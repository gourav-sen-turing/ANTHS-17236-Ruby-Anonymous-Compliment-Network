class CreateMoodEntries < ActiveRecord::Migration[7.2]
  def change
    create_table :mood_entries do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :value, null: false
      t.text :notes
      t.datetime :recorded_at, null: false
      t.references :compliment, foreign_key: true
      t.string :context
      t.string :factors

      t.timestamps
    end

    add_index :mood_entries, :value
    add_index :mood_entries, :recorded_at
    add_index :mood_entries, :context
    add_index :mood_entries, [:user_id, :recorded_at]
  end
end
