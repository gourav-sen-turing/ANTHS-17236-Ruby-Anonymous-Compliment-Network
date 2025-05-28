class Kudo < ApplicationRecord
  belongs_to :user
  belongs_to :compliment, counter_cache: :kudos_count

  validates :user_id, uniqueness: { scope: :compliment_id, message: "has already given kudos to this compliment" }
end
