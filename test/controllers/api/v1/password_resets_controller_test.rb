require "test_helper"

class Api::V1::PasswordResetsControllerTest < ActionDispatch::IntegrationTest
  NOVA_SENHA = "NovaSenha@9".freeze

  def pedir_codigo(user)
    post "/api/v1/password_resets/request", params: { email: user.email }, as: :json
    codigo_do_ultimo_email
  end

  test "envia o código para conta verificada" do
    post "/api/v1/password_resets/request", params: { email: users(:ana).email }, as: :json

    assert_response :ok
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_match(/\A\d{6}\z/, codigo_do_ultimo_email)
  end

  test "responde igual para e-mail inexistente, sem enviar nada" do
    post "/api/v1/password_resets/request", params: { email: "ninguem@ufop.br" }, as: :json

    assert_response :ok
    assert_equal Users::RequestPasswordReset::GENERIC_MESSAGE, response.parsed_body["message"]
    assert_empty ActionMailer::Base.deliveries
  end

  test "não envia código para conta ainda não verificada" do
    post "/api/v1/password_resets/request", params: { email: users(:bruno).email }, as: :json

    assert_response :ok
    assert_empty ActionMailer::Base.deliveries
  end

  test "segura uma segunda solicitação dentro do cooldown" do
    2.times do
      post "/api/v1/password_resets/request", params: { email: users(:ana).email }, as: :json
    end

    assert_equal 1, ActionMailer::Base.deliveries.size
  end

  test "troca a senha com o código certo" do
    codigo = pedir_codigo(users(:ana))

    post "/api/v1/password_resets/confirm",
         params: {
           email: users(:ana).email, code: codigo,
           password: NOVA_SENHA, confirm_password: NOVA_SENHA
         },
         as: :json

    assert_response :ok
    assert users(:ana).reload.authenticate(NOVA_SENHA)
  end

  test "derruba as sessões ativas ao trocar a senha" do
    token = login_as(users(:ana))
    codigo = pedir_codigo(users(:ana))

    post "/api/v1/password_resets/confirm",
         params: {
           email: users(:ana).email, code: codigo,
           password: NOVA_SENHA, confirm_password: NOVA_SENHA
         },
         as: :json

    # Quem tinha invadido a conta perde o acesso na hora — é o token_version.
    get "/api/v1/me", headers: auth_headers(token)
    assert_response :unauthorized
  end

  test "o código só vale uma vez" do
    codigo = pedir_codigo(users(:ana))
    params = {
      email: users(:ana).email, code: codigo,
      password: NOVA_SENHA, confirm_password: NOVA_SENHA
    }

    post "/api/v1/password_resets/confirm", params:, as: :json
    assert_response :ok

    post "/api/v1/password_resets/confirm", params:, as: :json
    assert_response :unprocessable_content
  end

  test "recusa código errado" do
    pedir_codigo(users(:ana))

    post "/api/v1/password_resets/confirm",
         params: {
           email: users(:ana).email, code: "000000",
           password: NOVA_SENHA, confirm_password: NOVA_SENHA
         },
         as: :json

    assert_response :unprocessable_content
    assert_not users(:ana).reload.authenticate(NOVA_SENHA)
  end

  test "recusa código expirado" do
    codigo = pedir_codigo(users(:ana))
    users(:ana).update!(password_reset_expires_at: 1.second.ago)

    post "/api/v1/password_resets/confirm",
         params: {
           email: users(:ana).email, code: codigo,
           password: NOVA_SENHA, confirm_password: NOVA_SENHA
         },
         as: :json

    assert_response :unprocessable_content
  end

  test "aplica a política na senha nova" do
    codigo = pedir_codigo(users(:ana))

    post "/api/v1/password_resets/confirm",
         params: { email: users(:ana).email, code: codigo, password: "abc", confirm_password: "abc" },
         as: :json

    assert_response :unprocessable_content
    campos = response.parsed_body.dig("error", "details").map { |d| d["field"] }
    assert_includes campos, "password"
  end

  test "e-mail desconhecido no confirm responde igual a código errado" do
    post "/api/v1/password_resets/confirm",
         params: {
           email: "ninguem@ufop.br", code: "123456",
           password: NOVA_SENHA, confirm_password: NOVA_SENHA
         },
         as: :json

    assert_response :unprocessable_content
    assert_equal "code", response.parsed_body.dig("error", "details").first["field"]
  end
end
