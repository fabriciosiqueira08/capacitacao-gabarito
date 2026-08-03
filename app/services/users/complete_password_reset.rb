module Users
  # Caso de uso: POST /api/v1/password_resets/confirm
  #
  # Valida o código, aplica a política de senha, troca a senha, derruba todas as
  # sessões ativas e consome o código — tudo numa transação só.
  class CompletePasswordReset
    Result = Struct.new(:success?, :message, :errors, keyword_init: true)

    SUCCESS_MESSAGE = "Senha redefinida com sucesso. Você já pode entrar.".freeze
    CODE_INVALID = [ { field: "code", message: "é inválido" } ].freeze
    CODE_EXPIRED = [ { field: "code", message: "expirou. Solicite um novo código." } ].freeze

    def self.call(email:, code:, password:, confirm_password:)
      new(email:, code:, password:, confirm_password:).call
    end

    def initialize(email:, code:, password:, confirm_password:)
      @email = email
      @code = code
      @password = password
      @confirm_password = confirm_password
    end

    def call
      erros = password_errors
      return failure(erros) if erros.any?

      user = User.find_by(email: User.normalize_email(@email))

      # Sem código ativo (e-mail desconhecido, não verificado, nunca solicitado
      # ou já usado) responde igual a código errado.
      return failure(CODE_INVALID) unless user&.email_verified? && user.password_reset_code_digest?
      return failure(CODE_EXPIRED) if user.password_reset_expired?
      return failure(CODE_INVALID) unless user.verify_password_reset_code!(@code)

      user.password = @password
      return failure(user.errors.map { |e| { field: e.attribute.to_s, message: e.message } }) unless user.valid?

      # Atômico: ou as três coisas acontecem, ou nenhuma. Sem isso dá para
      # trocar a senha e o código continuar valendo se o passo seguinte falhar.
      User.transaction do
        user.save!
        user.invalidate_sessions!
        user.clear_password_reset_code!
      end

      Result.new(success?: true, message: SUCCESS_MESSAGE)
    end

    private

    def password_errors
      errors = PasswordPolicyValidator.validate(@password).map do |message|
        { field: "password", message: }
      end

      errors << { field: "confirm_password", message: "não confere com a senha" } if @password != @confirm_password

      errors
    end

    def failure(errors)
      Result.new(success?: false, errors:)
    end
  end
end
