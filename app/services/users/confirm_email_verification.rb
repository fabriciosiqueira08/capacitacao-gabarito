module Users
  # Caso de uso: POST /api/v1/email_verifications/confirm
  class ConfirmEmailVerification
    Result = Struct.new(:success?, :user, :errors, keyword_init: true)

    CODE_INVALID = [ { field: "code", message: "é inválido ou expirou" } ].freeze

    def self.call(email:, code:)
      new(email:, code:).call
    end

    def initialize(email:, code:)
      @email = email
      @code = code
    end

    def call
      user = User.find_by(email: User.normalize_email(@email))

      # E-mail desconhecido e código errado devolvem a mesma coisa.
      return Result.new(success?: false, errors: CODE_INVALID) if user.nil?
      return Result.new(success?: true, user:) if user.email_verified?
      return Result.new(success?: false, errors: CODE_INVALID) unless user.verify_email_code!(@code)

      Result.new(success?: true, user:)
    end
  end
end
