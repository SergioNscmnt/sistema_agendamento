module ApplicationHelper
  def format_date(value, format: :default)
    return "" if value.blank?

    case format
    when Symbol
      I18n.l(value.to_date, format: format)
    when String
      value.to_date.strftime(format)
    else
      value.to_date.to_s
    end
  end

  def body_classes
    return 'bg-light' unless usuario_signed_in? && current_usuario.dark_mode?
    'dark-mode bg-dark text-white'
  end

  def dark_mode?
    usuario_signed_in? && current_usuario.dark_mode?
  end

  def card_headers
    dark_mode? ? 'bg-dark text-white' : 'bg-light text-dark'
  end

  def card_footer
    dark_mode? ? 'bg-dark text-white' : 'bg-light text-dark'
  end

  def card_classes
    dark_mode? ? 'bg-dark text-white' : 'bg-light'
  end

  def list_item_class
    if dark_mode?
      "list-group-item list-group-item-secondary text-white"
    else
      "list-group-item list-group-item-light text-dark"
    end
  end
  
  def form_control_class
    base = 'form-control form-control-sm'
    theme = dark_mode? ? 'bg-secondary text-white border-0' : 'bg-white text-dark'
    "#{base} #{theme}"
  end

  def body_classes
    dark_mode? ? 'bg-dark text-white' : 'bg-light'
  end

  # classes para a sidebar
  def sidebar_classes
    'col-md-3 col-lg-2 border-end p-3'
  end

  def status_label(status)
    cor =
      case status.to_s
      when "concluido" then "success"   # verde
      when "agendado"  then "primary"   # azul
      when "cancelado" then "danger"    # vermelho
      else                   "secondary" # cinza
      end
    
    # Compatível com Bootstrap 3 e 5
    classes = "label label-#{cor} badge bg-#{cor}"
    
    content_tag(:span, status.humanize, class: classes)
  end
end
