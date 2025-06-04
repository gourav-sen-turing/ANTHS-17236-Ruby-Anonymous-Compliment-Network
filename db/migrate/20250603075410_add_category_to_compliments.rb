class AddCategoryToCompliments < ActiveRecord::Migration[7.2]
  def change
    add_reference :compliments, :category, foreign_key: true, index: true
  end
end
