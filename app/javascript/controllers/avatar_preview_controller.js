import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "preview", "icon"]

  triggerFileInput() {
    this.inputTarget.click()
  }

  preview() {
    const file = this.inputTarget.files[0]
    if (file) {
      const reader = new FileReader()
      reader.onload = (e) => {
        this.previewTarget.src = e.target.result
        this.previewTarget.classList.remove("d-none")
        this.iconTarget.classList.add("d-none")
      }
      reader.readAsDataURL(file)
    }
  }
}
