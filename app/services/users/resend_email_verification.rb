module Users
  # Caso de uso: POST /api/v1/email_verifications/resend
  #
  # Sempre 200 com a mesma mensagem: e-mail inexistente, já verificado ou em
  # cooldown são indistinguíveis para quem chama.
  class ResendEmailVerification
    Result = Struct.new(:success?, :message, keyword_init: true)

    GENERIC_MESSAGE = "Se a conta existir e ainda não estiver ativa, enviamos um novo código.".freeze

    def self.call(email:)
      new(email:).call
    end

    def initialize(email:)
      @email = email
    end

    def call
      user = User.find_by(email: User.normalize_email(@email))

      if user && !user.email_verified? && user.resend_verification_allowed?
        SendEmailVerification.call(user:)
      end

      Result.new(success?: true, message: GENERIC_MESSAGE)
    end
  end
end
