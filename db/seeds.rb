# Creates the single user this application has, from the credentials of the
# environment it runs in — so no password is typed into a console or written
# into a tracked file. Add one with:
#
#   bin/rails credentials:edit --environment development
#
#   user:
#     email_address: you@example.com
#     password: ...
#
# Idempotent: running it again on a database that already has the user is a
# no-op, so it is safe on every environment and as often as you like.
user = Rails.application.credentials.user

if user.blank?
  puts "No user in the #{Rails.env} credentials — skipping. See docs/deployment.md."
else
  record = User.find_or_initialize_by(email_address: user.email_address)
  record.password = user.password unless record.authenticate(user.password)

  if record.changed?
    record.save!
    puts "Seeded #{record.email_address}."
  else
    puts "#{record.email_address} already seeded."
  end
end
