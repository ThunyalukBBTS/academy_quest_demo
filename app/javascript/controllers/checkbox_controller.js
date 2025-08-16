import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="checkbox"
export default class extends Controller {
  submit(event) {
    this.element.closest("form").requestSubmit();
  }
}
