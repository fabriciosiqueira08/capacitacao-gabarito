source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.1.3", ">= 8.1.3.1"
# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"

# Hash de senha e dos códigos de 6 dígitos. Habilita o has_secure_password.
gem "bcrypt", "~> 3.1.7"

# Emite e valida os tokens de sessão (Aula 3).
gem "jwt", "~> 3.2"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Use the database-backed adapters for Rails.cache and Active Job
gem "solid_cache"
gem "solid_queue"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem "kamal", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false

# Libera o painel web (outra origem) a chamar esta API. O app nativo não passa por CORS.
gem "rack-cors"

group :development do
  # Sem SMTP em dev: o e-mail é guardado e servido numa caixa de entrada em
  # http://localhost:3000/letter_opener, em vez de sair pela rede.
  #
  # É a versão "web" de propósito. O letter_opener original tenta abrir o
  # arquivo no navegador DA MÁQUINA, e num WSL2, num container ou num
  # servidor sem tela não existe navegador para abrir — o envio falhava e
  # derrubava o cadastro. Aqui não há nada a abrir: é uma rota da própria
  # aplicação, e funciona igual em qualquer sistema.
  gem "letter_opener_web", "~> 3.0"
end

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  # Audits gems for known security defects (use config/bundler-audit.yml to ignore issues)
  gem "bundler-audit", require: false

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false
end
