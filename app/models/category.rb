class Category < ApplicationRecord
  # Associations
  has_many :compliments
  belongs_to :community, optional: true

  # Validations
  validates :name, presence: true
  validates :name, uniqueness: { scope: :community_id, message: "already exists in this context" }
  validates :color, format: { with: /\A#[0-9A-F]{6}\z/i, message: "must be a valid hex color code" }, allow_blank: true

  # Scopes
  scope :system_categories, -> { where(system: true) }
  scope :community_categories, ->(community_id) { where(community_id: community_id) }
  scope :available_for, ->(community_id) { where(system: true).or(where(community_id: community_id)) }
end
