import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["barcodeStep", "photoStep", "detailsStep", "barcodeInput", "barcodeField", "barcodeDisplay", "stepLabel"]

  connect() {
    this.showStep(this.barcodeStepTarget)
  }

  continueToPhoto(event) {
    if (event.type === "keydown") event.preventDefault()
    this.barcodeFieldTarget.value = this.barcodeInputTarget.value.trim()
    if (this.hasBarcodeDisplayTarget) this.barcodeDisplayTarget.value = this.barcodeFieldTarget.value || "No barcode"
    this.showStep(this.photoStepTarget)
  }

  skipBarcode() {
    this.barcodeInputTarget.value = ""
    this.continueToPhoto({ type: "click" })
  }

  continueToDetails() {
    this.showStep(this.detailsStepTarget)
    this.detailsStepTarget.querySelector('input[name$="[name]"]')?.focus()
  }

  showDetails() {
    this.continueToDetails()
  }

  backToBarcode() {
    this.showStep(this.barcodeStepTarget)
    this.barcodeInputTarget.focus()
  }

  backToPhoto() {
    this.showStep(this.photoStepTarget)
  }

  showStep(activeStep) {
    const steps = [this.barcodeStepTarget, this.photoStepTarget, this.detailsStepTarget]
    this.element.dataset.itemEntryStage = activeStep === this.barcodeStepTarget
      ? "barcode"
      : (activeStep === this.photoStepTarget ? "photo" : "details")
    steps.forEach((step, index) => {
      step.hidden = step !== activeStep
      this.stepLabelTargets[index].classList.toggle("gl-pos-item-progress-active", step === activeStep)
      if (step === activeStep) {
        this.stepLabelTargets[index].setAttribute("aria-current", "step")
      } else {
        this.stepLabelTargets[index].removeAttribute("aria-current")
      }
    })
  }
}
