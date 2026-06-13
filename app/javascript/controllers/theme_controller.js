import { Controller } from "@hotwired/stimulus"

// Alterna claro/escuro e persiste a escolha. Sem escolha salva, o site segue o SO
// (o script inline no <head> do layout aplica o tema salvo antes do primeiro paint).
export default class extends Controller {
  toggle() {
    const current = document.documentElement.dataset.theme || this.systemTheme()
    const next = current === "dark" ? "light" : "dark"
    document.documentElement.dataset.theme = next
    localStorage.setItem("theme", next)
  }

  systemTheme() {
    return window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light"
  }
}
