require "test_helper"

class Api::V1::SessionsControllerTest < ActionDispatch::IntegrationTest
  test "mobile recebe o token no cabeçalho Authorization" do
    post "/api/v1/sessions",
         params: { email: users(:ana).email, password: PASSWORD, client: "mobile" },
         as: :json

    assert_response :ok
    assert_match(/\ABearer .+\z/, response.headers["Authorization"])
    assert_equal users(:ana).email, response.parsed_body.dig("user", "email")
  end

  test "web recebe o token num cookie httpOnly" do
    post "/api/v1/sessions",
         params: { email: users(:ana).email, password: PASSWORD, client: "web" },
         as: :json

    assert_response :ok
    assert_nil response.headers["Authorization"]
    assert_match(/HttpOnly/i, response.headers["Set-Cookie"].to_s)
  end

  test "recusa senha errada com 401 e mensagem genérica" do
    post "/api/v1/sessions",
         params: { email: users(:ana).email, password: "errada", client: "mobile" },
         as: :json

    assert_response :unauthorized
    assert_equal "invalid_credentials", response.parsed_body.dig("error", "code")
  end

  test "e-mail inexistente responde igual a senha errada" do
    post "/api/v1/sessions",
         params: { email: "ninguem@ufop.br", password: PASSWORD, client: "mobile" },
         as: :json

    assert_response :unauthorized
    assert_equal "invalid_credentials", response.parsed_body.dig("error", "code")
  end

  test "recusa conta sem e-mail confirmado com 403" do
    post "/api/v1/sessions",
         params: { email: users(:bruno).email, password: PASSWORD, client: "mobile" },
         as: :json

    assert_response :forbidden
    assert_equal "email_unverified", response.parsed_body.dig("error", "code")
  end

  test "exige client mobile ou web" do
    post "/api/v1/sessions",
         params: { email: users(:ana).email, password: PASSWORD, client: "desktop" },
         as: :json

    assert_response :unprocessable_content
  end

  test "logout revoga o token apresentado" do
    token = login_as(users(:ana))

    get "/api/v1/me", headers: auth_headers(token)
    assert_response :ok

    delete "/api/v1/sessions", headers: auth_headers(token)
    assert_response :ok

    # É este assert que prova que o logout serve para alguma coisa: sem a
    # denylist, o token continuaria valendo por 24h.
    get "/api/v1/me", headers: auth_headers(token)
    assert_response :unauthorized
  end

  test "logout de um dispositivo não derruba os outros" do
    token_celular = login_as(users(:ana))
    token_notebook = login_as(users(:ana))

    delete "/api/v1/sessions", headers: auth_headers(token_celular)

    get "/api/v1/me", headers: auth_headers(token_notebook)
    assert_response :ok
  end

  test "logout sem token responde 401" do
    delete "/api/v1/sessions"

    assert_response :unauthorized
  end
end
