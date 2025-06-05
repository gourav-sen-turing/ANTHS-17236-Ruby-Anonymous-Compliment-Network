class SetupManyToManyCategoryCommunity < ActiveRecord::Migration[7.2]
  def up
    # Create the join table if it doesn't exist
    create_table :community_categories do |t|
      t.references :community, foreign_key: true
      t.references :category, foreign_key: true
      t.timestamps
      t.index [:community_id, :category_id], unique: true
    end

    # Migrate existing relationships with SQLite's datetime() function
    execute <<-SQL
      INSERT INTO community_categories (community_id, category_id, created_at, updated_at)
      SELECT community_id, id, datetime('now'), datetime('now')
      FROM categories
      WHERE community_id IS NOT NULL;
    SQL

    # Remove the direct foreign key
    remove_column :categories, :community_id
  end

  def down
    # This would undo the migration but might lose data if a category belongs to multiple communities
    add_column :categories, :community_id, :integer
    add_index :categories, :community_id

    # Copy the first community_id for each category
    execute <<-SQL
      UPDATE categories
      SET community_id = (
        SELECT community_id
        FROM community_categories
        WHERE category_id = categories.id
        LIMIT 1
      )
      WHERE id IN (SELECT DISTINCT category_id FROM community_categories);
    SQL

    drop_table :community_categories
  end
end
