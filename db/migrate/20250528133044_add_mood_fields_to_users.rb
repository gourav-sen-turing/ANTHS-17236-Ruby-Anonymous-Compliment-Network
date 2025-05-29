class AddMoodFieldsToUsers < ActiveRecord::Migration[7.0]
  def change
    unless column_exists?(:users, :current_mood)
      add_column :users, :current_mood, :integer
      add_index :users, :current_mood
    end

    unless column_exists?(:users, :mood_updated_at)
      add_column :users, :mood_updated_at, :datetime
      add_index :users, :mood_updated_at
    end
  end
end
