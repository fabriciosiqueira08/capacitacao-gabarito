require "test_helper"

class Api::V1::MeControllerTest < ActionDispatch::IntegrationTest
  test "devolve o usuário do token" do
    token = login_as(users(:ana))

    get "/api/v1/me", headers: auth_headers(token)

    assert_response :ok
    assert_equal users(:ana).email, response.parsed_body.dig("user", "email")
  end

  test "aceita o cookie do cliente web" do
    post "/api/v1/sessions",
         params: { email: users(:ana).email, password: PASSWORD, client: "web" },
         as: :json

    get "/api/v1/me"

    assert_response :ok
  end

  test "recusa sem token" do
    get "/api/v1/me"

    assert_response :unauthorized
    assert_equal "unauthorized", response.parsed_body.dig("error", "code")
  end

  test "recusa token adulterado" do
    token = login_as(users(:ana))
    adulterado = "#{token[0..-3]}xx"

    get "/api/v1/me", headers: auth_headers(adulterado)

    assert_response :unauthorized
  end

  test "recusa token assinado com outro segredo" do
    forjado = JWT.encode(
      { sub: users(:ana).id, ver: 0, jti: SecureRandom.uuid, exp: 1.hour.from_now.to_i },
      "segredo-do-atacante",
      "HS256"
    )

    get "/api/v1/me", headers: auth_headers(forjado)

    assert_response :unauthorized
  end
end
