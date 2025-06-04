import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "searchInput",
    "hiddenInput",
    "selectedDisplay",
    "selectedName",
    "results"
    ]

  connect() {
    // Check if we already have a selected recipient (from params or previous selection)
    if (this.hiddenInputTarget.value) {
      // We need to fetch the recipient's info to display their name
      fetch(`/users/${this.hiddenInputTarget.value}/info`)
      .then(response => response.json())
      .then(data => {
        this.selectRecipient(data.id, data.name)
      })
      .catch(() => {
          // If fetch fails, just clear the selection to start fresh
        this.clearSelection()
      })
    }

    // Hide results when clicking outside
    document.addEventListener('click', (e) => {
      if (!this.element.contains(e.target)) {
        this.hideResults()
      }
    })
  }

  search() {
    const query = this.searchInputTarget.value.trim()

    if (query.length < 2) {
      this.hideResults()
      return
    }

    fetch(`/compliments/recipients?query=${encodeURIComponent(query)}`)
    .then(response => response.json())
    .then(data => {
      this.resultsTarget.innerHTML = ""

      if (data.recipients.length === 0) {
        const noResults = document.createElement("div")
        noResults.className = "py-2 px-4 text-gray-500 text-sm"
        noResults.textContent = "No matching recipients found"
        this.resultsTarget.appendChild(noResults)
      } else {
        data.recipients.forEach(recipient => {
          const option = document.createElement("div")
          option.className = "recipient-option cursor-pointer py-2 px-4 hover:bg-gray-100"
          option.innerHTML = `
          <strong>
          ${recipient.name}

          </strong>
          <span>
          @${recipient.username}

          </span>
          `
          option.dataset.id = recipient.id
          option.dataset.name = recipient.name
          option.addEventListener("click", () => {
            this.selectRecipient(recipient.id, recipient.name)
          })
          this.resultsTarget.appendChild(option)
        })
      }

      this.showResults()
    })
    .catch(error => {
      console.error("Error searching recipients:", error)
    })
  }

  selectRecipient(id, name) {
    this.hiddenInputTarget.value = id
    this.selectedNameTarget.textContent = name
    this.searchInputTarget.value = ""
    this.hideResults()

// Show the selected recipient display
    this.selectedDisplayTarget.classList.remove("hidden")
// Hide the search input
    this.searchInputTarget.classList.add("hidden")

// Trigger categoriesLoad event for the compliment form controller
    const event = new CustomEvent("recipientSelected", {
      detail: { recipientId: id },
      bubbles: true
    })
    this.element.dispatchEvent(event)

// Also trigger change on the hidden input for any regular form handlers
    this.hiddenInputTarget.dispatchEvent(new Event('change', { bubbles: true }))
  }

  clearSelection() {
    this.hiddenInputTarget.value = ""
    this.selectedDisplayTarget.classList.add("hidden")
    this.searchInputTarget.classList.remove("hidden")
    this.searchInputTarget.focus()

// Trigger event to clear categories
    const event = new CustomEvent("recipientCleared", { bubbles: true })
    this.element.dispatchEvent(event)

// Also trigger change on the hidden input
    this.hiddenInputTarget.dispatchEvent(new Event('change', { bubbles: true }))
  }

  showResults() {
    this.resultsTarget.classList.remove("hidden")
  }

  hideResults() {
    this.resultsTarget.classList.add("hidden")
  }
}
