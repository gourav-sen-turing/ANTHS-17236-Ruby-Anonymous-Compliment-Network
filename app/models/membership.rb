class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :community

  validates :user_id, uniqueness: { scope: :community_id, message: "is already a member of this community" }

  enum role: {
    member: 0,
    moderator: 1,
    admin: 2
  }

  enum status: {
    pending: 0,
    active: 1,
    blocked: 2
  }

  before_create :set_joined_at, if: -> { status.to_sym == :active }

  private

  def set_joined_at
    self.joined_at = Time.current
  end
end
