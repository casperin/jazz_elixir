defmodule JazzWeb.NoteView do
  use JazzWeb, :view

  def to_html(file, content) do
    if String.ends_with?(file, ".md") do
      Earmark.as_html! content
    else
      "<pre>#{content}</pre>"
    end
  end
end
