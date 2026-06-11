require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  test "index shows published posts" do
    get root_path
    assert_response :success
    assert_select "h2", text: "Post publicado"
  end

  test "index does not show draft posts" do
    get root_path
    assert_response :success
    assert_select "h2", { count: 1 }
    assert_select "h2", text: "Rascunho", count: 0
  end

  test "show displays a published post" do
    get post_path(slug: "post-publicado")
    assert_response :success
    assert_select "h1", text: "Post publicado"
  end

  test "show returns 404 for draft post" do
    get post_path(slug: "rascunho")
    assert_response :not_found
  end

  test "show returns 404 for nonexistent slug" do
    get post_path(slug: "nao-existe")
    assert_response :not_found
  end
end
