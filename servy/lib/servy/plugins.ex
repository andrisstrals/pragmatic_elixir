defmodule Servy.Plugins do
  alias Servy.Conv

  alias Servy.FourOhFourCounter

  @doc "Logs 404 requests"
  def track(%Conv{status: 404, path: path} = conv) do
    if Mix.env() != :test do
      FourOhFourCounter.bump_count(path)
      IO.puts("Warning!!! #{path} is on the loose!")
    end

    conv
  end

  def track(%Conv{} = conv), do: conv

  def rewrite_path(%Conv{path: path} = conv) do
    regex = ~r{\/(?<thing>\w+)\?id=(?<id>\d+)}
    captures = Regex.named_captures(regex, path)
    rewrite_path_captures(conv, captures)
  end

  defp rewrite_path_captures(%Conv{} = conv, %{"thing" => thing, "id" => id}),
    do: %{conv | path: "/#{thing}/#{id}"}

  defp rewrite_path_captures(%Conv{} = conv, nil), do: conv

  def emojify(%Conv{resp_body: _resp_body, path: "/about", status: 200} = conv), do: conv

  def emojify(%Conv{resp_body: resp_body, status: 200} = conv),
    do: %{conv | resp_body: ":) #{resp_body} 🎉"}

  def emojify(%Conv{resp_body: resp_body} = conv),
    do: %{conv | resp_body: "Sad... #{resp_body} :("}

  def log(%Conv{} = conv) do
    if(Mix.env() == :dev) do
      IO.inspect(conv)
    end

    conv
  end
end
