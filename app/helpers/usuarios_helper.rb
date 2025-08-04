module UsuariosHelper
  def avatar_upload_field(form, usuario)
    content_tag(:div, class: "col-sm-3 mb-3", data: { controller: "avatar-preview" }) do
      form.label(:avatar, "Foto de perfil", class: "form-label fw-semibold small d-block") +

      content_tag(:div,
        class: "position-relative border rounded overflow-hidden",
        style: "width: 120px; aspect-ratio: 1 / 1; background-color: #f8f9fa; cursor: pointer;",
        data: { action: "click->avatar-preview#triggerFileInput" }) do

        avatar_img = if usuario.avatar.attached?
          image_tag(
            usuario.avatar.variant(resize_to_fill: [120, 120]),
            class: "img-fluid h-100 w-100 object-fit-cover",
            data: { avatar_preview_target: "preview" }
          )
        else
          image_tag("", class: "d-none", data: { avatar_preview_target: "preview" })
        end

        icon = content_tag(:div,
          content_tag(:i, "", class: "bi bi-plus-lg text-secondary"),
          class: "position-absolute top-50 start-50 translate-middle bg-body bg-opacity-75 rounded-circle d-flex align-items-center justify-content-center",
          data: { avatar_preview_target: "icon" },
          style: "width: 36px; height: 36px; z-index: 2;"
        )

        file_input = form.file_field(:avatar,
          class: "d-none",
          accept: "image/*",
          data: {
            avatar_preview_target: "input",
            action: "avatar-preview#preview"
          }
        )

        avatar_img + icon + file_input
      end
    end
  end
end
