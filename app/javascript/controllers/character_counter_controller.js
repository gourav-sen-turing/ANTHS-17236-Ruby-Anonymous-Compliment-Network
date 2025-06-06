import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "input", "count", "counter", "indicator", "submitButton" ]

  connect() {
    this.updateCount();
  }

  updateCount() {
    const currentCount = this.inputTarget.value.length;
    const minLength = parseInt(this.inputTarget.dataset.minLength || 0);
    const maxLength = parseInt(this.inputTarget.dataset.maxLength || 500);

    // Update the character count
    this.countTarget.textContent = currentCount;

    // Apply styling based on character count
    if (currentCount === 0) {
      this.counterTarget.classList.remove("text-red-500", "text-yellow-500", "text-green-500");
      this.counterTarget.classList.add("text-gray-500");
      this.indicatorTarget.textContent = "";
      this.indicatorTarget.classList.add("hidden");
    }
    else if (currentCount < minLength) {
      this.counterTarget.classList.remove("text-gray-500", "text-yellow-500", "text-green-500");
      this.counterTarget.classList.add("text-red-500");
      this.indicatorTarget.textContent = `Need ${minLength - currentCount} more character${minLength - currentCount !== 1 ? 's' : ''}`;
      this.indicatorTarget.classList.remove("hidden", "text-yellow-500", "text-green-500");
      this.indicatorTarget.classList.add("text-red-500");
    }
    else if (currentCount >= maxLength * 0.9) {
      this.counterTarget.classList.remove("text-gray-500", "text-red-500", "text-green-500");
      this.counterTarget.classList.add("text-yellow-500");

      if (currentCount > maxLength) {
        this.indicatorTarget.textContent = `${currentCount - maxLength} character${currentCount - maxLength !== 1 ? 's' : ''} over limit`;
        this.indicatorTarget.classList.remove("hidden", "text-green-500", "text-yellow-500");
        this.indicatorTarget.classList.add("text-red-500");
      } else {
        this.indicatorTarget.textContent = `${maxLength - currentCount} character${maxLength - currentCount !== 1 ? 's' : ''} remaining`;
        this.indicatorTarget.classList.remove("hidden", "text-red-500", "text-green-500");
        this.indicatorTarget.classList.add("text-yellow-500");
      }
    }
    else {
      this.counterTarget.classList.remove("text-gray-500", "text-red-500", "text-yellow-500");
      this.counterTarget.classList.add("text-green-500");
      this.indicatorTarget.textContent = "";
      this.indicatorTarget.classList.add("hidden");
    }

    // Disable button if limits are exceeded or not met
    if (currentCount < minLength || currentCount > maxLength) {
      this.submitButtonTarget.classList.add("opacity-50", "cursor-not-allowed", "bg-gray-400", "hover:bg-gray-400");
      this.submitButtonTarget.classList.remove("bg-indigo-600", "hover:bg-indigo-700");
      this.submitButtonTarget.disabled = true;
    } else {
      this.submitButtonTarget.classList.remove("opacity-50", "cursor-not-allowed", "bg-gray-400", "hover:bg-gray-400");
      this.submitButtonTarget.classList.add("bg-indigo-600", "hover:bg-indigo-700");
      this.submitButtonTarget.disabled = false;
    }
  }
}
