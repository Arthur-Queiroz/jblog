import { Controller } from "@hotwired/stimulus"

// Monta o sumário "Nesta página" do post a partir dos h2 do conteúdo.
// Os ids vêm do render no save (extensão header_ids do commonmarker); posts
// salvos antes dessa extensão não têm id, então geramos um aqui como fallback.
export default class extends Controller {
  static targets = ["content", "nav", "list"]

  connect() {
    const headings = this.contentTarget.querySelectorAll("h2")
    if (headings.length === 0) return

    headings.forEach((heading) => {
      const link = document.createElement("a")
      link.href = `#${this.ensureId(heading)}`
      link.textContent = heading.textContent
      link.className = "page-aside__link"
      this.listTarget.appendChild(link)
    })
    this.navTarget.hidden = false
  }

  ensureId(heading) {
    // O header_ids põe o id numa âncora dentro do h2, não no h2 em si.
    const existing = heading.id || heading.querySelector("[id]")?.id
    if (existing) return existing

    // Slug tipo parameterize: sem acentos (NFD remove os diacríticos), hífens no resto.
    const generated = heading.textContent.toLowerCase().trim()
      .normalize("NFD").replace(/[\u0300-\u036f]/g, "")
      .replace(/[^a-z0-9]+/g, "-").replace(/^-+|-+$/g, "")
    heading.id = generated
    return generated
  }

  scrollTop(event) {
    event.preventDefault()
    window.scrollTo({ top: 0, behavior: "smooth" })
  }
}
