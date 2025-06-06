class Compliment < ApplicationRecord
  belongs_to :recipient, class_name: "User"
  belongs_to :sender, class_name: "User", optional: true
  belongs_to :community, optional: true
  belongs_to :category, optional: true

  # Enhanced validation with better error messages
  validates :content,
    presence: { message: "can't be blank - please write your compliment" },
    length: {
      minimum: 10,
      maximum: 500,
      too_short: "is too short (minimum is %{count} characters) - please share something more meaningful",
      too_long: "is too long (maximum is %{count} characters) - please be more concise"
    }
  validates :recipient_id, presence: true

  # Scopes
  scope :published, -> { where(status: 'published') }
  scope :from_community, ->(community_id) { where(community_id: community_id) }

  # Updated enum syntax to avoid deprecation warning
  enum :status, { pending: 0, published: 1, flagged: 2, removed: 3 }

  # Callbacks
  before_create :generate_anonymous_token, if: :anonymous?
  after_create :increment_counters
  after_destroy :decrement_counters

  # Custom validations
  validate :sender_cannot_be_recipient
  validate :category_compatible_with_community, if: -> { community_id.present? && category_id.present? }

  # Public methods
  def anonymous?
    anonymous == true
  end

  def read?
    read_at.present?
  end

  def mark_as_read!
    update(read_at: Time.current, status: :published) unless read?
  end

  def add_kudos!
    increment!(:kudos_count)
  end

  def remove_kudos!
    decrement!(:kudos_count) if kudos_count > 0
  end

  def self.recent_compliments(limit = 5)
    order(created_at: :desc).limit(limit)
  end

  # Private methods
  private

  # This is the method that was missing proper implementation
  def sender_cannot_be_recipient
    # Only validate when sender_id is present (not anonymous)
    if sender_id.present? && sender_id == recipient_id
      errors.add(:recipient_id, "cannot be the same as sender - you can't compliment yourself")
    end
  end

  def category_compatible_with_community
    return if category.nil? || community.nil?

    # Check if category is system-wide or belongs to the specified community
    unless category.system? || category.community_id == community.id
      errors.add(:category_id, "is not compatible with the selected community")
    end
  end

  def generate_anonymous_token
    self.anonymous_token = SecureRandom.hex(10)
  end

  def increment_counters
    if community_id.present?
      Community.increment_counter(:compliments_count, community_id)
    end

    if category_id.present?
      Category.increment_counter(:compliments_count, category_id)
    end
  end

  def decrement_counters
    if community_id.present?
      Community.decrement_counter(:compliments_count, community_id)
    end

    if category_id.present?
      Category.decrement_counter(:compliments_count, category_id)
    end
  end
end
