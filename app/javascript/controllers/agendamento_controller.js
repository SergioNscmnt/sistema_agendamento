import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["frame", "data"]

  refresh() {
    const params = new URLSearchParams()
    const form   = this.element

    const funcionarioId = form.querySelector("#agendamento_funcionario_id")?.value
    const servicoId     = form.querySelector("#agendamento_servico_id")?.value
    const data          = this.dataTarget?.value

    if (!funcionarioId || !servicoId || !data) {
      this.frameTarget.innerHTML = `<div class="text-muted">Escolha profissional, serviço e data para ver os horários disponíveis.</div>`
      return
    }

    params.set("funcionario_id", funcionarioId)
    params.set("servico_id", servicoId)
    params.set("data", data)

    // Turbo Frame carrega a partial
    const url = `/agendamentos/novos_horarios?${params.toString()}`
    this.frameTarget.src = url
  }
}
