# app/models/user.rb
class User < ApplicationRecord
  # Include default devise modules
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
         #,:confirmable

  # Associations
  has_many :sent_compliments, class_name: 'Compliment', foreign_key: 'sender_id', dependent: :nullify
  has_many :received_compliments, class_name: 'Compliment', foreign_key: 'recipient_id', dependent: :destroy
  has_many :mood_entries, dependent: :destroy
  has_many :memberships, dependent: :destroy
  has_many :communities, through: :memberships
  has_many :created_communities, class_name: 'Community', foreign_key: 'creator_id', dependent: :nullify

  # Active Storage
  has_one_attached :avatar

  # Attributes
  # Only use attribute for virtual attributes that don't have DB columns!
  attribute :terms_accepted, :boolean

  # Enums - these need actual database columns
  enum role: { user: 0, moderator: 1, admin: 2 }, _default: 0
  enum anonymity_level: {
    full_anonymity: 0,
    partial_anonymity: 1,
    community_only: 2,
    fully_visible: 3
  }, _default: 0

  # Validations
  validates :username, presence: true,
                     uniqueness: { case_sensitive: false },
                     length: { minimum: 3, maximum: 30 },
                     format: { with: /\A[a-zA-Z0-9_]+\z/,
                               message: "only allows letters, numbers, and underscores" }

  validates :anonymous_identifier, uniqueness: true, allow_blank: true

  # Callbacks
  before_create :set_anonymous_identifier

  # Methods for anonymous profiles
  def display_name(viewer = nil)
    return username if viewer == self
    return anonymous_identifier if !profile_visible || anonymity_level == "full_anonymity"
    return username if anonymity_level == "partial_anonymity"

    if anonymity_level == "community_only" && viewer.present?
      shared_communities = communities.where(id: viewer.community_ids)
      return username if shared_communities.any?
      return anonymous_identifier
    end

    name.presence || username
  end

  def visible_bio(viewer = nil)
    return bio if viewer == self
    return nil if !profile_visible || anonymity_level == "full_anonymity"
    return nil if anonymity_level == "partial_anonymity"

    if anonymity_level == "community_only" && viewer.present?
      shared_communities = communities.where(id: viewer.community_ids)
      return nil unless shared_communities.any?
    end

    bio
  end

  def avatar_for_display(viewer = nil)
    return avatar if avatar.attached? && (viewer == self || (profile_visible && anonymity_level == "fully_visible"))

    # Return a default anonymous avatar
    "anonymous_avatar.png"
  end

  def joined_communities
    communities.joins(:memberships).where(memberships: { user_id: id, status: :active })
  end

  def pending_communities
    communities.joins(:memberships).where(memberships: { user_id: id, status: :pending })
  end

  def join_community(community, status = :pending)
    memberships.create(community: community, status: status)
  end

  def leave_community(community)
    memberships.find_by(community: community)&.destroy
  end

  def community_role(community)
    memberships.find_by(community: community)&.role
  end

  def is_community_admin?(community)
    memberships.exists?(community: community, role: :admin) || created_communities.exists?(id: community.id)
  end

  def is_community_moderator?(community)
    memberships.exists?(community: community, role: [:moderator, :admin]) || created_communities.exists?(id: community.id)
  end

  def initials
    if name.present?
      # Split name by spaces and take first letter of first and last components
      name_parts = name.split
      if name_parts.length >= 2
        "#{name_parts.first[0]}#{name_parts.last[0]}".upcase
      else
        name_parts.first[0].upcase
      end
    elsif username.present?
      # If no name, use the first letter of username
      username[0].upcase
    else
      # Fallback if neither name nor username are available
      "U"
    end
  rescue
    # Ensure we always return something even if there's an error
    "U"
  end

  private

  def set_anonymous_identifier
    return if anonymous_identifier.present?

    loop do
      adjectives = ['Mysterious', 'Anonymous', 'Enigmatic', 'Hidden', 'Secret', 'Incognito']
      nouns = ['Penguin', 'Dolphin', 'Falcon', 'Tiger', 'Phoenix', 'Voyager']
      number = rand(1..999)

      self.anonymous_identifier = "#{adjectives.sample}#{nouns.sample}#{number}"
      break unless User.exists?(anonymous_identifier: anonymous_identifier)
    end
  end
end
