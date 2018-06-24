defmodule Servy.Handler do
  @moduledoc "Handles HTTP requests"

  @pages_path Path.expand("lib/pages")

  alias Servy.Conv

  import Servy.Plugins, only: [rewrite_path: 1, log: 1, emojify: 1, track: 1]
  import Servy.Parser, only: [parse: 1]

  @doc "Transforms the request into response"
  def handle(request) do
    request
    |> parse
    |> rewrite_path
    |> log
    |> route
    # |> emojify
    |> track
    |> format_response
  end

  def route(%Conv{method: "GET", path: "/wildthings"} = conv),
    do: %{conv | resp_body: "Bears, Lions, Tigers, Snakes", status: 200}

  def route(%Conv{method: "GET", path: "/bears"} = conv),
    do: %{conv | resp_body: "Teddy, Smokey, Paddington", status: 200}

  def route(%Conv{method: "GET", path: "/bears/new"} = conv),
    do:
      file =
        @pages_path
        |> Path.join("form.html")
        |> File.read()
        |> handle_file(conv)

  def route(%Conv{method: "GET", path: "/bears/" <> id} = conv),
    do: %{conv | resp_body: "Bear #{id}", status: 200}

  # name=Baloo&type=Brown
  def route(%Conv{method: "POST", path: "/bears"} = conv) do
    # params = %{"name" => "Baloo", "type" => "Brown"}
    %{
      conv
      | status: 201,
        resp_body: "Created a #{conv.params["type"]} bear named #{conv.params["name"]}!"
    }
  end

  def route(%Conv{method: "GET", path: "/about" <> id} = conv) do
    file =
      @pages_path
      |> Path.join("about.html")
      |> File.read()
      |> handle_file(conv)
  end

  def route(%Conv{path: path} = conv),
    do: %{conv | resp_body: "No path #{path} found", status: 404}

  def handle_file({:ok, content}, conv), do: %Conv{conv | status: 200, resp_body: content}

  def handle_file({:error, :enoent}, conv),
    do: %Conv{conv | status: 404, resp_body: "File not found"}

  def handle_file({:error, reason}, conv),
    do: %Conv{conv | status: 500, resp_body: "File error: #{reason}"}

  def format_response(%Conv{} = conv) do
    """
    HTTP/1.1 #{Conv.full_status(conv)}
    Content-Type: text/html
    Content-Length: #{String.length(conv.resp_body)}

    #{conv.resp_body}
    """
  end
end

# -------------------------------
request = """
GET /wildlife HTTP/1.1
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

request = """
GET /about HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)
IO.puts(response)

# -------------------------------

request = """
GET /bears/new HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)
IO.puts(response)

# -------------------------------

request = """
POST /bears HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*
Content-Type: application/x-www-form-urlencoded
Content-Length: 21

name=Ballo&type=Browny
"""

request = """
POST /bears HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*
Content-Type: multipart/form-data
Content-Length: 21

name=Ballo&type=Browny
"""

response = Servy.Handler.handle(request)
IO.puts(response)

# -------------------------------
