class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :email, null: false
      # NUNCA a senha. Só o digest gerado pelo bcrypt — ver has_secure_password.
      t.string :password_digest, null: false
      t.string :course, null: false
      t.string :matricula, null: false
      t.datetime :terms_accepted_at, null: false

      t.timestamps
    end

    # Índice único no banco, não só validação no model: duas requisições
    # simultâneas passam pela validação juntas, mas só uma vence o índice.
    add_index :users, :email, unique: true
    add_index :users, :matricula, unique: true
  end
end
