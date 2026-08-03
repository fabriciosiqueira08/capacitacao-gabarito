# Histórico de login do usuário — a segunda tabela do projeto.
#
# Existe para o aluno ver uma associação de verdade (users 1—N login_events),
# e é útil: "sua conta foi acessada de outro aparelho" começa aqui.
class CreateLoginEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :login_events do |t|
      # references cria a coluna user_id, o índice e a chave estrangeira.
      # foreign_key: o BANCO passa a recusar login_event órfão.
      t.references :user, null: false, foreign_key: true
      t.string :client, null: false
      t.string :ip_address
      t.datetime :occurred_at, null: false

      t.timestamps
    end

    # Índice composto: a consulta é sempre "os últimos logins DESTE usuário".
    # A ordem das colunas importa — user_id primeiro, porque é o filtro.
    add_index :login_events, [ :user_id, :occurred_at ]
  end
end
