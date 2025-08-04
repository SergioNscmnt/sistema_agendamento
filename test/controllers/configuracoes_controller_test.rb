require "test_helper"

class ConfiguracoesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get configuracoes_show_url
    assert_response :success
  end

  test "should get edit" do
    get configuracoes_edit_url
    assert_response :success
  end
end
