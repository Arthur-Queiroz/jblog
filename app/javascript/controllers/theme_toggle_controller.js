import { Controller } from "@hotwired/stimulus"

// Botão único de tema no header: alterna entre claro e escuro e persiste a escolha.
// Os ícones (sol/lua) são trocados por CSS conforme o color-scheme efetivo, então
// este controller só decide a direção do clique. O valor salvo no localStorage é o
// mesmo que o script inline do layout reaplica antes do primeiro paint.
export default class extends Controller {
  toggle() {
    const theme = this.currentlyDark() ? "light" : "dark"
    document.documentElement.dataset.theme = theme
    localStorage.setItem("theme", theme)
  }

  // Estado atual pelo color-scheme computado do <html>: "dark"/"light" quando há
  // tema salvo; sem tema salvo é "light dark" e caímos na preferência do SO.
  currentlyDark() {
    const scheme = getComputedStyle(document.documentElement).colorScheme
    if (scheme === "dark") return true
    if (scheme === "light") return false
    return window.matchMedia("(prefers-color-scheme: dark)").matches
  }
}
