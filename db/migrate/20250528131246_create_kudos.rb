class CreateKudos < ActiveRecord::Migration[7.2]
  def change
    create_table :kudos do |t|
      t.references :user, null: false, foreign_key: true
      t.references :compliment, null: false, foreign_key: true

      t.timestamps
    end
  end
end
