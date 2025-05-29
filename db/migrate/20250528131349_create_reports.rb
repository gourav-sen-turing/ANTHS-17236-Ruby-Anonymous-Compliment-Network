class CreateReports < ActiveRecord::Migration[7.2]
  def change
    create_table :reports do |t|
      t.references :reporter, null: false, foreign_key: true
      t.references :compliment, null: false, foreign_key: true
      t.string :status

      t.timestamps
    end
  end
end
