module Users
  # Caso de uso: POST /api/v1/password_resets/request
  #
  # SEMPRE responde 200 com a mesma mensagem. E-mail inexistente, não verificado,
  # em cooldown ou falha de SMTP são indistinguíveis para quem chama — senão
  # esta rota vira um verificador de quem tem conta no sistema.
  class RequestPasswordReset
    Result = Struct.new(:success?, :message, keyword_init: true)

    GENERIC_MESSAGE = "Se o e-mail estiver cadastrado, enviamos um código para redefinir sua senha.".freeze

    def self.call(email:)
      new(email:).call
    end

    def initialize(email:)
      @email = email
    end

    def call
      user = User.find_by(email: User.normalize_email(@email))

      # Só conta verificada recebe código: senão dá para sequestrar um cadastro
      # feito com o e-mail de outra pessoa antes de ela confirmar.
      if user&.email_verified? && user.password_reset_request_allowed?
        SendPasswordResetCode.call(user:)
      end

      Result.new(success?: true, message: GENERIC_MESSAGE)
    end
  end
end
