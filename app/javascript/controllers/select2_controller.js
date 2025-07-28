import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log("🎯 select2_controller conectado");

    // Espera o frame de renderização seguinte antes de inicializar
    requestAnimationFrame(() => {
      if (window.jQuery && $.fn.select2) {
        $(this.element).select2({
          width: "100%",
          theme: "bootstrap-5",
          placeholder: $(this.element).find('option:first').text(),
          allowClear: true,
          dropdownParent: $('body')
        });
      } else {
        console.error("❌ jQuery ou Select2 não estão disponíveis!");
      }
    });
  }
}
