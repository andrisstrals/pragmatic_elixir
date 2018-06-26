defmodule Servy.BearController do
  alias Servy.Wildthings

  defp bear_item(b) do
    "<li>#{b.name} - #{b.hibernating}</li>"
  end

  def index(conv) do
    items =
      Wildthings.list_bears()
      |> Enum.filter(fn b -> b.type == "Grizzly" end)
      |> Enum.sort(fn b1, b2 -> b1.name < b2.name end)
      |> Enum.map(&bear_item(&1))
      |> Enum.join()

    # TODO: Transform bears to HTML list
    %{conv | status: 200, resp_body: "<ul>#{items}</ul>"}
  end

  def show(conv, %{"id" => id}) do
    bear = Wildthings.get_bear(id)
    %{conv | status: 200, resp_body: "<h1>Bear #{bear.id}: #{bear.name}</h1>"}
  end

  def create(conv, %{"name" => name, "type" => type} = params) do
    %{
      conv
      | status: 201,
        resp_body: "Created a #{type} bear named #{name}!"
    }
  end
end
