class Compliment < ApplicationRecord
  # Existing associations
  belongs_to :recipient, class_name: 'User'
  belongs_to :sender, class_name: 'User', optional: true
  belongs_to :community, optional: true
  belongs_to :category, optional: true

  has_many :kudos, dependent: :destroy
  has_many :reports, dependent: :destroy

  # Enums
  enum status: { pending: 0, approved: 1, rejected: 2, flagged: 3 }

  # Validations
  validates :content, presence: true, length: { minimum: 5, maximum: 500 }
  validates :anonymous_token, uniqueness: true, allow_nil: true

  # Callbacks
  before_create :generate_anonymous_token, if: :anonymous?

  # Scopes
  scope :anonymous_only, -> { where(anonymous: true) }
  scope :identified, -> { where(anonymous: false) }
  scope :by_category, ->(category_id) { where(category_id: category_id) }

  # Methods for anonymity
  def generate_anonymous_token
    self.anonymous_token = SecureRandom.uuid
  end

  def store_hashed_ip(ip_address)
    return unless anonymous?
    require 'digest'
    # Only store a one-way hash of the IP, never the actual IP
    self.sender_ip_hash = Digest::SHA256.hexdigest(ip_address + Rails.application.secrets.secret_key_base)
  end

  # Sender visibility methods
  def reveal_sender?
    !anonymous? && sender.present?
  end

  def sender_name
    reveal_sender? ? sender.name : "Anonymous"
  end

  # Moderation and safety
  def mark_as_read!
    update(read_at: Time.current) unless read_at?
  end

  def mark_as_flagged!
    update(status: :flagged)
  end
end
