# Dados de desenvolvimento. Rode com: bin/rails db:seed
#
# find_or_initialize_by deixa o arquivo idempotente: rodar duas vezes não
# duplica ninguém nem estoura no índice único.

usuario = User.find_or_initialize_by(email: "ana@aluno.ufop.edu.br")
usuario.assign_attributes(
  name: "Ana Souza",
  password: "Automic@2026",
  course: "Engenharia de Controle e Automação",
  matricula: "2011234",
  terms_accepted_at: Time.current,
  # Já verificada: sem isso o login recusa (ver Auth::Login, na Aula 3).
  email_verified_at: Time.current
)
usuario.save!

puts "Seed pronto. Login: ana@aluno.ufop.edu.br / Automic@2026"
