# Confirmação de e-mail por código de 6 dígitos.
#
# Um concern é um módulo Ruby que a classe inclui — o mixin da Aula 1. Sem ele,
# `User` acumularia esta lógica, a de recuperação de senha e todo o resto num
# arquivo só.
#
# O código é guardado como digest bcrypt, exatamente como a senha: quem lê o
# banco não consegue confirmar a conta de ninguém.
module EmailVerifiable
  extend ActiveSupport::Concern

  CODE_TTL = 15.minutes
  RESEND_COOLDOWN = 1.minute

  included do
    scope :email_verified, -> { where.not(email_verified_at: nil) }
  end

  def email_verified?
    email_verified_at.present?
  end

  # Gera o código, guarda o digest e devolve o código em texto — que só existe
  # nesta chamada, para ser enviado por e-mail. Depois disso, some.
  def issue_email_verification_code!
    code = format("%06d", SecureRandom.random_number(1_000_000))

    update!(
      email_verification_code_digest: BCrypt::Password.create(code),
      email_verification_expires_at: CODE_TTL.from_now,
      email_verification_sent_at: Time.current
    )

    code
  end

  # Confirma a conta se o código bater. O `!` avisa que isto grava no banco.
  def verify_email_code!(submitted_code)
    return false if email_verified?
    return false if verification_expired?
    return false if email_verification_code_digest.blank?
    return false unless BCrypt::Password.new(email_verification_code_digest)
                                        .is_password?(submitted_code.to_s.strip)

    update!(
      email_verified_at: Time.current,
      # Consome o código: ele não vale uma segunda vez.
      email_verification_code_digest: nil,
      email_verification_expires_at: nil
    )

    true
  end

  def verification_expired?
    email_verification_expires_at.blank? || email_verification_expires_at < Time.current
  end

  # Impede que alguém peça código em loop e use o servidor de e-mail como spam.
  def resend_verification_allowed?
    email_verification_sent_at.blank? || email_verification_sent_at < RESEND_COOLDOWN.ago
  end
end
