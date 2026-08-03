class ApplicationMailer < ActionMailer::Base
  # O remetente real vem de MAILER_FROM (ver config/initializers/mailer.rb).
  layout "mailer"
end
