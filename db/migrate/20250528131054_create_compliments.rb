class CreateCompliments < ActiveRecord::Migration[7.2]
  def change
    create_table :compliments do |t|
      t.text :content, null: false
      t.references :recipient, null: false, foreign_key: { to_table: :users }
      t.references :sender, foreign_key: { to_table: :users }
      t.boolean :anonymous, default: false
      t.string :status, default: 'pending'
      t.datetime :read_at
      t.references :community, foreign_key: true
      t.string :category
      t.integer :kudos_count, default: 0
      t.integer :reports_count, default: 0

      t.timestamps
    end

    add_index :compliments, :status
    add_index :compliments, :category
    add_index :compliments, :anonymous
    add_index :compliments, :read_at
  end
end
