defmodule Servy.Handler do
  def handle(request) do
    # conv = parse(request)
    # conv = route(conv)
    # format_response(conv)
    request
      |> parse
      |> log
      |> route
      |> format_response
  end

  # def log(conv) do
  #   IO.inspect conv
  #     #need to return it as well to keep pipeline working
  #     # IO.inspect does it - it returns inspected object
  # end

  def log(conv), do: IO.inspect conv

  def parse(request) do
    [method, path, _] =
      request
        |> String.split("\n")
        |> List.first
        |> String.split(" ")
    %{ method: method,
       path: path,
       resp_body: "",
       status: nil
     }
  end

  def route(conv) do
    route(conv, conv.method, conv.path)
  end
  def route(conv, "GET", "/wildthings") do
    %{ conv |  resp_body: "Bears, Lions, Tigers, Snakes", status: 200}
  end
  def route(conv, "GET", "/bears") do
    %{ conv |  resp_body: "Teddy, Smokey, Paddington", status: 200}
  end
  def route(conv, "GET", "/bears/" <> id) do
    %{ conv |  resp_body: "Bear #{id}", status: 200}
  end
  def route(conv, method, path) do
    %{conv | resp_body: "No path #{path} found", status: 404}
  end

  def format_response(conv) do
    """
    HTTP/1.1 #{conv.status} #{status_reason(conv.status)}
    Content-Type: text/html
    Content-Length: #{String.length(conv.resp_body)}

    #{conv.resp_body}
    """
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

end

# -------------------------------
request = """
GET /wildthings HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)
IO.puts(response)

# -------------------------------

request = """
GET /bears HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)
IO.puts(response)

# -------------------------------


request = """
GET /bears/3 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)
IO.puts(response)

# -------------------------------


request = """
GET /hren HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""
response = Servy.Handler.handle(request)
IO.puts(response)

# -------------------------------
