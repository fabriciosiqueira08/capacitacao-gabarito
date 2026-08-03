# Confirmação de e-mail por código de 6 dígitos (OTP).
#
# O código é guardado como digest, igual à senha: se o banco vazar, ninguém
# confirma conta alheia. Ver o concern EmailVerifiable.
class AddEmailVerificationToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :email_verification_code_digest, :string
    add_column :users, :email_verification_expires_at, :datetime
    # Quando o último código saiu — usado para o cooldown de reenvio.
    add_column :users, :email_verification_sent_at, :datetime
    # Nulo enquanto não confirmado. Data em vez de booleano: guarda o "quando".
    add_column :users, :email_verified_at, :datetime
  end
end
