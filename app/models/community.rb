class Community < ApplicationRecord
  belongs_to :creator, class_name: 'User'

  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships
  has_many :compliments, dependent: :nullify

  validates :name, presence: true, length: { minimum: 3, maximum: 50 }
  validates :slug, presence: true, uniqueness: true,
            format: { with: /\A[a-z0-9\-_]+\z/, message: "can only contain lowercase letters, numbers, hyphens and underscores" }
  validates :description, length: { maximum: 500 }

  enum community_type: {
    interest: 0,
    geographic: 1,
    workplace: 2,
    educational: 3,
    organization: 4
  }

  enum privacy_level: {
    open: 0,
    restricted: 1,
    members_only: 2
  }

  before_validation :generate_slug, if: -> { slug.blank? && name.present? }

  def active_users
    users.joins(:memberships).where(memberships: { status: :active })
  end

  def pending_users
    users.joins(:memberships).where(memberships: { status: :pending })
  end

  private

  def generate_slug
    self.slug = name.parameterize
  end
end
