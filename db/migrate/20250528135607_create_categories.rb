class CreateCategories < ActiveRecord::Migration[7.2]
  def change
    create_table :categories do |t|
      t.string :name, null: false
      t.text :description
      t.string :icon
      t.string :color, default: "#6366F1" # Default indigo color
      t.string :scope, default: "global"
      t.references :created_by, foreign_key: { to_table: :users }
      t.references :community, foreign_key: true
      t.integer :compliments_count, default: 0

      t.timestamps
    end

    add_index :categories, :name
    add_index :categories, :scope
    add_index :categories, [:scope, :community_id]
    add_index :categories, [:name, :scope, :community_id], unique: true
  end
end
