require "test_helper"

class Admin::PostsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as(users(:one))
  end

  test "index lists all posts" do
    get admin_posts_path
    assert_response :success
    assert_select "td", text: "Post publicado"
    assert_select "td", text: "Rascunho"
  end

  test "new renders form" do
    get new_admin_post_path
    assert_response :success
    assert_select "form"
  end

  test "create with valid params creates post" do
    assert_difference("Post.count", 1) do
      post admin_posts_path, params: {
        post: { title: "Novo post", body_markdown: "Conteúdo novo" }
      }
    end
    assert_redirected_to admin_posts_path
  end

  test "create with invalid params renders form" do
    assert_no_difference("Post.count") do
      post admin_posts_path, params: {
        post: { title: "", body_markdown: "" }
      }
    end
    assert_response :unprocessable_entity
  end

  test "edit renders form" do
    get edit_admin_post_path(slug: "post-publicado")
    assert_response :success
    assert_select "form"
  end

  test "update with valid params updates post" do
    patch admin_post_path(slug: "post-publicado"), params: {
      post: { title: "Título atualizado" }
    }
    assert_redirected_to admin_posts_path
    assert_equal "Título atualizado", posts(:published_post).reload.title
  end

  test "update with invalid params renders form" do
    patch admin_post_path(slug: "post-publicado"), params: {
      post: { title: "" }
    }
    assert_response :unprocessable_entity
  end

  test "destroy removes post" do
    assert_difference("Post.count", -1) do
      delete admin_post_path(slug: "post-publicado")
    end
    assert_redirected_to admin_posts_path
  end
end
