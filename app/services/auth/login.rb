module Auth
  # Caso de uso do login: valida credenciais e conta ativa.
  #
  # Não emite token nem mexe em cookie — isso é decisão do controller, que sabe
  # se o cliente é o app ou o navegador.
  class Login
    Result = Struct.new(:success?, :user, :error_code, keyword_init: true)

    def self.call(email:, password:)
      new(email:, password:).call
    end

    def initialize(email:, password:)
      @email = email
      @password = password
    end

    def call
      user = User.authenticate_by_email(@email, @password)

      # Uma mensagem só para e-mail inexistente e senha errada: dizer qual dos
      # dois falhou entrega quem tem conta no sistema.
      return Result.new(success?: false, error_code: "invalid_credentials") if user.nil?

      return Result.new(success?: false, error_code: "email_unverified") unless user.email_verified?

      Result.new(success?: true, user:)
    end
  end
end
