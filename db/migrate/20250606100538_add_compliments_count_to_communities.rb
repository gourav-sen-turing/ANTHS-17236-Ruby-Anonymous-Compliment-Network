class AddComplimentsCountToCommunities < ActiveRecord::Migration[7.2]
  def change
    # Check if column doesn't exist before trying to add it
    unless column_exists?(:communities, :compliments_count)
      add_column :communities, :compliments_count, :integer, default: 0
    end

    # Update existing records to have a default count of 0
    Community.reset_column_information
    Community.all.each do |community|
      community.update_column(:compliments_count, 0) unless community.compliments_count.present?
    end
  end
end
