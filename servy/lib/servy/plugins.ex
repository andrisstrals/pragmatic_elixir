defmodule Servy.Plugins do

  @doc "Logs 404 requests"
  def track(%{status: 404, path: path} = conv) do
    IO.puts "Warning!!! #{path} is on the loose!"
    conv
  end
  def track(conv), do: conv

  def rewrite_path(%{path: path} = conv) do
    regex = ~r{\/(?<thing>\w+)\?id=(?<id>\d+)}
    captures = Regex.named_captures(regex, path)
    rewrite_path_captures(conv, captures)
  end

  defp rewrite_path_captures(conv, %{"thing" => thing, "id" => id}), do:
  %{ conv | path: "/#{thing}/#{id}" }
  defp rewrite_path_captures(conv, nil), do: conv

  def emojify(%{resp_body: resp_body, path: "/about", status: 200} = conv), do: conv

  def emojify(%{resp_body: resp_body, status: 200} = conv), do:
  %{conv | resp_body: ":) #{resp_body} 🎉" }
  def emojify(%{resp_body: resp_body} = conv), do:
  %{conv | resp_body: "Sad... #{resp_body} :(" }


  def log(conv), do: IO.inspect conv

end
