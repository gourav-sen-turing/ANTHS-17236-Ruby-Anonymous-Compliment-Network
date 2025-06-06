class AddComplimentsCountToCategories < ActiveRecord::Migration[7.2]
  def change
    # Check if column doesn't exist before trying to add it
    unless column_exists?(:categories, :compliments_count)
      add_column :categories, :compliments_count, :integer, default: 0
    end

    # Reset column information to refresh the schema cache
    Category.reset_column_information

    # Update existing records to have a default count of 0
    # Also, calculate actual counts for existing categories if there are compliments
    Category.find_each do |category|
      # Get the actual count of compliments for this category
      actual_count = Compliment.where(category_id: category.id).count
      category.update_column(:compliments_count, actual_count)
    end
  end
end
