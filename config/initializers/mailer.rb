# Action Mailer configurado por variáveis de ambiente.
#
# Em desenvolvimento não há SMTP: o letter_opener grava o e-mail em
# tmp/letter_opener/ e tenta abrir no navegador.
# Em produção, SMTP_ADDRESS e companhia vêm dos secrets do Kamal (Aula 4).

Rails.application.configure do
  config.action_mailer.default_options = {
    from: ENV.fetch("MAILER_FROM", "Automic Auth API <noreply@automic.local>")
  }

  if ENV["SMTP_ADDRESS"].present?
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      address: ENV.fetch("SMTP_ADDRESS"),
      port: ENV.fetch("SMTP_PORT", 587).to_i,
      user_name: ENV.fetch("SMTP_USERNAME", nil),
      password: ENV.fetch("SMTP_PASSWORD", nil),
      authentication: ENV.fetch("SMTP_AUTHENTICATION", "plain"),
      enable_starttls_auto: ActiveModel::Type::Boolean.new.cast(
        ENV.fetch("SMTP_ENABLE_STARTTLS_AUTO", true)
      )
    }.compact
    # Estoura se o envio falhar: quem trata é o rescue dos services.
    config.action_mailer.raise_delivery_errors = true
  elsif Rails.env.development?
    config.action_mailer.delivery_method = :letter_opener
    config.action_mailer.perform_deliveries = true
    # `false` aqui, e é de propósito que seja o oposto do ramo de cima.
    #
    # O letter_opener grava o e-mail em disco e SÓ DEPOIS tenta abrir o
    # navegador. Num ambiente sem navegador — WSL2, container, servidor sem
    # tela — essa segunda parte estoura. Com `true`, a exceção subiria até o
    # rescue do service, que devolveria falha, e o cadastro responderia 422
    # com o usuário já gravado no banco: um beco sem saída.
    #
    # O e-mail está escrito em tmp/letter_opener/ de qualquer jeito, então não
    # conseguir abrir a janela não é motivo para derrubar o fluxo.
    config.action_mailer.raise_delivery_errors = false
  end
end
