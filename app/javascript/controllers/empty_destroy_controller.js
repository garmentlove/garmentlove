import { Controller } from "@hotwired/stimulus"

// data-controller="empty-destroy"
export default class extends Controller {
  static targets = ["destroy", "inputs"]

  connect() {
    // Initial evaluation
    this.update()
  }

  update() {
    const allEmpty = this.inputsTargets
      .filter((el) => el.offsetParent !== null) // visible
      .every((el) => el.value.trim() === "")
    this.destroyTarget.value = allEmpty ? "true" : "false"
  }
}
