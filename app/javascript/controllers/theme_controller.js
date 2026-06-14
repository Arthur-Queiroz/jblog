import { Controller } from "@hotwired/stimulus"

// Aplica o tema escolhido no <html> e persiste no localStorage. O próprio <select>
// é o elemento do controller. Sem escolha salva ("Sistema"), removemos o data-theme
// e o site volta a seguir o SO (o :root usa light-dark()).
//
// Adicionar um tema é só: novo bloco [data-theme] no CSS + nova <option> no layout.
// Nada muda aqui — o controller só lê o value do select.
export default class extends Controller {
  connect() {
    // Reflete no select o tema atualmente forçado (ou "Sistema" quando não há).
    this.element.value = document.documentElement.dataset.theme || "system"
  }

  apply() {
    const theme = this.element.value
    if (theme === "system") {
      delete document.documentElement.dataset.theme
      localStorage.removeItem("theme")
    } else {
      document.documentElement.dataset.theme = theme
      localStorage.setItem("theme", theme)
    }
  }
}
