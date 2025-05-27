class CreateTestTable < ActiveRecord::Migration[7.2]
  def change
    create_table :test_tables do |t|
      t.string :name

      t.timestamps
    end
  end
end
