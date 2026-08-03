module Users
  # Caso de uso: POST /api/v1/registrations
  #
  # Está fora do controller porque cadastro não é "salvar um formulário": valida
  # campo a campo, confere a confirmação de senha, cria o usuário e dispara o
  # e-mail. Controller recebe requisição e devolve resposta; a regra é aqui.
  class Register
    Result = Struct.new(:success?, :user, :errors, keyword_init: true)

    REQUIRED_FIELDS = %i[name email password confirm_password course matricula check_terms_use].freeze
    # Mensagem única para e-mail e matrícula já cadastrados: dizer "este e-mail
    # já existe" transforma o cadastro num verificador de quem tem conta.
    REGISTRATION_FAILED_MESSAGE =
      "Não foi possível concluir o cadastro. Verifique os dados e tente novamente.".freeze

    def self.call(attributes = {})
      new(attributes).call
    end

    def initialize(attributes = {})
      @attributes = attributes.to_h.symbolize_keys
    end

    def call
      errors = missing_field_errors + rule_errors
      return Result.new(success?: false, errors:) if errors.any?

      user = build_user

      return Result.new(success?: false, errors: model_errors(user)) unless user.save

      envio = SendEmailVerification.call(user:)
      return Result.new(success?: false, errors: envio.errors) unless envio.success?

      Result.new(success?: true, user:)
    end

    private

    def build_user
      User.new(
        name: User.normalize_name(@attributes[:name]),
        email: User.normalize_email(@attributes[:email]),
        password: @attributes[:password],
        course: @attributes[:course].to_s.strip,
        matricula: User.normalize_matricula(@attributes[:matricula]),
        terms_accepted_at: Time.current
      )
    end

    def missing_field_errors
      REQUIRED_FIELDS.filter_map do |field|
        next if presente?(field)

        { field: field.to_s, message: "não pode ficar em branco" }
      end
    end

    def presente?(field)
      valor = @attributes[field]
      return false if valor.nil?
      # O aceite dos termos é booleano: `false` está presente, só não é válido.
      return true if field == :check_terms_use

      !valor.to_s.strip.empty?
    end

    def rule_errors
      errors = []

      unless ActiveModel::Type::Boolean.new.cast(@attributes[:check_terms_use])
        errors << { field: "check_terms_use", message: "deve ser aceito" }
      end

      PasswordPolicyValidator.validate(@attributes[:password]).each do |message|
        errors << { field: "password", message: }
      end

      if @attributes[:password] != @attributes[:confirm_password]
        errors << { field: "confirm_password", message: "não confere com a senha" }
      end

      errors
    end

    def model_errors(user)
      return [ { field: "base", message: REGISTRATION_FAILED_MESSAGE } ] if user.errors.any? { |e| e.type == :taken }

      user.errors.map { |e| { field: e.attribute.to_s, message: e.message } }
    end
  end
end
