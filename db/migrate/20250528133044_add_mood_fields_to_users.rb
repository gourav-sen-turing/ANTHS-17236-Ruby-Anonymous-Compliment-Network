class AddMoodFieldsToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :current_mood, :integer
    add_column :users, :mood_updated_at, :datetime

    add_index :users, :current_mood
    add_index :users, :mood_updated_at
  end
end
