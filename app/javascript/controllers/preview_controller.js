import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "input", "output" ]

  async preview() {
    const markdown = this.inputTarget.value
    const token = document.querySelector('meta[name="csrf-token"]').content

    const response = await fetch("/admin/posts/preview", {
      method: "POST",
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
        "X-CSRF-Token": token
      },
      body: `body_markdown=${encodeURIComponent(markdown)}`
    })

    const html = await response.text()
    this.outputTarget.innerHTML = html
    this.outputTarget.classList.remove("hidden")
  }
}
