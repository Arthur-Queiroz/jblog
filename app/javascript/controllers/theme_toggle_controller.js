import { Controller } from "@hotwired/stimulus"

// Botão sol/lua do header: alterna entre os temas claro e escuro padrão.
// Convive com a tela de configurações: qualquer tema de esquema escuro
// (kanagawa, gruvbox...) conta como "escuro", então o clique leva para "light"
// e o clique seguinte volta para "dark". Persiste no localStorage, o mesmo
// mecanismo que o script inline do layout reaplica antes do primeiro paint.
export default class extends Controller {
  static targets = ["sun", "moon"]

  connect() {
    this.updateIcon()
  }

  toggle() {
    const theme = this.effectiveDark() ? "light" : "dark"
    document.documentElement.dataset.theme = theme
    localStorage.setItem("theme", theme)
    this.updateIcon()
  }

  // Lê o color-scheme computado do <html> — cobre os temas fixos e, sem tema
  // salvo ("light dark"), cai na preferência do SO.
  effectiveDark() {
    const scheme = getComputedStyle(document.documentElement).colorScheme
    if (scheme === "dark") return true
    if (scheme === "light") return false
    return window.matchMedia("(prefers-color-scheme: dark)").matches
  }

  updateIcon() {
    const dark = this.effectiveDark()
    this.moonTarget.hidden = !dark
    this.sunTarget.hidden = dark
  }
}
