class CreateMemberships < ActiveRecord::Migration[7.2]
  def change
    create_table :memberships do |t|
      t.references :user, null: false, foreign_key: true
      t.references :community, null: false, foreign_key: true
      t.integer :role, default: 0
      t.integer :status, default: 0
      t.datetime :joined_at

      t.timestamps
    end

    add_index :memberships, [:user_id, :community_id], unique: true
    add_index :memberships, :status
    add_index :memberships, :role
  end
end
