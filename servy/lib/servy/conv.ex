defmodule Servy.Conv do
  defstruct method: "",
            path: "",
            params: %{},
            headers: %{},
            resp_headers: %{"Content-Type" => "text/html"},
            resp_body: "",
            status: nil

  def full_status(%Servy.Conv{} = conv) do
    "#{conv.status} #{status_reason(conv.status)}"
  end

  defp status_reason(code) do
    %{
      200 => "OK",
      201 => "Created",
      401 => "Unauthorised",
      403 => "Forbidden",
      404 => "Not Found",
      500 => "Internal Server Error"
    }[code]
  end

  def put_resp_content_type(%Servy.Conv{} = conv, type) do
    hdr = Map.put(conv.resp_headers, "Content-Type", type)
    %{conv | resp_headers: hdr}
  end

  def put_content_length(conv) do
    hdr = Map.put(conv.resp_headers, "Content-Length", String.length(conv.resp_body))
    %{conv | resp_headers: hdr}
  end
end
