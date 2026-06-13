require "test_helper"

# Garante que nenhum endpoint administrativo fica acessível sem login.
# Se alguém adicionar allow_unauthenticated_access no Admin::PostsController
# por engano, estes testes quebram.
class Admin::AccessControlTest < ActionDispatch::IntegrationTest
  test "index requires authentication" do
    get admin_posts_path
    assert_redirected_to new_session_path
  end

  test "new requires authentication" do
    get new_admin_post_path
    assert_redirected_to new_session_path
  end

  test "create requires authentication" do
    assert_no_difference("Post.count") do
      post admin_posts_path, params: { post: { title: "Invasor", body_markdown: "x" } }
    end
    assert_redirected_to new_session_path
  end

  test "edit requires authentication" do
    get edit_admin_post_path(slug: "post-publicado")
    assert_redirected_to new_session_path
  end

  test "update requires authentication" do
    patch admin_post_path(slug: "post-publicado"), params: { post: { title: "Hackeado" } }
    assert_redirected_to new_session_path
    assert_equal "Post publicado", posts(:published_post).reload.title
  end

  test "destroy requires authentication" do
    assert_no_difference("Post.count") do
      delete admin_post_path(slug: "post-publicado")
    end
    assert_redirected_to new_session_path
  end

  test "preview requires authentication" do
    post preview_admin_posts_path, params: { body_markdown: "**x**" }
    assert_redirected_to new_session_path
  end
end
