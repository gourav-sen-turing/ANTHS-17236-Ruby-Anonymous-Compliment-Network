class Compliment < ApplicationRecord
  # Associations
  belongs_to :recipient, class_name: 'User'
  belongs_to :sender, class_name: 'User', optional: true
  belongs_to :community, optional: true
  belongs_to :category, optional: true

  has_many :kudos, dependent: :destroy
  has_many :reports, dependent: :destroy

  scope :published, -> { where(status: 1) }
  scope :from_community, ->(community_id) { where(community_id: community_id) }

  # Attributes
  attribute :anonymous, :boolean, default: false

  # Enums
  enum :status, [:pending, :published, :flagged, :removed], default: :pending

  # Validations
  validates :content,
  presence: { message: "can't be blank - please write your compliment" },
  length: {
    minimum: 10,
    maximum: 500,
    too_short: "is too short (minimum is %{count} characters) - please share something more meaningful",
    too_long: "is too long (maximum is %{count} characters) - please be more concise"
  }
  validates :recipient_id, presence: true
  validates :category_id, presence: true
  validates :anonymous_token, uniqueness: true, allow_nil: true
  validate :sender_or_anonymous_required
  validate :category_compatible_with_community
  validate :not_self_complimenting
  validate :sender_cannot_be_recipient
  validate :category_compatible_with_community, if: -> { community_id.present? && category_id.present? }

  # Callbacks
  before_create :generate_anonymous_token, if: :anonymous?
  after_create :increment_counters
  after_destroy :decrement_counters

  # Methods for anonymity
  def generate_anonymous_token
    self.anonymous_token = SecureRandom.uuid
  end

  def store_hashed_ip(ip_address)
    return unless anonymous?

    secret = Rails.application.credentials.secret_key_base || Rails.application.config.secret_key_base
    self.sender_ip_hash = Digest::SHA256.hexdigest("#{ip_address}-#{secret}")
  end

  # Sender visibility methods
  def reveal_sender?
    !anonymous? && sender.present?
  end

  def sender_name
    reveal_sender? ? sender.name : "Anonymous"
  end

  # Utility methods
  def mark_as_read!
    return if read_at?
    update(read_at: Time.current)
  end

  def mark_as_flagged!
    update(status: :flagged)
  end

  private

  def sender_or_anonymous_required
    if !anonymous? && sender.blank?
      errors.add(:base, "Compliment must either be anonymous or have a sender")
    end
  end

  def not_self_complimenting
    if sender.present? && sender_id == recipient_id
      errors.add(:recipient_id, "cannot be the same as the sender")
    end
  end

  def category_compatible_with_community
    return if category.nil? || community.nil?

    # Check if category is system-wide or belongs to the specified community
    unless category.system? || category.community_id == community.id
      errors.add(:category_id, "is not compatible with the selected community")
    end
  end
end
