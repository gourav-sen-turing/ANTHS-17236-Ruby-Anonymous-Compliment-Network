# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

def generate_compliment_content(category_name)
  case category_name
  when "Professional Achievement"
    [
      "Your work on the recent project was outstanding. The attention to detail really shows!",
      "I was impressed by how you handled the presentation last week. You showed real expertise.",
      "The way you solved that complex problem was brilliant. Thanks for sharing your knowledge."
    ].sample
  when "Personal Growth"
    [
      "I've noticed how much you've grown in your communication skills lately. It's really impressive!",
      "The way you've been developing your leadership abilities is inspirational. Keep it up!",
      "Your commitment to learning new things is admirable. Your growth mindset is contagious."
    ].sample
  when "Kindness & Compassion"
    [
      "Thank you for your support during the team meeting. Your kindness made a difficult conversation easier.",
      "I appreciate how you took the time to help the new team member get oriented. Very thoughtful!",
      "The empathy you showed when I was struggling with the deadline didn't go unnoticed. Thank you."
    ].sample
  when "Creativity & Innovation"
    [
      "Your creative approach to the design challenge brought a fresh perspective that we needed.",
      "I love the innovative solution you proposed for our recurring issue. Very outside-the-box!",
      "The creative energy you bring to brainstorming sessions elevates everyone's thinking."
    ].sample
  when "Leadership"
    [
      "Your leadership during the recent crisis was calm and decisive. It helped the whole team stay focused.",
      "I admire how you lead by example, never asking others to do what you wouldn't do yourself.",
      "The way you empower team members to make decisions shows real leadership maturity."
    ].sample
  when "Teamwork"
    [
      "You're an exceptional team player. Your willingness to help others makes our whole group stronger.",
      "Your contribution to the group project was invaluable. We couldn't have succeeded without you.",
      "I appreciate how you always make sure everyone's voice is heard during meetings."
    ].sample
  when "Overcoming Challenge"
    [
      "The resilience you showed while dealing with those technical issues was impressive.",
      "I admire how you persevered through the difficult parts of the project without compromising quality.",
      "Your positive attitude when facing obstacles is something we can all learn from."
    ].sample
  when "Helpfulness"
    [
      "Thank you for stepping in to help with the documentation when I was overwhelmed.",
      "I really appreciate you taking the time to explain that complex concept to me yesterday.",
      "Your assistance with troubleshooting saved me hours of work. Really grateful!"
    ].sample
  when "Positive Attitude"
    [
      "Your optimism during the stressful deadline period lifted everyone's spirits.",
      "The positive energy you bring to team meetings changes the whole atmosphere.",
      "I admire how you always find something good even in challenging situations."
    ].sample
  when "Thoughtfulness"
    [
      "Your thoughtful feedback on my draft was exactly what I needed. Thank you for taking the time.",
      "I appreciated how you remembered to include everyone when planning the team event.",
      "The way you consider all perspectives before making decisions shows real thoughtfulness."
    ].sample
  when "Character & Values"
    [
      "Your integrity when handling the sensitive information was admirable.",
      "I respect how you stand by your values even when it's not the easiest path.",
      "Your authenticity in all our interactions makes you someone I truly trust."
    ].sample
  when "Friendship"
    [
      "Your support during my difficult time meant more than you know. You're a true friend.",
      "I value how you always make time to listen when I need someone to talk to.",
      "Thank you for being consistently reliable and trustworthy. Your friendship is important to me."
    ].sample
  else
    # Default case with sufficient length content
    [
      "I really appreciate your contribution to our community. You make a difference every day!",
      "Thank you for being such a positive influence. Your impact doesn't go unnoticed!",
      "I truly admire your approach to challenges. You inspire everyone around you consistently."
    ].sample
  end
end

# ===== MAIN SEEDING LOGIC =====

# Only clear data in development to be safe
if Rails.env.development?
  puts "== Starting seed process in DEVELOPMENT mode =="
  puts "Clearing existing data..."
  Compliment.destroy_all
  MoodEntry.destroy_all
  Community.destroy_all
  Category.destroy_all
  User.where.not(email: "admin@example.com").destroy_all
end

# Step 1: Create Categories first (always need to exist before compliments)
puts "\n== Creating categories =="

