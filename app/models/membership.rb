class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :community, counter_cache: :members_count

  validates :user_id, uniqueness: { scope: :community_id, message: "is already a member of this community" }
  validates :role, inclusion: { in: %w(member moderator admin), message: "%{value} is not a valid role" }

  before_validation :set_defaults

  private

  def set_defaults
    self.role ||= 'member'
    self.joined_at ||= Time.current
  end
end
