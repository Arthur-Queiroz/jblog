# Be sure to restart your server when you modify this file.

# Segunda linha de defesa contra XSS: mesmo que algum HTML malicioso escape da
# sanitização do MarkdownRenderer, o browser não executa script sem nonce.
# img-src permite https para imagens externas em posts Markdown.
Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self
    # Google Fonts: o CSS vem de fonts.googleapis.com e os arquivos de fonte
    # (Bitter/Lora/JetBrains Mono do redesign) de fonts.gstatic.com.
    policy.font_src    :self, :data, "https://fonts.gstatic.com"
    policy.img_src     :self, :https, :data
    policy.object_src  :none
    policy.script_src  :self
    policy.style_src   :self, "https://fonts.googleapis.com"
    policy.frame_ancestors :none
    policy.base_uri    :self
    policy.form_action :self
  end

  # Nonce para o importmap (script inline no <head>) e para o <style> da progress bar
  # do Turbo, que lê o nonce do csp_meta_tag no layout.
  config.content_security_policy_nonce_generator = ->(request) { SecureRandom.base64(16) }
  config.content_security_policy_nonce_directives = %w[script-src style-src]
end
