import { Controller } from "@hotwired/stimulus"
import $ from "jquery"
import "select2"

export default class extends Controller {
  connect() {
    $(this.element).select2({
      theme: "bootstrap-5",
      placeholder: this.element.dataset.placeholder || "Selecione...",
      allowClear: true
    })
  }

  disconnect() {
    $(this.element).select2("destroy")
  }
}
