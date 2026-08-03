require "test_helper"

class PasswordResettableTest < ActiveSupport::TestCase
  setup { @user = users(:ana) }

  test "emite um código de 6 dígitos e guarda só o digest" do
    code = @user.issue_password_reset_code!

    assert_match(/\A\d{6}\z/, code)
    assert_not_equal code, @user.password_reset_code_digest
  end

  test "confere o código certo sem consumir" do
    code = @user.issue_password_reset_code!

    assert @user.verify_password_reset_code!(code)
    # Conferir não apaga: quem consome é o service, dentro da transação.
    assert @user.verify_password_reset_code!(code)
  end

  test "recusa código errado ou expirado" do
    code = @user.issue_password_reset_code!
    assert_not @user.verify_password_reset_code!("000000")

    @user.update!(password_reset_expires_at: 1.second.ago)
    assert_not @user.verify_password_reset_code!(code)
  end

  test "limpa o código" do
    @user.issue_password_reset_code!
    @user.clear_password_reset_code!

    assert_nil @user.password_reset_code_digest
    assert_nil @user.password_reset_expires_at
  end

  test "segura nova solicitação durante o cooldown" do
    @user.issue_password_reset_code!
    assert_not @user.password_reset_request_allowed?

    @user.update!(password_reset_sent_at: 2.minutes.ago)
    assert @user.password_reset_request_allowed?
  end
end
