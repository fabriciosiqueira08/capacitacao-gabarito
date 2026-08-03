module Users
  # Emite o código e manda o e-mail de ativação.
  #
  # `deliver_now` e não `deliver_later` de propósito: numa fila, o código de 6
  # dígitos ficaria gravado em texto na tabela de jobs. O preço é a requisição
  # esperar o SMTP — por isso o rescue, para uma falha de envio não virar 500.
  class SendEmailVerification
    Result = Struct.new(:success?, :user, :errors, :error_code, keyword_init: true)

    def self.call(user:)
      new(user:).call
    end

    def initialize(user:)
      @user = user
    end

    def call
      return Result.new(success?: true, user: @user) if @user.email_verified?

      code = @user.issue_email_verification_code!
      UserMailer.email_verification(@user, code).deliver_now

      Result.new(success?: true, user: @user)
    rescue StandardError => e
      Rails.error.report(e, handled: true, source: "SendEmailVerification")
      Result.new(
        success?: false,
        error_code: "delivery_failed",
        errors: [ { field: "email", message: "não foi possível enviar o e-mail de verificação" } ]
      )
    end
  end
end
