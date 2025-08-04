import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["icon", "sidebar", "title", "username", "label", "toggleButton"]
  static values  = { enabled: Boolean }

  connect() {
    this.applyTheme(this.enabledValue)
  }

  async toggle(event) {
    this.enabledValue = !this.enabledValue
    this.applyTheme(this.enabledValue)
    await this.persistPreference()
  
    if (event?.target instanceof HTMLElement) {
      event.target.blur()
    }
  }

  applyTheme(isDark) {

    // TEXT BUTTON MOBILE SCREEN

    if (this.hasLabelTarget) {
      this.labelTarget.textContent = `Modo ${isDark ? "Escuro" : "Claro"}`
    }

    // BUTTON ACTIVE

    if (this.hasToggleButtonTarget) {
      this.toggleButtonTarget.classList.toggle("active", isDark)
    }

    // USERNAME   

    if (this.hasUsernameTarget) {
      this.usernameTarget.classList.toggle("text-white")
    }

    //TITLE

    if (this.hasTitleTarget) {
      this.titleTarget.classList.toggle("text-light", isDark)
      this.titleTarget.classList.toggle("text-dark",  !isDark)
    }
    // BODY
    document.body.classList.toggle("dark-mode",   isDark)
    document.body.classList.toggle("bg-dark",      isDark)
    document.body.classList.toggle("bg-light",    !isDark)
    document.body.classList.toggle("text-white",   isDark)
    document.body.classList.toggle("text-dark",   !isDark)

    // SIDEBAR
    if (this.hasSidebarTarget) {
      this.sidebarTarget.classList.toggle("bg-dark",    isDark)
      this.sidebarTarget.classList.toggle("bg-white",   !isDark)
      this.sidebarTarget.classList.toggle("text-white", isDark)
      this.sidebarTarget.classList.toggle("text-dark",  !isDark)
    }

    // CARDS
    document.querySelectorAll(".card").forEach(card => {
      card.classList.toggle("bg-secondary", isDark)  // cinza bloqueado
      card.classList.toggle("bg-white",    !isDark)
      card.classList.toggle("text-white",  isDark)
      card.classList.toggle("text-dark",   !isDark)
    })

    document.querySelectorAll(".form-control").forEach(el => {
      el.classList.toggle("bg-secondary", isDark)
      el.classList.toggle("bg-white",    !isDark)
      el.classList.toggle("text-white",  isDark)
      el.classList.toggle("text-dark",   !isDark)
      el.classList.toggle("border-0",    isDark)
    })

    // ÍCONE
    this.iconTargets.forEach(icon => {
      icon.classList.toggle("bi-eye", !isDark)
      icon.classList.toggle("bi-eye-slash", isDark)
    })
  }

  async persistPreference() {
    const token = document.querySelector("meta[name='csrf-token']").content
    try {
      await fetch("/configuracoes", {
        method: "PATCH",
        headers: {
          "Content-Type":   "application/json",
          "Accept":         "application/json",
          "X-CSRF-Token":   token
        },
        body: JSON.stringify({
          usuario: { dark_mode: this.enabledValue }
        })
      })
    } catch (e) {
      console.error("Não foi possível salvar preferência de tema:", e)
    }
  }
}
