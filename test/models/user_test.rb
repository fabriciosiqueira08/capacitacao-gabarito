require "test_helper"

class UserTest < ActiveSupport::TestCase
  ATRIBUTOS_VALIDOS = {
    name: "Carla Dias",
    email: "carla@aluno.ufop.edu.br",
    password: "Automic@2026",
    course: "Engenharia Civil",
    matricula: "2015555"
  }.freeze

  def build_user(**overrides)
    User.new(**ATRIBUTOS_VALIDOS, terms_accepted_at: Time.current, **overrides)
  end

  test "é válido com os atributos obrigatórios" do
    assert build_user.valid?
  end

  test "exige aceite dos termos na criação" do
    user = build_user(terms_accepted_at: nil)

    assert_not user.valid?
    assert_includes user.errors.attribute_names, :terms_accepted_at
  end

  test "recusa e-mail repetido, sem diferenciar maiúsculas" do
    user = build_user(email: users(:ana).email.upcase, matricula: "2016666")

    assert_not user.valid?
    assert_includes user.errors.attribute_names, :email
  end

  test "exige matrícula com exatamente 7 dígitos" do
    assert_not build_user(matricula: "12345").valid?
    assert_not build_user(matricula: "abcdefg").valid?
    assert build_user(matricula: "2017777").valid?
  end

  test "aplica a política de senha" do
    user = build_user(password: "senha")

    assert_not user.valid?
    assert_includes user.errors[:password], "deve incluir pelo menos uma letra maiúscula"
  end

  test "guarda o digest e nunca a senha em texto" do
    user = build_user
    user.save!

    assert_not_equal ATRIBUTOS_VALIDOS[:password], user.password_digest
    assert user.authenticate(ATRIBUTOS_VALIDOS[:password])
    assert_not user.authenticate("outra-senha")
  end

  test "normaliza e-mail e matrícula" do
    assert_equal "ana@ufop.br", User.normalize_email("  Ana@UFOP.br ")
    assert_equal "2011234", User.normalize_matricula("20.112-34")
  end

  test "authenticate_by_email encontra o usuário com a senha certa" do
    assert_equal users(:ana), User.authenticate_by_email("ANA@aluno.ufop.edu.br", "Automic@2026")
  end

  test "authenticate_by_email devolve nil com senha errada ou e-mail inexistente" do
    assert_nil User.authenticate_by_email(users(:ana).email, "errada")
    assert_nil User.authenticate_by_email("ninguem@ufop.br", "Automic@2026")
  end
end
