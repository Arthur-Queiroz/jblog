require "test_helper"

class SearchControllerTest < ActionDispatch::IntegrationTest
  test "index renders search form" do
    get search_path
    assert_response :success
    assert_select "form"
  end

  test "search with query returns results" do
    get search_path, params: { q: "publicado" }
    assert_response :success
    assert_select "h3", text: "Post publicado"
  end

  test "search with empty query shows no results" do
    get search_path, params: { q: "" }
    assert_response :success
    assert_select "ul", count: 0
  end

  test "search does not return draft posts" do
    get search_path, params: { q: "rascunho" }
    assert_response :success
    assert_select "h3", count: 0
  end
end
