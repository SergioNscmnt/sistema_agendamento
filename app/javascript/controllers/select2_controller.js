import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log("🎯 select2_controller conectado");

    // Espera o frame de renderização seguinte antes de inicializar
    requestAnimationFrame(() => {
      if (window.jQuery && $.fn.select2) {
        $(this.element).select2({
          theme: "bootstrap4", // ou "bootstrap-5" se usar um tema alternativo
          width: '100%',
          dropdownParent: $(this.element).parent()
        })
      } else {
        console.error("❌ jQuery ou Select2 não estão disponíveis!");
      }
    });
  }
}
