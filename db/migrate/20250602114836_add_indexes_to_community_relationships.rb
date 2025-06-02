class AddIndexesToCommunityRelationships < ActiveRecord::Migration[7.2]
  def change
    # Remove or comment out this line:
    # add_index :compliments, :community_id

    # Keep the new indexes that don't exist yet:
    add_index :memberships, [:community_id, :role]
    add_index :memberships, [:community_id, :status]
    add_index :memberships, [:user_id, :status]
  end
end
