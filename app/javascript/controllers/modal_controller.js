import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["frame"]

  connect() {
    this.bs = window.bootstrap?.Modal.getOrCreateInstance(this.element)

    // Abre quando o frame terminar de carregar o form
    this.element.addEventListener("turbo:frame-load", (e) => {
      if (e.target === this.frameTarget) this.bs?.show()
    })

    // Fecha quando esvaziamos o frame via turbo_stream.update("agendamento_modal", "")
    this.element.addEventListener("turbo:before-frame-render", (e) => {
      if (e.target === this.frameTarget && e.detail.newFrame.innerHTML.trim() === "") {
        this.bs?.hide()
      }
    })
  }

  // fallback: abrir já no clique (para feedback imediato)
  open() {
    this.bs?.show()
  }

  close() { this.bs?.hide() }
}
