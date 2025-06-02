class User < ApplicationRecord
  # Include default devise modules
  devise :database_authenticatable, :registerable,
  :recoverable, :rememberable, :validatable

  has_many :memberships, dependent: :destroy
  has_many :communities, through: :memberships
  has_many :created_communities, class_name: 'Community', foreign_key: 'created_by_id'

  has_many :received_compliments, class_name: 'Compliment', foreign_key: 'recipient_id', dependent: :nullify
  has_many :sent_compliments, class_name: 'Compliment', foreign_key: 'sender_id', dependent: :nullify
  has_many :kudos, dependent: :destroy
  has_many :given_kudos, through: :kudos, source: :compliment

  has_many :mood_entries, dependent: :destroy

  has_many :created_categories, class_name: 'Category', foreign_key: 'created_by_id', dependent: :nullify

  # Validations
  validates :username, presence: true,
            uniqueness: { case_sensitive: false },
            length: { minimum: 3, maximum: 30 },
            format: { with: /\A[a-zA-Z0-9_]+\z/,
              message: "only allows letters, numbers, and underscores" }
              validates :role, inclusion: { in: %w(user admin moderator) }
              validates :mood, inclusion: { in: 1..5 }, allow_nil: true

  # Callbacks
  before_validation :set_anonymous_identifier, on: :create
  before_validation :extract_email_domain, if: :email_changed?

  # Avatar attachment using Active Storage
  has_one_attached :avatar

  # Virtual attribute for avatar upload
  attr_accessor :avatar_upload

  # Callbacks for avatar processing
  after_save :attach_avatar, if: :avatar_upload

  def average_mood(period = :all)
    entries = case period
    when :today
      mood_entries.where(recorded_at: Date.current.all_day)
    when :week
      mood_entries.where(recorded_at: Date.current.all_week)
    when :month
      mood_entries.where(recorded_at: Date.current.all_month)
    else
      mood_entries
    end

    entries.average(:value)&.round(2) || nil
  end

  def mood_trend(days = 14)
    MoodEntry.trend_data(self, days)
  end

  def mood_status
    return "Unknown" if current_mood.nil?

    MoodEntry::MOOD_LABELS[current_mood] || "Unknown"
  end

  def mood_icon
    return "❓" if current_mood.nil?

    case current_mood
    when 1 then "😢"
    when 2 then "🙁"
    when 3 then "😐"
    when 4 then "🙂"
    when 5 then "😄"
    else "❓"
    end
  end

  def mood_freshness
    return :stale if mood_updated_at.nil?

    hours_ago = ((Time.current - mood_updated_at) / 1.hour).round

    if hours_ago < 6
      :fresh
    elsif hours_ago < 24
      :recent
    else
      :stale
    end
  end

  def available_categories(community = nil)
    Category.available_for(self, community)
  end

  private

  def set_anonymous_identifier
    self.anonymous_identifier = loop do
      identifier = SecureRandom.alphanumeric(8)
      break identifier unless User.exists?(anonymous_identifier: identifier)
    end
  end

  def extract_email_domain
    self.email_domain = email.split('@').last if email.present? && email.include?('@')
  end

  def attach_avatar
    avatar.attach(avatar_upload) if avatar_upload.present?
  end
end
