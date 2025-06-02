class AddAnonymityLevelToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :anonymity_level, :integer, default: 0, null: false
    add_index :users, :anonymity_level

    # While we're at it, let's also add anonymous_identifier if it doesn't exist
    unless column_exists?(:users, :anonymous_identifier)
      add_column :users, :anonymous_identifier, :string
      add_index :users, :anonymous_identifier, unique: true
    end

    # And profile_visible if it doesn't exist
    unless column_exists?(:users, :profile_visible)
      add_column :users, :profile_visible, :boolean, default: false
    end
  end
end
