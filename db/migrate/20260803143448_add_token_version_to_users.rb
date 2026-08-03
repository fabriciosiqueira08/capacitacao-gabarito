# Versão das sessões do usuário. Vai dentro do JWT (claim `ver`).
#
# Incrementar esta coluna invalida todos os tokens já emitidos para o usuário —
# é como derrubamos todas as sessões de uma vez ao redefinir a senha.
class AddTokenVersionToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :token_version, :integer, null: false, default: 0
  end
end
