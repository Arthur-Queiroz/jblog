import { Controller } from "@hotwired/stimulus"

// Tela de configurações: cada card aplica seu tema ao clicar e o controller marca
// qual está ativo. A persistência é no localStorage; o script inline do layout
// reaplica o tema salvo antes do primeiro paint (evita flash).
//
// "system" = sem tema forçado: removemos o data-theme e o site volta a seguir o SO.
export default class extends Controller {
  static targets = ["card"]

  connect() {
    this.markActive()
  }

  select(event) {
    const theme = event.currentTarget.dataset.theme
    if (theme === "system") {
      delete document.documentElement.dataset.theme
      localStorage.removeItem("theme")
    } else {
      document.documentElement.dataset.theme = theme
      localStorage.setItem("theme", theme)
    }
    this.markActive()
  }

  markActive() {
    const current = document.documentElement.dataset.theme || "system"
    this.cardTargets.forEach((card) => {
      const active = card.dataset.theme === current
      card.classList.toggle("theme-card--active", active)
      card.setAttribute("aria-pressed", active)
    })
  }
}
