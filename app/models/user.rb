class User < ApplicationRecord
  # Include default devise modules
  devise :database_authenticatable, :registerable,
  :recoverable, :rememberable, :validatable,
  :confirmable, :trackable

  # Attachments
  has_one_attached :avatar

  # Associations
  has_many :sent_compliments, class_name: 'Compliment', foreign_key: 'sender_id', dependent: :nullify
  has_many :received_compliments, class_name: 'Compliment', foreign_key: 'recipient_id', dependent: :destroy
  has_many :mood_entries, dependent: :destroy
  has_many :privacy_setting_changes, dependent: :destroy
  has_many :community_memberships, dependent: :destroy
  has_many :communities, through: :community_memberships

  # Validations
  validates :username, presence: true,
  uniqueness: { case_sensitive: false },
  length: { minimum: 3, maximum: 30 },
  format: { with: /\A[a-zA-Z0-9_]+\z/,
    message: "only allows letters, numbers, and underscores" }
    validates :anonymous_identifier, presence: true, uniqueness: true
    validate :anonymous_identifier_format

  # Attributes & Enums
  enum role: { user: 0, moderator: 1, admin: 2 }, _default: 0
  enum anonymity_level: {
    full_anonymity: 0,       # Hide all personal information
    partial_anonymity: 1,    # Show selective information like username only
    community_only: 2,       # Visible only within specific communities
    fully_visible: 3         # Public profile
  }, _default: 0

  attribute :profile_visible, :boolean, default: false
  attribute :terms_accepted, :boolean

  # Callbacks
  before_validation :set_anonymous_identifier, on: :create
  after_update :track_privacy_changes

  # Scopes
  scope :publicly_visible, -> { where(profile_visible: true) }
  scope :with_compliments, -> { joins(:sent_compliments).or(joins(:received_compliments)).distinct }
  scope :by_anonymity_level, -> (level) { where(anonymity_level: level) }

  # Public methods for anonymity management
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

    # Otherwise return a default anonymous avatar
    "anonymous_avatar.png"
  end

  def display_info_for(viewer = nil, context = :general)
    # Self always sees everything
    return {
      name: name,
      username: username,
      bio: bio,
      avatar: avatar_for_display(viewer),
      anonymous: false,
      anonymous_identifier: anonymous_identifier
    } if viewer == self

    case context
    when :compliment_sender
      return {name: anonymous_identifier, anonymous: true} unless profile_visible
      {name: name || username, anonymous: false}

    when :community_member
      return {name: anonymous_identifier, anonymous: true} if anonymity_level == "full_anonymity"

      if anonymity_level == "community_only" && viewer.present?
        shared_communities = communities.where(id: viewer.community_ids)
        return {name: anonymous_identifier, anonymous: true} unless shared_communities.any?
      end

      return {name: username, anonymous: true} if anonymity_level == "partial_anonymity"

      {
        name: name,
        username: username,
        bio: bio,
        avatar: avatar_for_display(viewer),
        anonymous: false
      }

    when :public
      return {name: anonymous_identifier, anonymous: true} unless anonymity_level == "fully_visible"

      {
        name: name,
        username: username,
        bio: bio,
        anonymous: false
      }

    else # :general
      return {name: anonymous_identifier, anonymous: true} unless profile_visible
      {name: name || username, anonymous: false}
    end
  end

  def visible_to?(viewer, context = :general)
    return true if viewer == self

    case context
    when :community_member
      return false if anonymity_level == "full_anonymity"

      if anonymity_level == "community_only" && viewer.present?
        shared_communities = communities.where(id: viewer.community_ids)
        return shared_communities.any?
      end

      return anonymity_level != "partial_anonymity"

    when :public
      return anonymity_level == "fully_visible"
    else
      return profile_visible
    end
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

  def anonymous_identifier_format
    return unless anonymous_identifier.present?

    # Ensure it follows the pattern that doesn't leak personal info
    unless anonymous_identifier.match?(/\A[A-Z][a-z]+[A-Z][a-z]+\d+\z/)
      errors.add(:anonymous_identifier, "doesn't follow required format")
    end
  end

  def track_privacy_changes
    if saved_change_to_profile_visible? || saved_change_to_anonymity_level?
      privacy_setting_changes.create(
        changed_by: self,
        previous_visibility: profile_visible_before_last_save ? "visible" : "hidden",
        current_visibility: profile_visible ? "visible" : "hidden",
        previous_anonymity_level: anonymity_level_before_last_save,
        current_anonymity_level: anonymity_level,
        changed_at: Time.current
        )
    end
  end
end