# System categories that will be displayed in dropdown menus
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

created_categories = []
system_categories.each do |category_attrs|
  category = Category.create!(category_attrs)
  created_categories << category
  puts "Created system category: #{category.name}"
end

# User-defined categories
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

user_categories.each do |category_attrs|
  category = Category.create!(category_attrs)
  created_categories << category
  puts "Created user category: #{category.name}"
end

puts "Category seeding complete! Created #{created_categories.size} categories."

# Verify categories exist before proceeding
if created_categories.empty?
  puts "Error: No categories were created. Halting seed process."
  exit
end

# Step 2: Create Users
puts "\n== Creating sample users =="

created_users = [] # Initialize array to store user objects

users_data = [
  {
    name: "Alex Johnson",
    username: "alex_j",
    email: "alex@example.com",
    password: "password",
    bio: "Software developer with a passion for building community tools.",
    role: 0 # Regular user
  },
  {
    name: "Sam Rivera",
    username: "sam_r",
    email: "sam@example.com",
    password: "password",
    bio: "UI/UX designer focusing on accessible interfaces.",
    role: 0 # Regular user
  },
  {
    name: "Morgan Chen",
    username: "morgan_c",
    email: "morgan@example.com",
    password: "password",
    bio: "Project manager and team leader. Advocate for recognition and appreciation in the workplace.",
    role: 2 # Admin
  },
  {
    name: "Jordan Taylor",
    username: "jordan_t",
    email: "jordan@example.com",
    password: "password",
    bio: "Marketing specialist and writer. Looking for ways to foster connections through words.",
    role: 0 # Regular user
  },
  {
    name: "Casey Kim",
    username: "casey_k",
    email: "casey@example.com",
    password: "password",
    bio: "Student and volunteer. Interested in how technology can help build supportive communities.",
    role: 0 # Regular user
  },
  {
    name: "Taylor Morgan",
    username: "taylor_m",
    email: "taylor@example.com",
    password: "password",
    bio: "HR professional with expertise in workplace culture.",
    role: 1 # Moderator
  }
]

# Create users and confirm them automatically for development
users_data.each do |user_data|
  # Find or create to avoid duplicates on re-runs
  user = User.find_by(email: user_data[:email])

  if user
    puts "User #{user_data[:email]} already exists, updating attributes"
    user.update!(user_data.except(:email, :password)) # Don't update email/password for existing users
  else
    user = User.create!(user_data)
    puts "Created new user: #{user.name} (#{user.email})"
  end

  # Confirm user if using Devise confirmable
  user.confirm if user.respond_to?(:confirm)

  # Set a current mood for some users
  if rand > 0.3 # 70% chance of having a mood set
    user.update(
      current_mood: rand(1..5),
      mood_updated_at: rand(10).days.ago + rand(24).hours
    )
  end

  created_users << user
end

# Ensure we have users before proceeding
if created_users.size < 2
  puts "Error: Not enough users were created for proper testing. Need at least 2 users."
  exit
end

puts "Successfully created/updated #{created_users.size} users"

# Step 3: Create Communities and Memberships
puts "\n== Creating communities =="

communities_data = [
  {
    name: "Tech Supporters",
    description: "A community for technology professionals to share recognition and support.",
    founder_email: "morgan@example.com" # Look up by email instead of object reference
  },
  {
    name: "Creative Collaborators",
    description: "A space for designers, writers, and artists to appreciate each other's work.",
    founder_email: "sam@example.com"
  }
]

created_communities = []
communities_data.each do |community_data|
  # Get founder separately
  founder_email = community_data.delete(:founder_email)
  founder = User.find_by(email: founder_email)

  # Use a default founder if the specified one doesn't exist
  unless founder
    founder = created_users.first
    puts "Warning: Specified founder #{founder_email} not found, using #{founder.email} instead"
  end

  # Create the community with a clean slug
  community_name = community_data[:name]
  slug = community_name.parameterize

  # Check if community already exists
  existing_community = Community.find_by(slug: slug)
  if existing_community
    puts "Community '#{community_name}' already exists, skipping"
    created_communities << existing_community
    next
  end

  # Create new community
  community = Community.create!(
    name: community_name,
    description: community_data[:description],
    slug: slug,
    creator_id: founder.id
  )

  created_communities << community

  # Add the founder as a member with admin role
  Membership.create!(
    user: founder,
    community: community,
    role: 2 # Admin role
  )

  # Add 2-4 random members to each community
  members_to_add = (created_users - [founder]).sample(rand(2..4))

  members_to_add.each do |user|
    # 80% regular members, 20% moderators
    role = rand < 0.8 ? 0 : 1

    Membership.create!(
      user: user,
      community: community,
      role: role
    )

    puts "Added #{user.name} to #{community.name}"
  end

  puts "Created community: #{community.name} with #{members_to_add.size + 1} members"
