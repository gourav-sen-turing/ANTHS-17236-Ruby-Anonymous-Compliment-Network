import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "feedback"]

  connect() {
    console.log("Username validation controller connected!")
    // Add a class to visually confirm connection
    this.element.classList.add("controller-connected")
    this.validateOnChange()
  }

  validateOnChange() {
    this.inputTarget.addEventListener('input', this.validate.bind(this))
  }

  validate() {
    const username = this.inputTarget.value
    console.log("Validating username:", username)

    if (username.length === 0) {
      this.showFeedback("Username can't be blank", "error")
      return
    }

    if (username.length < 3) {
      this.showFeedback("Username is too short (minimum is 3 characters)", "error")
      return
    }

    if (username.length > 30) {
      this.showFeedback("Username is too long (maximum is 30 characters)", "error")
      return
    }

    if (!/^[a-zA-Z0-9_]+$/.test(username)) {
      this.showFeedback("Username only allows letters, numbers, and underscores", "error")
      return
    }

    this.showFeedback("Username format is valid", "success")
  }

  showFeedback(message, type) {
    this.feedbackTarget.textContent = message
    this.feedbackTarget.classList.remove("text-gray-500", "text-red-500", "text-green-500")
    this.feedbackTarget.classList.add(type === "error" ? "text-red-500" : "text-green-500")
  }
}
