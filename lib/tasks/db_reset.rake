namespace :db do
  desc "Custom database creation that bypasses credentials checks"
  task :create_simple do
    db_file = Rails.root.join('db', "#{Rails.env}.sqlite3")

    unless File.exist?(db_file)
      # Ensure db directory exists
      FileUtils.mkdir_p(Rails.root.join('db'))

      # Create empty SQLite database
      SQLite3::Database.new(db_file.to_s)

      puts "Created database #{db_file}"
    else
      puts "Database #{db_file} already exists"
    end
  end

  desc "Reset all database files"
  task :reset_all do
    FileUtils.rm_rf(Dir.glob(Rails.root.join('db', '*.sqlite3')))
    puts "All database files removed"
    Rake::Task["db:create_simple"].invoke
  end
end
