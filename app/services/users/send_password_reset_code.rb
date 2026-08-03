module Users
  # Emite o código de recuperação e manda o e-mail.
  class SendPasswordResetCode
    Result = Struct.new(:success?, :user, :error_code, keyword_init: true)

    def self.call(user:)
      new(user:).call
    end

    def initialize(user:)
      @user = user
    end

    def call
      code = @user.issue_password_reset_code!
      UserMailer.password_reset(@user, code).deliver_now

      Result.new(success?: true, user: @user)
    rescue StandardError => e
      # Falha de SMTP não pode virar 500 nem mudar a resposta: o cliente recebe
      # a mesma mensagem genérica de sempre. Quem precisa saber é o log.
      Rails.error.report(e, handled: true, source: "SendPasswordResetCode")
      Result.new(success?: false, error_code: "delivery_failed")
    end
  end
end
