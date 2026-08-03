require "test_helper"

class Api::V1::EmailVerificationsControllerTest < ActionDispatch::IntegrationTest
  test "confirma a conta com o código certo e libera o login" do
    codigo = users(:bruno).issue_email_verification_code!

    post "/api/v1/email_verifications/confirm",
         params: { email: users(:bruno).email, code: codigo },
         as: :json

    assert_response :ok
    assert users(:bruno).reload.email_verified?

    post "/api/v1/sessions",
         params: { email: users(:bruno).email, password: PASSWORD, client: "mobile" },
         as: :json
    assert_response :ok
  end

  test "recusa código errado" do
    users(:bruno).issue_email_verification_code!

    post "/api/v1/email_verifications/confirm",
         params: { email: users(:bruno).email, code: "000000" },
         as: :json

    assert_response :unprocessable_content
    assert_not users(:bruno).reload.email_verified?
  end

  test "e-mail desconhecido responde igual a código errado" do
    post "/api/v1/email_verifications/confirm",
         params: { email: "ninguem@ufop.br", code: "123456" },
         as: :json

    assert_response :unprocessable_content
  end

  test "reenvia o código para conta pendente" do
    post "/api/v1/email_verifications/resend", params: { email: users(:bruno).email }, as: :json

    assert_response :ok
    assert_equal 1, ActionMailer::Base.deliveries.size
  end

  test "não reenvia para conta já verificada, mas responde igual" do
    post "/api/v1/email_verifications/resend", params: { email: users(:ana).email }, as: :json

    assert_response :ok
    assert_empty ActionMailer::Base.deliveries
  end
end
