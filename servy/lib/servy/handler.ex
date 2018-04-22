defmodule Servy.Handler do
  def handle(request) do
    # conv = parse(request)
    # conv = route(conv)
    # format_response(conv)
    request
      |> parse
      |> rewrite_path
      |> log
      |> route
      |> emojify
      |> track
      |> format_response
  end

  def track(%{status: 404, path: path} = conv) do
    IO.puts "Warning!!! #{path} is on the loose!"
    conv
  end
  def track(conv), do: conv

  # def rewrite_path(%{path: "/wildlife"} = conv), do: %{conv | path: "/wildthings"}
  # def rewrite_path(conv), do: conv
  def rewrite_path(%{path: path} = conv) do
    regex = ~r{\/(?<thing>\w+)\?id=(?<id>\d+)}
    captures = Regex.named_captures(regex, path)
    rewrite_path_captures(conv, captures)
  end

  def rewrite_path_captures(conv, %{"thing" => thing, "id" => id}), do:
    %{ conv | path: "/#{thing}/#{id}" }
  def rewrite_path_captures(conv, nil), do: conv

  def emojify(%{resp_body: resp_body, path: "/about", status: 200} = conv), do: conv

  def emojify(%{resp_body: resp_body, status: 200} = conv), do:
    %{conv | resp_body: ":) #{resp_body} 🎉" }
  def emojify(%{resp_body: resp_body} = conv), do:
  %{conv | resp_body: "Sad... #{resp_body} :(" }


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


  def route(%{method: "GET", path: "/wildthings"} = conv), do:
    %{ conv |  resp_body: "Bears, Lions, Tigers, Snakes", status: 200}

  def route(%{method: "GET", path: "/bears"} = conv), do:
    %{ conv |  resp_body: "Teddy, Smokey, Paddington", status: 200}

  def route(%{method: "GET", path: "/bears/new"} = conv), do:
  file =
    Path.expand("lib/pages")
    |> Path.join("form.html")
    |> File.read
    |> handle_file(conv)

  def route(%{method: "GET", path: "/bears/" <> id} = conv), do:
    %{ conv |  resp_body: "Bear #{id}", status: 200}

  def route(%{method: "GET", path: "/about" <> id} = conv) do
    file =
      Path.expand("lib/pages")
      |> Path.join("about.html")
      |> File.read
      |> handle_file(conv)
  end

  def handle_file({:ok, content}, conv), do: %{conv | status: 200, resp_body: content}
  def handle_file({:error, :enoent}, conv), do: %{conv | status: 404, resp_body: "File not found" }
  def handle_file({:error, reason}, conv), do: %{conv | status: 500, resp_body: "File error: #{reason}" }

  def route(%{path: path} = conv), do:
    %{conv | resp_body: "No path #{path} found", status: 404}


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
