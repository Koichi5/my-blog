module ApplicationHelper
  # Design system: button class strings by variant and style.
  # variant: :primary | :secondary | :danger | :link
  # style: :filled (default) | :elevated | :outlined | :text
  def ds_button_classes(variant = :primary, style = :filled)
    base = "inline-block px-4 py-2 rounded-md font-medium transition-colors cursor-pointer focus:outline-none focus:ring-2 focus:ring-offset-2"
    style = :text if variant == :link
    case style
    when :elevated
      elevated_classes(base, variant)
    when :outlined
      outlined_classes(base, variant)
    when :text
      text_classes(base, variant)
    else
      filled_classes(base, variant)
    end
  end

  private

  def filled_classes(base, variant)
    case variant
    when :primary
      "#{base} bg-primary text-on-primary hover:bg-primary-hover focus:ring-primary"
    when :secondary
      "#{base} bg-secondary-container text-on-secondary-container hover:bg-secondary-container-hover focus:ring-on-secondary-container"
    when :danger
      "#{base} bg-danger text-on-primary hover:bg-danger-hover focus:ring-danger"
    when :link
      "#{base} text-primary hover:text-primary-hover bg-transparent focus:ring-primary"
    else
      "#{base} bg-primary text-on-primary hover:bg-primary-hover focus:ring-primary"
    end
  end

  def elevated_classes(base, variant)
    case variant
    when :primary
      "#{base} shadow-md bg-primary text-on-primary hover:bg-primary-hover focus:ring-primary"
    when :secondary
      "#{base} shadow-md bg-secondary text-on-secondary hover:opacity-90 focus:ring-on-secondary-container"
    when :danger
      "#{base} shadow-md bg-danger-bg text-danger-text hover:bg-danger hover:text-on-primary focus:ring-danger"
    else
      elevated_classes(base, :primary)
    end
  end

  def outlined_classes(base, variant)
    outline_base = "#{base} ds-btn-outline bg-transparent"
    case variant
    when :primary
      "#{outline_base} ds-btn-outline-primary hover:bg-border-subtle focus:ring-primary"
    when :secondary
      "#{outline_base} ds-btn-outline-secondary hover:bg-border-subtle focus:ring-text-muted"
    when :danger
      "#{outline_base} ds-btn-outline-danger hover:bg-border-subtle focus:ring-danger"
    else
      outlined_classes(base, :primary)
    end
  end

  def text_classes(base, variant)
    case variant
    when :primary
      "#{base} bg-transparent text-primary hover:bg-border-subtle focus:ring-primary"
    when :secondary
      "#{base} bg-transparent text-text hover:bg-border-subtle focus:ring-text-muted"
    when :danger
      "#{base} bg-transparent text-danger hover:bg-border-subtle focus:ring-danger"
    when :link
      "#{base} text-primary hover:text-primary-hover bg-transparent focus:ring-primary"
    else
      text_classes(base, :primary)
    end
  end

  public

  # Design system: card container classes
  def ds_card_classes(extra = "")
    "bg-surface rounded-lg shadow-md p-8 #{extra}".strip
  end

  # Design system: alert container classes by type
  def ds_alert_classes(type = :notice)
    base = "border-l-4 p-4 mx-auto max-w-7xl mt-4"
    type == :alert ? "#{base} bg-danger-bg border-danger text-danger-text" : "#{base} bg-success-bg border-success text-success-text"
  end

  # Design system: form field label class
  def ds_form_field_classes
    "block text-sm font-medium text-text mb-2"
  end

  # Design system: text input / textarea class
  def ds_input_classes
    "w-full max-w-md px-3 py-2 border border-border rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent"
  end
end
