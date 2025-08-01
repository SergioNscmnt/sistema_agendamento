require "application_system_test_case"

class ServicosTest < ApplicationSystemTestCase
  setup do
    @servico = servicos(:one)
  end

  test "visiting the index" do
    visit servicos_url
    assert_selector "h1", text: "Servicos"
  end

  test "should create servico" do
    visit servicos_url
    click_on "New servico"

    fill_in "Duracao", with: @servico.duracao
    fill_in "Nome", with: @servico.nome
    fill_in "Preco", with: @servico.preco
    click_on "Create Servico"

    assert_text "Servico was successfully created"
    click_on "Back"
  end

  test "should update Servico" do
    visit servico_url(@servico)
    click_on "Edit this servico", match: :first

    fill_in "Duracao", with: @servico.duracao
    fill_in "Nome", with: @servico.nome
    fill_in "Preco", with: @servico.preco
    click_on "Update Servico"

    assert_text "Servico was successfully updated"
    click_on "Back"
  end

  test "should destroy Servico" do
    visit servico_url(@servico)
    click_on "Destroy this servico", match: :first

    assert_text "Servico was successfully destroyed"
  end
end
