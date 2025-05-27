class User < ApplicationRecord
  # Include default devise modules
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Validations
  validates :username, presence: true, uniqueness: true,
            length: { minimum: 3, maximum: 30 },
            format: { with: /\A[a-zA-Z0-9_]+\z/, message: "only allows letters, numbers, and underscores" }
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
