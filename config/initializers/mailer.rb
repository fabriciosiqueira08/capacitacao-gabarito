# Action Mailer configurado por variáveis de ambiente.
#
# Em desenvolvimento não há SMTP: o letter_opener_web guarda o e-mail e o
# serve numa caixa de entrada em http://localhost:3000/letter_opener.
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
    # Guarda o e-mail e o serve em /letter_opener. Nada sai pela rede, e
    # nada precisa abrir janela nenhuma: é uma rota da própria aplicação.
    config.action_mailer.delivery_method = :letter_opener_web
    config.action_mailer.perform_deliveries = true
    # `false` aqui, e é de propósito que seja o oposto do ramo de cima. Em
    # desenvolvimento, uma falha ao guardar o e-mail não deve derrubar o
    # cadastro do aluno — o que importa é a rota ter respondido.
    config.action_mailer.raise_delivery_errors = false
  end
end
