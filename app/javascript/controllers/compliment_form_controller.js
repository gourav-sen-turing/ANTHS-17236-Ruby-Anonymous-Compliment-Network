import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "recipient",
    "category",
    "templateContainer",
    "templates",
    "content",
    "characterCount",
    "anonymous"
  ]

  connect() {
    this.updateCharacterCount()

    // If we already have a recipient and category selected, try to load templates
    if (this.recipientTarget.value && this.categoryTarget.value) {
      this.loadTemplates()
    }
  }

  loadTemplates() {
    const categoryId = this.categoryTarget.value
    if (!categoryId) {
      this.templateContainerTarget.classList.add("hidden")
      return
    }

    fetch(`/api/categories/${categoryId}/templates`)
      .then(response => response.json())
      .then(data => {
        if (data.templates && data.templates.length > 0) {
          this.templateContainerTarget.classList.remove("hidden")

          this.templatesTarget.innerHTML = ""

          data.templates.forEach(template => {
            const button = document.createElement("button")
            button.type = "button"
            button.className = "template-option px-3 py-1.5 bg-white border border-gray-300 rounded-md text-sm text-gray-700 hover:bg-gray-50"
            button.textContent = template.substring(0, 25) + "..."
            button.setAttribute("data-full-template", template)
            button.addEventListener("click", (e) => {
              const fullTemplate = e.target.getAttribute("data-full-template")
              this.contentTarget.value = fullTemplate
              this.contentTarget.focus()
              this.updateCharacterCount()

              // Scroll textarea to start to ensure user sees the beginning of template
              this.contentTarget.scrollTop = 0
            })
            this.templatesTarget.appendChild(button)
          })
        } else {
          this.templateContainerTarget.classList.add("hidden")
        }
      })
      .catch(error => {
        console.error("Error loading templates:", error)
        this.templateContainerTarget.classList.add("hidden")
      })
  }

  updateCharacterCount() {
    const maxLength = 500
    const currentLength = this.contentTarget.value.length
    this.characterCountTarget.textContent = `${currentLength}/${maxLength} characters`

    // Visual feedback on character count
    if (currentLength > maxLength) {
      this.characterCountTarget.classList.add("text-red-500")
      this.characterCountTarget.classList.remove("text-gray-500")
    } else if (currentLength > maxLength * 0.8) {
      this.characterCountTarget.classList.add("text-yellow-500")
      this.characterCountTarget.classList.remove("text-gray-500", "text-red-500")
    } else {
      this.characterCountTarget.classList.add("text-gray-500")
      this.characterCountTarget.classList.remove("text-yellow-500", "text-red-500")
    }
  }
}