end

puts "Successfully created #{created_communities.size} communities"

# Step 4: Create Compliments with proper validations
puts "\n== Creating compliments =="

# Ensure we have proper categories before creating compliments
if created_categories.empty?
  # This is a safety check since we already verified categories at the beginning
  puts "Error: No categories available for compliments. Exiting."
  exit
end

# Create compliments
total_compliments = 30 # Start with a smaller number to test
successful_compliments = 0

total_compliments.times do |i|
  begin
    # Select random sender and recipient (different people)
    sender = created_users.sample
    recipient = (created_users - [sender]).sample

    # Skip if we couldn't get a valid sender-recipient pair
    unless sender && recipient
      puts "Warning: Could not find valid sender and recipient pair, skipping compliment"
      next
    end

    # Select a random category - use the ID explicitly
    category = created_categories.sample

    # Generate compelling content based on category
    content = generate_compliment_content(category.name)

    # Ensure content meets minimum length requirements (5 chars)
    if content.to_s.strip.length < 5
      content = "This is a detailed compliment about your amazing work. Thank you!"
    end

    # 30% chance of being anonymous
    anonymous = rand < 0.3

    # 50% chance of being shared with a community
    share_with_community = rand < 0.5

    # Find communities both users belong to (if any)
    sender_communities = Membership.where(user: sender).pluck(:community_id)
    recipient_communities = Membership.where(user: recipient).pluck(:community_id)
    common_community_ids = sender_communities & recipient_communities

    community_id = if share_with_community && common_community_ids.any?
                     common_community_ids.sample
                   else
                     nil
                   end

    # Create the compliment with all required fields
    compliment = Compliment.new(
      content: content,
      recipient_id: recipient.id,
      sender_id: anonymous ? nil : sender.id,
      anonymous: anonymous,
      status: rand < 0.7 ? 1 : 0, # 70% read, 30% unread
      category_id: category.id,
      community_id: community_id,
      # Other fields
      anonymous_token: anonymous ? SecureRandom.hex(10) : nil
    )

    # Debug output before saving
    puts "Creating compliment: Category ##{category.id} (#{category.name}), " +
         "Content length: #{content.length}, " +
         "Anonymous: #{anonymous}, " +
         "Sender: #{anonymous ? 'Anonymous' : sender.name}, " +
         "Recipient: #{recipient.name}"

    if compliment.save
      successful_compliments += 1
      print "." if successful_compliments % 5 == 0
    else
      puts "Failed to save compliment: #{compliment.errors.full_messages.join(', ')}"
    end

  rescue => e
    puts "Error creating compliment #{i}: #{e.message}"
    puts e.backtrace.first(5) # Show first few lines of backtrace for debugging
  end
end

puts "\nSuccessfully created #{successful_compliments} compliments out of #{total_compliments} attempted"

# Add kudos to some compliments
puts "\n== Adding kudos to compliments =="

Compliment.all.each do |compliment|
  if rand < 0.7 # 70% chance of getting kudos
    kudos_count = rand(1..10)
    compliment.update(kudos_count: kudos_count)
  end
end

puts "Added kudos to #{Compliment.where('kudos_count > 0').count} compliments"

# Print summary
puts "\n== Seed data creation complete! =="
puts "Created/Updated:"
puts "  #{User.count} users"
puts "  #{Community.count} communities"
puts "  #{Membership.count} community memberships"
puts "  #{Category.count} categories"
puts "  #{Compliment.count} compliments"
puts "  #{MoodEntry.count} mood entries"
puts "\nLogin with any of these accounts (password for all: 'password'):"
created_users.first(3).each do |user|
  puts "  - #{user.name} (#{user.email})"
end
