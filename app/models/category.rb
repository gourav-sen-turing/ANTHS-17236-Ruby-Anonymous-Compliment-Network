class Category < ApplicationRecord
  # Constants
  SCOPES = %w[global community user].freeze

  # Associations
  belongs_to :created_by, class_name: 'User', optional: true
  belongs_to :community, optional: true
  has_and_belongs_to_many :compliments

  # Validations
  validates :name, presence: true, length: { in: 2..50 }
  validates :scope, inclusion: { in: SCOPES }
  validates :name, uniqueness: { scope: [:scope, :community_id],
                                case_sensitive: false,
                                message: "already exists in this scope" }
  validate :valid_scope_associations

  # Scopes
  scope :global, -> { where(scope: 'global') }
  scope :community_specific, -> { where(scope: 'community') }
  scope :user_defined, -> { where(scope: 'user') }
  scope :for_community, ->(community_id) { where(scope: 'global').or(where(community_id: community_id, scope: 'community')) }
  scope :for_user, ->(user_id) { where(scope: 'global').or(where(created_by_id: user_id, scope: 'user')) }
  scope :available_for, ->(user, community = nil) {
    result = global
    result = result.or(where(created_by_id: user.id, scope: 'user')) if user
    result = result.or(where(community_id: community.id, scope: 'community')) if community
    result
  }

  # Callbacks
  before_validation :normalize_values

  # Instance methods
  def global?
    scope == 'global'
  end

  def community_specific?
    scope == 'community'
  end

  def user_defined?
    scope == 'user'
  end

  def editable_by?(user)
    return false unless user
    return true if user.admin?

    if global?
      user.admin?
    elsif community_specific?
      community&.moderator?(user) || created_by_id == user.id
    else # user_defined
      created_by_id == user.id
    end
  end

  def hex_color
    color.start_with?('#') ? color : "##{color}"
  end

  def icon_class
    icon.present? ? icon : "tag" # Default icon
  end

  # Class methods
  def self.seed_defaults
    return if exists?(scope: 'global')

    [
      { name: 'Kindness', description: 'Acts of kindness and compassion', icon: 'heart', color: '#EF4444' },
      { name: 'Creativity', description: 'Creative thinking and innovation', icon: 'lightbulb', color: '#F59E0B' },
      { name: 'Support', description: 'Providing help and support', icon: 'hands-helping', color: '#10B981' },
      { name: 'Leadership', description: 'Demonstrating leadership qualities', icon: 'crown', color: '#6366F1' },
      { name: 'Teamwork', description: 'Collaboration and team contributions', icon: 'users', color: '#8B5CF6' },
      { name: 'Achievement', description: 'Recognizing accomplishments', icon: 'trophy', color: '#EC4899' },
      { name: 'Growth', description: 'Personal or professional development', icon: 'chart-line', color: '#14B8A6' },
      { name: 'Inspiration', description: 'Inspiring others through actions', icon: 'fire', color: '#F97316' }
    ].each do |attributes|
      create!(attributes.merge(scope: 'global'))
    end
  end

  private

  def normalize_values
    self.name = name.strip.titleize if name
    self.color = color.downcase if color
  end

  def valid_scope_associations
    case scope
    when 'global'
      if community_id.present?
        errors.add(:community_id, "should be nil for global categories")
      end
    when 'community'
      if community_id.blank?
        errors.add(:community_id, "can't be blank for community categories")
      end
    when 'user'
      if created_by_id.blank?
        errors.add(:created_by_id, "can't be blank for user categories")
      end
    end
  end
end
