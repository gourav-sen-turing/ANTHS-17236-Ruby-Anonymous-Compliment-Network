class CreateCommunities < ActiveRecord::Migration[7.2]
  def change
    create_table :communities do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.integer :community_type, default: 0
      t.string :domain
      t.integer :privacy_level, default: 0
      t.references :creator, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :communities, :name
    add_index :communities, :slug, unique: true
    add_index :communities, :domain
    add_index :communities, :community_type
  end
end
