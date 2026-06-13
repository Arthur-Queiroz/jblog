# Nunca criar usuários com credenciais hardcoded: este arquivo é público no git e
# roda em produção no primeiro db:prepare. Usuário admin de produção se cria via
# console (bin/kamal console → User.create!).
if Rails.env.development?
  User.find_or_create_by!(email_address: "dev@localhost") do |user|
    user.password = "senha-dev-local"
    user.password_confirmation = "senha-dev-local"
  end
end
