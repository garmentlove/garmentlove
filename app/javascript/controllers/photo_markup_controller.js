import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["file", "preview", "placeholder", "stage", "marks", "kind", "note", "annotations", "video", "canvas", "cameraMessage", "startCameraButton", "captureButton", "stopCameraButton"]

  preview() {
    const file = this.fileTarget.files[0]
    if (!file) return

    this.showPreview(file)
    this.stopCamera()
  }

  async startCamera() {
    if (!navigator.mediaDevices?.getUserMedia) {
      this.cameraMessageTarget.textContent = "Camera access is unavailable here. Choose a photo using the upload control."
      return
    }

    try {
      this.stream = await navigator.mediaDevices.getUserMedia({ video: { facingMode: { ideal: "environment" } } })
      this.videoTarget.srcObject = this.stream
      this.videoTarget.hidden = false
      this.previewTarget.hidden = true
      this.placeholderTarget.hidden = true
      this.startCameraButtonTarget.hidden = true
      this.captureButtonTarget.hidden = false
      this.stopCameraButtonTarget.hidden = false
      this.cameraMessageTarget.textContent = "Camera ready. Take a photo when the item is in frame."
    } catch (error) {
      this.cameraMessageTarget.textContent = `Could not open the camera: ${error.message} Choose a photo using the upload control.`
    }
  }

  async capture() {
    if (!this.videoTarget.videoWidth || !this.videoTarget.videoHeight) {
      this.cameraMessageTarget.textContent = "The camera is not ready yet. Try again or choose a photo using the upload control."
      return
    }

    const canvas = this.canvasTarget
    canvas.width = this.videoTarget.videoWidth
    canvas.height = this.videoTarget.videoHeight
    const context = canvas.getContext("2d")
    if (!context || typeof DataTransfer === "undefined") {
      this.cameraMessageTarget.textContent = "This browser cannot attach a camera photo to the order. Choose a photo using the upload control."
      this.stopCamera()
      return
    }
    context.drawImage(this.videoTarget, 0, 0)
    const blob = await new Promise((resolve) => canvas.toBlob(resolve, "image/jpeg", 0.9))
    if (!blob) {
      this.cameraMessageTarget.textContent = "The photo could not be captured. Choose a photo using the upload control."
      this.stopCamera()
      return
    }

    const file = new File([blob], `item-${Date.now()}.jpg`, { type: "image/jpeg" })
    const transfer = new DataTransfer()
    transfer.items.add(file)
    this.fileTarget.files = transfer.files
    this.showPreview(file)
    this.stopCamera()
    this.cameraMessageTarget.textContent = "Photo captured. Continue to item details when ready."
  }

  stopCamera() {
    this.stream?.getTracks().forEach((track) => track.stop())
    this.stream = null
    if (this.hasVideoTarget) {
      this.videoTarget.srcObject = null
      this.videoTarget.hidden = true
    }
    if (this.hasStartCameraButtonTarget) this.startCameraButtonTarget.hidden = false
    if (this.hasCaptureButtonTarget) this.captureButtonTarget.hidden = true
    if (this.hasStopCameraButtonTarget) this.stopCameraButtonTarget.hidden = true
  }

  catalogSelected() {
    this.stopCamera()
    this.fileTarget.value = ""
    this.previewTarget.removeAttribute("src")
    this.previewTarget.hidden = true
    this.placeholderTarget.hidden = false
    this.marksTarget.replaceChildren()
    if (this.hasAnnotationsTarget) this.annotationsTarget.value = "[]"
    this.fileTarget.disabled = true
    if (this.hasStartCameraButtonTarget) this.startCameraButtonTarget.disabled = true
    this.cameraMessageTarget.textContent = "Using the catalog item and its existing photo. Clear the catalog selection to add a new item photo."
    if (this.previewUrl) {
      URL.revokeObjectURL(this.previewUrl)
      this.previewUrl = null
    }
  }

  catalogCleared() {
    this.fileTarget.disabled = false
    if (this.hasStartCameraButtonTarget) this.startCameraButtonTarget.disabled = false
    this.cameraMessageTarget.textContent = "Use the device camera or choose an image."
  }

  disconnect() {
    this.stopCamera()
    if (this.previewUrl) URL.revokeObjectURL(this.previewUrl)
  }

  mark(event) {
    if (this.previewTarget.hidden || !this.hasAnnotationsTarget || !this.hasKindTarget || !this.hasNoteTarget) return

    const bounds = this.stageTarget.getBoundingClientRect()
    if (!bounds.width || !bounds.height) return
    const mark = {
      type: this.kindTarget.value,
      note: this.noteTarget.value.trim(),
      x: Math.round(((event.clientX - bounds.left) / bounds.width) * 1000) / 10,
      y: Math.round(((event.clientY - bounds.top) / bounds.height) * 1000) / 10
    }
    const marks = JSON.parse(this.annotationsTarget.value || "[]")
    marks.push(mark)
    this.annotationsTarget.value = JSON.stringify(marks)

    const marker = document.createElement("span")
    marker.className = `gl-pos-mark gl-pos-mark-${mark.type}`
    marker.style.left = `${mark.x}%`
    marker.style.top = `${mark.y}%`
    marker.textContent = mark.type.slice(0, 1).toUpperCase()
    marker.title = [mark.type, mark.note].filter(Boolean).join(": ")
    this.marksTarget.append(marker)
    this.noteTarget.value = ""
  }

  showPreview(file) {
    if (this.previewUrl) URL.revokeObjectURL(this.previewUrl)
    this.previewUrl = URL.createObjectURL(file)
    this.previewTarget.src = this.previewUrl
    this.previewTarget.hidden = false
    this.placeholderTarget.hidden = true
    if (this.hasVideoTarget) this.videoTarget.hidden = true
  }
}
