class CreateCommunities < ActiveRecord::Migration[7.2]
  def change
    create_table :communities do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.string :community_type, default: 'interest'
      t.string :email_domain
      t.string :privacy_level, default: 'public'
      t.text :rules
      t.string :join_code
      t.references :created_by, foreign_key: { to_table: :users }
      t.integer :compliments_count, default: 0
      t.integer :members_count, default: 0

      t.timestamps
    end

    add_index :communities, :slug, unique: true
    add_index :communities, :email_domain
    add_index :communities, :community_type
    add_index :communities, :privacy_level
  end
end
