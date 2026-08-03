# Atalhos usados pelos testes de controller.
module AuthTestHelper
  PASSWORD = "Automic@2026".freeze

  # Faz login de verdade e devolve o token do cabeçalho — o mesmo caminho que o
  # app faz. Testar pelo caminho real pega bug que um token forjado esconderia.
  def login_as(user, password: PASSWORD)
    post "/api/v1/sessions",
         params: { email: user.email, password:, client: "mobile" },
         as: :json

    response.headers["Authorization"].to_s.delete_prefix("Bearer ")
  end

  def auth_headers(token)
    { "Authorization" => "Bearer #{token}" }
  end

  # Pega o código de 6 dígitos do último e-mail enviado.
  def codigo_do_ultimo_email
    ActionMailer::Base.deliveries.last.body.to_s[/\b\d{6}\b/]
  end
end
