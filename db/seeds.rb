# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

puts "Clearing existing categories..."
Category.destroy_all
puts "Creating new categories..."

# System categories that will be available in the compliment form dropdown
system_categories = [
  {
    name: "Professional Achievement",
    description: "Recognizing excellence and accomplishments in work or professional settings.",
    system: true
  },
  {
    name: "Personal Growth",
    description: "Acknowledging someone's self-improvement, learning, or personal development journey.",
    system: true
  },
  {
    name: "Kindness & Compassion",
    description: "Highlighting acts of kindness, empathy, or compassion toward others.",
    system: true
  },
  {
    name: "Creativity & Innovation",
    description: "Celebrating creative thinking, artistic expression, or innovative problem-solving.",
    system: true
  },
  {
    name: "Leadership",
    description: "Recognizing inspiring leadership qualities or actions that motivate others.",
    system: true
  },
  {
    name: "Teamwork",
    description: "Acknowledging collaborative efforts, contributions to group success, or being a great team player.",
    system: true
  },
  {
    name: "Overcoming Challenge",
    description: "Celebrating resilience and perseverance in the face of obstacles or difficulties.",
    system: true
  },
  {
    name: "Helpfulness",
    description: "Recognizing actions that assist, support, or make things easier for others.",
    system: true
  },
  {
    name: "Positive Attitude",
    description: "Acknowledging optimism, enthusiasm, or bringing positive energy to situations.",
    system: true
  },
  {
    name: "Thoughtfulness",
    description: "Celebrating considerate actions, attention to detail, or going the extra mile for others.",
    system: true
  },
  {
    name: "Character & Values",
    description: "Recognizing displays of integrity, honesty, authenticity, or admirable character traits.",
    system: true
  },
  {
    name: "Friendship",
    description: "Celebrating qualities that make someone a good friend or the value they bring to relationships.",
    system: true
  }
]

# Create all system categories
system_categories.each do |category_attrs|
  category = Category.create!(category_attrs)
  puts "Created system category: #{category.name}"
end

# Allow for user-created categories in the future (these won't show in dropdown by default)
user_categories = [
  {
    name: "General Appreciation",
    description: "A general expression of appreciation or gratitude that doesn't fit other categories.",
    system: false
  },
  {
    name: "Custom",
    description: "User-defined custom category for specialized compliments.",
    system: false
  }
]

# Create user categories
user_categories.each do |category_attrs|
  category = Category.create!(category_attrs)
  puts "Created user category: #{category.name}"
end

puts "Category seeding complete! Created #{Category.count} categories."

created_users = []
users_data = [
  {
    name: "Alex Johnson",
    username: "alex_j",
    email: "alex@example.com",
    password: "password",
    bio: "Software developer with a passion for building community tools...",
    role: 0 # Regular user
  },
  # 7 more users with varied backgrounds
  {
    name: "Morgan Chen",
    username: "morgan_c",
    email: "morgan@example.com",
    password: "password",
    bio: "Project manager and team leader...",
    role: 2 # Admin
  },
  # ...
]

users_data.each do |user_data|
  # Find or create the user to avoid errors on re-runs
  user = User.find_by(email: user_data[:email]) || User.create!(user_data)
  user.confirm if user.respond_to?(:confirm)

  # Set mood data...
  created_users << user
end

# Ensure we have users before proceeding
if created_users.empty?
  puts "Error: No users were created. Exiting seed process."
  exit
end

def generate_compliment_content(category_name)
  case category_name
  when "Professional Achievement"
    [
      "Your work on the recent project was outstanding. The attention to detail really shows!",
      # Additional template options...
    ].sample
  # Cases for other categories...
  end
end

def category_has_template_text?
  Category.column_names.include?('template_text')
rescue
  false
end

150.times do |i|
  sender = created_users.sample
  recipient = (created_users - [sender]).sample
  categories = Category.all
  if categories.empty?
    puts "Warning: No categories found. Please run the category seed first."
    categories = [Category.create!(name: "General", description: "General compliment", system: true)]
  end
  byebug
  category = categories.sample
  anonymous = rand < 0.4 # 40% chance of being anonymous

  # More configuration details...

  compliment = Compliment.new(
    content: generate_compliment_content(category&.name),
    recipient_id: recipient.id,
    sender_id: anonymous ? nil : sender.id,
    anonymous: anonymous,
    # More attributes...
  )
  compliment.save!
end
