# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Single v1 user — credentials live in config/credentials.yml.enc (seed_user:).
if (seed = Rails.application.credentials.seed_user)
  User.find_or_create_by!(email_address: seed[:email]) do |user|
    user.password = seed[:password]
  end
  puts "Seeded user #{seed[:email]}"
else
  warn "No seed_user in credentials — skipping user seed"
end
