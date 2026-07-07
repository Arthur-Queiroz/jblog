require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  test "index shows published posts" do
    get root_path
    assert_response :success
    assert_select "a.month-group__link", text: "Post publicado"
  end

  test "index does not show draft posts" do
    get root_path
    assert_response :success
    assert_select "a.month-group__link", text: "Rascunho", count: 0
    assert_select "a.destaques__link", text: "Rascunho", count: 0
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

  test "responses include a content security policy with script nonce" do
    get root_path
    csp = response.headers["Content-Security-Policy"]
    assert csp.present?, "CSP header ausente"
    assert_match(/script-src 'self' 'nonce-/, csp)
    # O importmap é um script inline; sem o nonce aplicado, a CSP o bloquearia.
    assert_match(/<script type="importmap"[^>]* nonce=/, response.body)
  end

  test "theme bootstrap script carries the csp nonce" do
    get root_path
    theme_script = response.body[/<script[^>]*>[^<]*localStorage\.getItem\("theme"\)[^<]*<\/script>/m]
    assert theme_script.present?, "script inline do tema ausente no layout"
    assert_includes theme_script, "nonce=", "script do tema sem nonce — a CSP vai bloqueá-lo"
  end
end
