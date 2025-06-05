import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["message"]

  connect() {
    // Flash appears automatically due to CSS animation
  }

  dismiss() {
    this.messageTarget.remove()
  }

  remove(event) {
    // Only remove if this is the hide animation completing
    if (event.animationName === "fadeOut") {
      this.messageTarget.remove()
    }
  }
}
