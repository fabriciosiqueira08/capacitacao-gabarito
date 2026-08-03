class User < ApplicationRecord
  include EmailVerifiable
  include PasswordResettable

  # has_many é o lado "um" da relação um-para-muitos.
  # dependent: :delete_all — apagar o usuário apaga o histórico dele junto.
  # Sem isso, sobram linhas órfãs apontando para um id que não existe mais.
  has_many :login_events, dependent: :delete_all

  # Digest descartável usado quando o e-mail não existe. Sem ele, "e-mail não
  # cadastrado" responderia mais rápido que "senha errada", e dava para
  # descobrir quem tem conta cronometrando as respostas.
  DUMMY_PASSWORD_DIGEST = BCrypt::Password.create("automic-timing-safe-dummy").freeze

  # Dá ao model: `password=`, `password_confirmation` e `authenticate`.
  # Guarda só o digest bcrypt em password_digest. A senha em texto nunca toca o banco.
  # validations: false porque a política de senha é nossa (PasswordPolicyValidator).
  has_secure_password validations: false

  validates :name, presence: true, length: { maximum: 120 }
  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :course, presence: true
  validates :matricula, presence: true, uniqueness: true, format: { with: /\A\d{7}\z/ }
  validates :terms_accepted_at, presence: true, on: :create
  validate :password_meets_policy, if: -> { password.present? }

  # Normalizadores: o mesmo e-mail digitado de três jeitos é o mesmo e-mail.
  def self.normalize_name(name)
    name.to_s.strip
  end

  def self.normalize_email(email)
    email.to_s.strip.downcase
  end

  def self.normalize_matricula(matricula)
    matricula.to_s.gsub(/\D/, "")
  end

  # Sempre roda o bcrypt, mesmo sem usuário: o custo da resposta é o mesmo
  # existindo a conta ou não.
  def self.authenticate_by_email(email, password)
    user = find_by(email: normalize_email(email))
    digest = user&.password_digest || DUMMY_PASSWORD_DIGEST
    autenticado = BCrypt::Password.new(digest).is_password?(password.to_s)

    user if autenticado
  end

  # O JWT carrega a token_version de quando foi emitido. Se o número no token
  # não bate com o do banco, o token não vale mais.
  def token_version_matches?(submitted_version)
    token_version == submitted_version.to_i
  end

  # Derruba TODAS as sessões do usuário, em todos os dispositivos. Usado ao
  # redefinir a senha: quem invadiu a conta perde o acesso na hora.
  def invalidate_sessions!
    update!(token_version: token_version + 1)
  end

  private

  def password_meets_policy
    PasswordPolicyValidator.validate(password).each do |message|
      errors.add(:password, message)
    end
  end
end
