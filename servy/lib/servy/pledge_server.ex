defmodule Servy.PledgeServer do

  @pid :pledge_server

  #  alias Servy.GenericServer
  use GenServer

  defmodule State do
    defstruct cache_size: 3, pledges: []
  end

  #  Client interface functions
  def start do
    IO.puts "Starting the pledge server..."
    GenServer.start(__MODULE__, %State{}, name: @pid)
  end

  def create_pledge(name, amount) do
    GenServer.call @pid, {:create_pledge, name, amount}
  end

  def recent_pledges() do
    GenServer.call @pid, :recent_pledges
  end

  def total_pledged() do
    GenServer.call @pid, :total_pledged
  end

  def clear do
    GenServer.cast @pid, :clear
  end

  def set_cache_size(size) do
    GenServer.cast @pid, {:set_cache_size, size}
  end


  # Server callbacks

  def init(state) do
    pledges = fetch_recent_pledges_from_service
    {:ok, %{state | pledges: pledges} }
  end

  def handle_call(:total_pledged, _from, state) do
    total = Enum.map(state.pledges, &elem(&1, 1))
            |> Enum.sum
    {:reply, total, state}
  end

  def handle_call(:recent_pledges, _from, state) do
    {:reply, state.pledges, state}
  end

  def handle_call({:create_pledge, name, amount}, _from, state) do
    {:ok, id} = send_pledge_to_service(name, amount)
    recent = Enum.take(state.pledges, (state.cache_size - 1))
    cached_pledges = [{name, amount} | recent]
    new_state = %{state | pledges: cached_pledges}
    {:reply, id, new_state}
  end


  def handle_cast(:clear, state) do
    {:noreply, %{state | pledges: []}}
  end

  def handle_cast({:set_cache_size, size}, state) do
    {:noreply, %{state | cache_size: size}}
  end

#  Called on unprocessed (unexpected) messages
  def handle_info(message, state) do
    IO.puts "Can't handle this! #{message}"
    {:noreply, state}
  end


  defp send_pledge_to_service(_name, _amount) do
    #    code goes here to send to external service
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end

  defp fetch_recent_pledges_from_service do
    [{"wilma", 15}, {"fred", 25}]
  end

end

