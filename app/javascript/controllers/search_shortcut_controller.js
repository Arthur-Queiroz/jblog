import { Controller } from "@hotwired/stimulus"

// Ctrl K (ou Cmd K no Mac) foca a busca do header, como o hint do campo indica.
export default class extends Controller {
  static targets = ["input"]

  focus(event) {
    if (!(event.ctrlKey || event.metaKey) || event.key.toLowerCase() !== "k") return

    event.preventDefault()
    this.inputTarget.focus()
    this.inputTarget.select()
  }
}
