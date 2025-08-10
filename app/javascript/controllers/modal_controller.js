import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Abre o modal quando o conteúdo chega no frame
    this.modal = bootstrap.Modal.getOrCreateInstance(this.element)
    this.modal.show()

    // Se o form renderizar novamente (422), manter aberto
    this.element.addEventListener("turbo:submit-end", (e) => {
      const ok = e.detail.success
      if (ok) this.modal.hide()
    })

    // Ao fechar, limpa o frame (pra não reaparecer em navegações Turbo)
    this.element.addEventListener("hidden.bs.modal", () => {
      const frame = document.querySelector("#agendamento_modal")
      if (frame) frame.innerHTML = ""
    })
  }

  close() {
    this.modal?.hide()
  }
}
