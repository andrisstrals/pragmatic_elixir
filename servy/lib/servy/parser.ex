defmodule Servy.Parser do
  # alias Servy.Conv, as: Conv
  alias Servy.Conv

  def parse(request) do
    [top, params_string] = String.split(request, "\r\n\r\n")
    [request_line | header_lines] = String.split(top, "\r\n")
    [method, path, _] = String.split(request_line, " ")

    headers = parse_headers(header_lines)

    params = parse_params(headers["Content-Type"], params_string)

    %Conv{
      method: method,
      path: path,
      params: params,
      headers: headers
    }
  end

  @doc """
  Parses the given param string of the form `key1=value1&key2=value2`
  into a map with corresponding keys and values.

  ## Examples
      iex> params_string = "name=Baloo&type=Brown"
      iex> Servy.Parser.parse_params("application/x-www-form-urlencoded", params_string)
      %{"name" => "Baloo", "type" => "Brown"}
      iex> Servy.Parser.parse_params("multipart/form-data", params_string)
      %{}
      iex> json = ~s({"name": "Breezly", "type": "Polar"}) 
      iex> Servy.Parser.parse_params("application/json", json)
      %{"name" => "Breezly", "type" => "Polar"}
  """
  def parse_params("application/x-www-form-urlencoded", params_string) do
    params_string |> String.trim() |> URI.decode_query()
  end

  def parse_params("application/json", params_string) do
    params_string |> String.trim() |> Poison.Parser.parse!()
  end

  def parse_params(_, _), do: %{}

  def parse_headers(hdrlines) do
    Enum.reduce(hdrlines, %{}, fn s, acc ->
      [k, v] = String.split(s, ": ")
      Map.put(acc, k, v)
    end)
  end
end
