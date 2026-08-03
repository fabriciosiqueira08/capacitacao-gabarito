require "test_helper"

class Api::V1::Me::LoginEventsControllerTest < ActionDispatch::IntegrationTest
  test "o login grava um evento" do
    assert_difference "LoginEvent.count", 1 do
      login_as(users(:ana))
    end

    assert_equal "mobile", users(:ana).login_events.recentes.first.client
  end

  test "devolve os acessos do próprio usuário" do
    token = login_as(users(:ana))

    get "/api/v1/me/login_events", headers: auth_headers(token)

    assert_response :ok
    assert_equal 1, response.parsed_body["login_events"].size
    assert_equal "mobile", response.parsed_body["login_events"].first["client"]
  end

  test "não mostra o acesso de outro usuário" do
    users(:bruno).login_events.create!(client: "web", occurred_at: Time.current)
    token = login_as(users(:ana))

    get "/api/v1/me/login_events", headers: auth_headers(token)

    clientes = response.parsed_body["login_events"].map { |e| e["client"] }
    assert_equal [ "mobile" ], clientes
  end

  test "recusa sem token" do
    get "/api/v1/me/login_events"

    assert_response :unauthorized
  end
end
