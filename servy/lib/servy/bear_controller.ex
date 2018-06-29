defmodule Servy.BearController do
  alias Servy.Wildthings
  alias Servy.BearView

  @templates_path Path.expand("lib/templates")

  def index(conv) do
    bears =
      Wildthings.list_bears()
      |> Enum.sort(fn b1, b2 -> b1.name < b2.name end)

    %{conv | status: 200, resp_body: BearView.index(bears)}
  end

  def show(conv, %{"id" => id}) do
    bear = Wildthings.get_bear(id)

    %{conv | status: 200, resp_body: BearView.show(bear)}
  end

  def create(conv, %{"name" => name, "type" => type} = params) do
    %{
      conv
      | status: 201,
        resp_body: "Created a #{type} bear named #{name}!"
    }
  end
end
