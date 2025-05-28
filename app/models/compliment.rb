class Compliment < ApplicationRecord
  # Associations
  belongs_to :recipient, class_name: 'User'
  belongs_to :sender, class_name: 'User', optional: true
  belongs_to :community, optional: true

  has_many :kudos, dependent: :destroy
  has_many :reports, dependent: :destroy

  # Validations
  validates :content, presence: true, length: { in: 10..1000 }
  validates :status, inclusion: { in: %w(pending approved rejected) }
  validates :category, inclusion: {
    in: %w(professional personal achievement kindness helpful creative other),
    allow_blank: true
  }

  # Scopes
  scope :pending, -> { where(status: 'pending') }
  scope :approved, -> { where(status: 'approved') }
  scope :rejected, -> { where(status: 'rejected') }
  scope :unread, -> { where(read_at: nil) }
  scope :read, -> { where.not(read_at: nil) }
  scope :anonymous_only, -> { where(anonymous: true) }
  scope :identified, -> { where(anonymous: false) }
  scope :in_community, ->(community) { where(community: community) }
  scope :by_category, ->(category) { where(category: category) }

  # Callbacks
  before_validation :set_defaults
  after_create :notify_recipient

  # Additional associations for ActionCable notifications
  has_many :notifications, as: :subject, dependent: :destroy

  # Instance methods
  def read?
    read_at.present?
  end

  def unread?
    !read?
  end

  def mark_as_read!
    return if read?
    update(read_at: Time.current)
  end

  def approve!
    update(status: 'approved')
    notify_recipient if recipient.present?
  end

  def reject!
    update(status: 'rejected')
  end

  def sender_name
    return "Anonymous" if anonymous?
    sender&.name || "Unknown"
  end

  def add_kudo!(user)
    kudos.create(user: user)
  end

  def report!(user, reason = nil)
    reports.create(reporter: user, reason: reason)
  end

  # Check for inappropriate content using simple pattern matching
  # In a real app, you might use a content moderation service or AI
  def potentially_inappropriate?
    inappropriate_patterns = [
      /\b(hate|racist|sexist|violent)\b/i,
      # Add more patterns or integrate with an external filtering service
    ]

    inappropriate_patterns.any? { |pattern| content.match?(pattern) }
  end

  private

  def set_defaults
    self.status ||= potentially_inappropriate? ? 'pending' : 'approved'
  end

  def notify_recipient
    return unless status == 'approved'
    return unless recipient.present?

    # This would typically use ActionCable or Turbo Streams in a real implementation
    # Just a placeholder for now
    Notification.create(
      recipient: recipient,
      actor: anonymous? ? nil : sender,
      action: "sent",
      subject: self
    )
  end
end
