defmodule Servy.Handler do
  @moduledoc "Handles HTTP requests"

  @pages_path Path.expand("lib/pages")

  alias Servy.Conv
  alias Servy.BearController
  alias Servy.FourOhFourCounter

  import Servy.Plugins, only: [rewrite_path: 1, track: 1]
  import Servy.Parser, only: [parse: 1]
  import Servy.Conv, only: [put_content_length: 1]

  @doc "Transforms the request into response"
  def handle(request) do
    request
    |> parse
    |> rewrite_path
      # |> log
    |> route
      # |> emojify
    |> track
    |> put_content_length
    |> format_response
  end


  def route(%Conv{method: "GET", path: "/404s"} = conv) do
    %{conv | status: 200, resp_body: inspect(FourOhFourCounter.get_counts())}
  end

  def route(%Conv{method: "POST", path: "/pledges"} = conv) do
    Servy.PledgeController.create(conv, conv.params)
  end

  def route(%Conv{method: "GET", path: "/pledges"} = conv) do
    Servy.PledgeController.index(conv)
  end

  def route(%Conv{method: "GET", path: "/sensors"} = conv) do
    sensor_data = Servy.SensorServer.get_sensor_data()

    %{conv | status: 200, resp_body: inspect sensor_data}
  end

  def route(%Conv{method: "GET", path: "/wildthings"} = conv),
      do: %{conv | resp_body: "Bears, Lions, Tigers, Snakes", status: 200}

  def route(%Conv{method: "GET", path: "/bears"} = conv),
      do: BearController.index(conv)

  def route(%Conv{method: "GET", path: "/kaboom"} = _conv),
      do: raise "kaboom!!!"

  def route(%Conv{method: "GET", path: "/api/bears"} = conv),
      do: Servy.Api.BearController.index(conv)

  def route(%Conv{method: "GET", path: "/bears/new"} = conv),
      do:
        _file =
          @pages_path
          |> Path.join("form.html")
          |> File.read()
          |> handle_file(conv)

  def route(%Conv{method: "GET", path: "/bears/" <> id} = conv) do
    params = Map.put(conv.params, "id", id)
    BearController.show(conv, params)
  end

  # name=Baloo&type=Brown
  def route(%Conv{method: "POST", path: "/bears"} = conv) do
    BearController.create(conv, conv.params)
  end

  def route(%Conv{method: "POST", path: "/api/bears"} = conv) do
    Servy.Api.BearController.create(conv, conv.params)
  end

  def route(%Conv{method: "GET", path: "/about" <> _id} = conv) do
    _file =
      @pages_path
      |> Path.join("about.html")
      |> File.read()
      |> handle_file(conv)
  end

  def route(%Conv{method: "GET", path: "/pages/faq"} = conv) do
    _file =
      @pages_path
      |> Path.join("faq.md")
      |> File.read()
      |> convert_md
      |> handle_file(conv)
  end

  def route(%Conv{path: path} = conv),
      do: %{conv | resp_body: "No path #{path} found", status: 404}

  def handle_file({:ok, content}, conv), do: %Conv{conv | status: 200, resp_body: content}

  def handle_file({:error, :enoent}, conv),
      do: %Conv{conv | status: 404, resp_body: "File not found"}

  def handle_file({:error, reason}, conv),
      do: %Conv{conv | status: 500, resp_body: "File error: #{reason}"}

  def convert_md({:ok, content}) do
    case Earmark.as_html(content) do
      {:ok, html, _} -> {:ok, html}
      {_, _} -> {:error, "MD format unsupported"}
    end

  end

  def convert_md({res, cont}), do: {res, cont}

  def format_response(%Conv{} = conv) do
    """
    HTTP/1.1 #{Conv.full_status(conv)}\r
    Content-Type: #{conv.resp_headers["Content-Type"]}\r
    Content-Length: #{conv.resp_headers["Content-Length"]}\r
    \r
    #{conv.resp_body}
    """
  end
end
