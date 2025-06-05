import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["categorySelect", "communitySelect"]

  connect() {
    this.filterCategories()
  }

  filterCategories() {
    const communityId = this.communitySelectTarget.value

    // If no community is selected, only show system categories
    if (!communityId) {
      this.fetchCategories('system_only=true')
      return
    }

    // Otherwise, fetch categories compatible with this community
    this.fetchCategories(`community_id=${communityId}`)
  }

  async fetchCategories(queryParams) {
    const response = await fetch(`/categories?${queryParams}`)
    const html = await response.text()
    this.categorySelectTarget.innerHTML = html
  }
}
