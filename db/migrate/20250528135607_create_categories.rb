class CreateCategories < ActiveRecord::Migration[7.2]
  def change
    create_table :categories do |t|
      t.string :name, null: false
      t.text :description
      t.string :icon
      t.string :color, limit: 7
      t.text :template_text
      t.boolean :system, default: false
      t.references :community, foreign_key: true, index: true

      t.timestamps

      t.index [:name, :community_id], unique: true
    end
  end
end
