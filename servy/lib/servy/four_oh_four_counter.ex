defmodule Servy.FourOhFourCounter do
  @moduledoc false

  alias Servy.GenericServer

  @pid :bump_server


  #  Client interface functions
  def start do
    IO.puts "Starting the bump count server..."
    GenericServer.start(__MODULE__, %{}, @pid)
  end

  def bump_count(path) do
    GenericServer.call @pid, {:bump_count, path}
  end


  def get_count(path) do
    GenericServer.call @pid, {:get_count, path}
  end


  def get_counts do
    GenericServer.call @pid, :get_counts
  end

  # Server callbacks
  def handle_call({:bump_count, path}, state) do
    new_state = Map.update(state, path, 1, &(&1 + 1))
    {new_state, new_state}
  end

  def handle_call({:get_count, path}, state) do
    count = Map.get(state, path, 0)
    {count, state}
  end

  def handle_call(:get_counts, state) do
    {state, state}
  end

end
