defmodule Servy.Wildthings do
  alias Servy.Bear

  @bears_path Path.expand("lib/db")

  def list_bears do
    Path.join(@bears_path, "bears.json")
    |> read_json
    |> Poison.decode!(as: %{"bears" => [%Bear{}]})
    |> Map.get("bears")
  end

  def get_bear(id) when is_integer(id) do
    Enum.find(list_bears(), fn b -> b.id == id end)
  end

  def get_bear(id) when is_binary(id) do
    id |> String.to_integer() |> get_bear
  end

  defp read_json(file) do
    case File.read(file) do
      {:ok, contents} ->
        contents

      {:error, reason} ->
        IO.inspect("Error reding #{file}: #{reason}")
        "[]"
    end
  end
end
