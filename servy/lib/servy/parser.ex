defmodule Servy.Parser do
  # alias Servy.Conv, as: Conv
  alias Servy.Conv

  def parse(request) do
    [top, params_string] = String.split(request, "\n\n")
    [request_line | header_lines] = String.split(top, "\n")
    [method, path, _] = String.split(request_line, " ")

    headers = parse_headers(header_lines, %{})
    params = parse_params(headers["Content-Type"], params_string)

    %Conv{
      method: method,
      path: path,
      params: params,
      headers: headers
    }
  end

  def parse_params("application/x-www-form-urlencoded", params_string) do
    params_string |> String.trim() |> URI.decode_query()
  end

  def parse_params(_, _), do: %{}

  def parse_headers([hd | tl], headers) do
    [key, value] = String.split(hd, ": ")
    headers = Map.put(headers, key, value)
    # IO.inspect(headers)
    parse_headers(tl, headers)
  end

  def parse_headers([], headers) do
    # IO.puts("Done #{inspect(headers)}")
    headers
  end
end
