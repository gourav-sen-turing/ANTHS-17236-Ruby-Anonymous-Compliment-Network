import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  connect() {
    // Close dropdown when clicking outside
    document.addEventListener('click', this.outsideClickHandler)
  }

  disconnect() {
    document.removeEventListener('click', this.outsideClickHandler)
  }

  outsideClickHandler = (event) => {
    if (!this.element.contains(event.target) && !this.menuTarget.classList.contains('hidden')) {
      this.toggle()
    }
  }

  toggle() {
    this.menuTarget.classList.toggle('hidden')
  }
}
