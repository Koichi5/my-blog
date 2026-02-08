module PostsHelper
  def markdown_to_html(text)
    return "" if text.blank?

    renderer = Redcarpet::Render::HTML.new(
      filter_html: true,
      hard_wrap: true,
      link_attributes: { rel: "nofollow", target: "_blank" }
    )
    markdown = Redcarpet::Markdown.new(renderer, {
      autolink: true,
      tables: true,
      fenced_code_blocks: true,
      strikethrough: true,
      superscript: true
    })
    markdown.render(text).html_safe
  end
end
