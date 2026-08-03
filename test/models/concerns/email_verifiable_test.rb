require "test_helper"

class EmailVerifiableTest < ActiveSupport::TestCase
  setup { @user = users(:bruno) }

  test "começa sem verificação" do
    assert_not @user.email_verified?
  end

  test "emite um código de 6 dígitos e guarda só o digest" do
    code = @user.issue_email_verification_code!

    assert_match(/\A\d{6}\z/, code)
    assert_not_equal code, @user.email_verification_code_digest
    assert @user.email_verification_expires_at > Time.current
  end

  test "confirma com o código certo e consome ele" do
    code = @user.issue_email_verification_code!

    assert @user.verify_email_code!(code)
    assert @user.email_verified?
    assert_nil @user.email_verification_code_digest
    # O mesmo código não vale duas vezes.
    assert_not @user.verify_email_code!(code)
  end

  test "recusa código errado" do
    @user.issue_email_verification_code!

    assert_not @user.verify_email_code!("000000")
    assert_not @user.email_verified?
  end

  test "recusa código expirado" do
    code = @user.issue_email_verification_code!
    @user.update!(email_verification_expires_at: 1.second.ago)

    assert_not @user.verify_email_code!(code)
  end

  test "segura o reenvio durante o cooldown" do
    @user.issue_email_verification_code!
    assert_not @user.resend_verification_allowed?

    @user.update!(email_verification_sent_at: 2.minutes.ago)
    assert @user.resend_verification_allowed?
  end
end
