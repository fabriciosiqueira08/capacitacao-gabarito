# Recuperação de senha por código de 6 dígitos.
#
# Colunas separadas das de verificação de e-mail de propósito: os dois fluxos
# podem estar em andamento ao mesmo tempo. Ver o concern PasswordResettable.
class AddPasswordResetToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :password_reset_code_digest, :string
    add_column :users, :password_reset_expires_at, :datetime
    add_column :users, :password_reset_sent_at, :datetime
  end
end
