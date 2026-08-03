# Recuperação de senha por código de 6 dígitos.
#
# Separado de EmailVerifiable de propósito: os dois fluxos podem estar em
# andamento ao mesmo tempo, então cada um tem as suas colunas.
module PasswordResettable
  extend ActiveSupport::Concern

  CODE_TTL = 15.minutes
  REQUEST_COOLDOWN = 1.minute

  def issue_password_reset_code!
    code = format("%06d", SecureRandom.random_number(1_000_000))

    update!(
      password_reset_code_digest: BCrypt::Password.create(code),
      password_reset_expires_at: CODE_TTL.from_now,
      password_reset_sent_at: Time.current
    )

    code
  end

  # Só confere. Quem consome o código é Users::CompletePasswordReset, dentro da
  # transação que também troca a senha — para o código não ser gasto à toa se a
  # nova senha for recusada pela política.
  def verify_password_reset_code!(submitted_code)
    return false if password_reset_expired?
    return false if password_reset_code_digest.blank?

    BCrypt::Password.new(password_reset_code_digest).is_password?(submitted_code.to_s.strip)
  end

  def clear_password_reset_code!
    update!(
      password_reset_code_digest: nil,
      password_reset_expires_at: nil,
      password_reset_sent_at: nil
    )
  end

  def password_reset_expired?
    password_reset_expires_at.blank? || password_reset_expires_at < Time.current
  end

  def password_reset_request_allowed?
    password_reset_sent_at.blank? || password_reset_sent_at < REQUEST_COOLDOWN.ago
  end
end
