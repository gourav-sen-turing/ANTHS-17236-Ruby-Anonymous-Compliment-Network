class CreateJoinTableComplimentsCategories < ActiveRecord::Migration[7.2]
  def change
    create_join_table :compliments, :categories do |t|
      t.index [:compliment_id, :category_id], unique: true
      t.index [:category_id, :compliment_id]
    end
  end
end
