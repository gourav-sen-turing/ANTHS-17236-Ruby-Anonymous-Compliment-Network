class Compliment < ApplicationRecord
  # Associations
  belongs_to :recipient, class_name: 'User'
  belongs_to :sender, class_name: 'User', optional: true
  belongs_to :community, optional: true
  belongs_to :category

  has_many :kudos, dependent: :destroy
  has_many :reports, dependent: :destroy

  # Attributes
  attribute :anonymous, :boolean, default: false

  # Enums
  enum status: { pending: 0, approved: 1, rejected: 2, flagged: 3 }

  # Validations
  validates :content, presence: true,
  length: { minimum: 5, maximum: 500 }
  validates :recipient_id, presence: true
  validates :category_id, presence: true
  validates :anonymous_token, uniqueness: true, allow_nil: true
  validate :sender_or_anonymous_required
  validate :category_compatible_with_community
  validate :not_self_complimenting

  # Callbacks
  before_create :generate_anonymous_token, if: :anonymous?

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

    # Check if the category is system-wide
    is_system_category = category.system == true

    # Check if the category is explicitly associated with the community
    is_community_category = category.communities.exists?(community.id)

    # Add error if neither condition is true
    unless is_system_category || is_community_category
      errors.add(:category_id, "is not compatible with the selected community")
    end
  end
end
