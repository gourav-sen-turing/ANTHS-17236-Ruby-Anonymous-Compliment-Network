class Community < ApplicationRecord
  # Associations
  belongs_to :created_by, class_name: 'User'
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships
  has_many :compliments

  # Active Storage
  has_one_attached :avatar

  # Validations
  validates :name, presence: true, length: { in: 3..50 }
  validates :slug, presence: true, uniqueness: true,
            format: { with: /\A[a-z0-9-]+\z/, message: "only allows lowercase letters, numbers, and hyphens" }
  validates :community_type, inclusion: { in: %w(geographic workplace interest), message: "%{value} is not a valid community type" }
  validates :privacy_level, inclusion: { in: %w(public private invite_only), message: "%{value} is not a valid privacy level" }
  validates :email_domain, format: { with: /\A[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,}\z/i, message: "not a valid domain format" },
            allow_blank: true

  # Callbacks
  before_validation :generate_slug, if: -> { slug.blank? && name.present? }

  # Scopes
  scope :public_communities, -> { where(privacy_level: 'public') }
  scope :by_type, ->(type) { where(community_type: type) }
  scope :searchable, -> { where(privacy_level: ['public', 'private']) }

  # Instance Methods
  def to_param
    slug
  end

  def public?
    privacy_level == 'public'
  end

  def private?
    privacy_level == 'private'
  end

  def invite_only?
    privacy_level == 'invite_only'
  end

  def domain_restricted?
    email_domain.present?
  end

  def user_can_join?(user)
    return true if public?
    return false unless user

    if domain_restricted?
      user_domain = user.email.split('@').last
      return user_domain == email_domain
    end

    false
  end

  private

  def generate_slug
    base_slug = name.parameterize
    candidate_slug = base_slug
    counter = 0

    while Community.exists?(slug: candidate_slug)
      counter += 1
      candidate_slug = "#{base_slug}-#{counter}"
    end

    self.slug = candidate_slug
  end
end
