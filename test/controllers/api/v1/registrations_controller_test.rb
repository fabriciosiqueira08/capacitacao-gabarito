require "test_helper"

class Api::V1::RegistrationsControllerTest < ActionDispatch::IntegrationTest
  PARAMS = {
    name: "Carla Dias",
    email: "carla@aluno.ufop.edu.br",
    password: "Automic@2026",
    confirm_password: "Automic@2026",
    course: "Engenharia Civil",
    matricula: "2015555",
    check_terms_use: true
  }.freeze

  test "cadastra e dispara o e-mail de ativação" do
    assert_difference "User.count", 1 do
      post "/api/v1/registrations", params: PARAMS, as: :json
    end

    assert_response :created
    assert_equal "carla@aluno.ufop.edu.br", response.parsed_body.dig("user", "email")
    assert_equal false, response.parsed_body.dig("user", "email_verified")
    assert_equal 1, ActionMailer::Base.deliveries.size
  end

  test "nunca devolve o digest da senha" do
    post "/api/v1/registrations", params: PARAMS, as: :json

    assert_not_includes response.parsed_body["user"].keys, "password_digest"
  end

  test "recusa senha fora da política" do
    post "/api/v1/registrations", params: PARAMS.merge(password: "abc", confirm_password: "abc"), as: :json

    assert_response :unprocessable_content
    assert_equal "validation_failed", response.parsed_body.dig("error", "code")
    campos = response.parsed_body.dig("error", "details").map { |d| d["field"] }
    assert_includes campos, "password"
  end

  test "recusa confirmação de senha diferente" do
    post "/api/v1/registrations", params: PARAMS.merge(confirm_password: "Outra@2026"), as: :json

    assert_response :unprocessable_content
    campos = response.parsed_body.dig("error", "details").map { |d| d["field"] }
    assert_includes campos, "confirm_password"
  end

  test "exige o aceite dos termos" do
    post "/api/v1/registrations", params: PARAMS.merge(check_terms_use: false), as: :json

    assert_response :unprocessable_content
  end

  test "não revela que o e-mail já existe" do
    post "/api/v1/registrations", params: PARAMS.merge(email: users(:ana).email), as: :json

    assert_response :unprocessable_content
    detalhe = response.parsed_body.dig("error", "details").first
    assert_equal "base", detalhe["field"]
    assert_equal Users::Register::REGISTRATION_FAILED_MESSAGE, detalhe["message"]
  end

  test "recusa requisição sem os campos obrigatórios" do
    post "/api/v1/registrations", params: { email: "x@y.com" }, as: :json

    assert_response :bad_request
  end
end
