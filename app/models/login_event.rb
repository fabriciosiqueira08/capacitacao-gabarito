# Um login que aconteceu. Pertence a um usuário.
class LoginEvent < ApplicationRecord
  # belongs_to é o lado que CARREGA a chave estrangeira (user_id).
  # No Rails 5+ ele já exige presença: LoginEvent sem user é inválido.
  belongs_to :user

  CLIENTS = %w[mobile web].freeze

  validates :client, presence: true, inclusion: { in: CLIENTS }
  validates :occurred_at, presence: true

  # Scope é uma consulta com nome. Dá para encadear:
  #   user.login_events.recentes.limit(5)
  scope :recentes, -> { order(occurred_at: :desc) }
end
