defmodule Servy.FourOhFourCounter do
  @moduledoc false

  #  alias Servy.GenericServer

  use GenServer

  @pid :bump_server


  #  Client interface functions
  def start_link(_arg) do
    IO.puts "Starting the bump count server..."
    GenServer.start(__MODULE__, %{}, name: @pid)
  end

  def bump_count(path) do
    GenServer.call @pid, {:bump_count, path}
  end


  def get_count(path) do
    GenServer.call @pid, {:get_count, path}
  end


  def get_counts do
    GenServer.call @pid, :get_counts
  end

  # Server callbacks

  def init(args) do
    {:ok, args}
  end

  def handle_call({:bump_count, path}, _from, state) do
    new_state = Map.update(state, path, 1, &(&1 + 1))
    {:reply, new_state, new_state}
  end

  def handle_call({:get_count, path}, _from, state) do
    count = Map.get(state, path, 0)
    {:reply, count, state}
  end

  def handle_call(:get_counts, _from, state) do
    {:reply, state, state}
  end

end
