User.find_or_create_by!(email_address: "admin@jblog.com") do |user|
  user.password = "Queiroz05@"
  user.password_confirmation = "Queiroz05@"
end
