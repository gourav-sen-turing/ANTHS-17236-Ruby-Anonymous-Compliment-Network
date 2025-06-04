class AddAnonymityFieldsToCompliments < ActiveRecord::Migration[7.2]
  def change
    add_column :compliments, :anonymous_token, :string
    add_column :compliments, :sender_ip_hash, :string

    add_index :compliments, :anonymous_token, unique: true
  end
end
