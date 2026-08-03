require "test_helper"

class PasswordPolicyValidatorTest < ActiveSupport::TestCase
  test "aceita senha que cumpre todas as regras" do
    assert_empty PasswordPolicyValidator.validate("Automic@2026")
  end

  test "aponta cada regra quebrada" do
    erros = PasswordPolicyValidator.validate("abc")

    assert_includes erros, "deve ter entre 8 e 16 caracteres"
    assert_includes erros, "deve incluir pelo menos uma letra maiúscula"
    assert_includes erros, "deve incluir pelo menos um dígito"
    assert_includes erros, "deve incluir pelo menos um caractere especial"
  end

  test "recusa senha longa demais" do
    assert_includes PasswordPolicyValidator.validate("Automic@2026Automic@2026"),
                    "deve ter entre 8 e 16 caracteres"
  end

  test "trata nil sem estourar" do
    assert_not_empty PasswordPolicyValidator.validate(nil)
  end
end
