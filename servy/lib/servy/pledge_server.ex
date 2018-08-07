defmodule Servy.PledgeServer do

  @pid :pledge_server

  #  alias Servy.GenericServer
  use GenServer

  #  Client interface functions
  def start do
    IO.puts "Starting the pledge server..."
    GenServer.start(__MODULE__, [], name: @pid)
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


  # Server callbacks
  def handle_call(:total_pledged, _from, state) do
    total = Enum.map(state, &elem(&1, 1))
            |> Enum.sum
    {:reply, total, state}
  end

  def handle_call(:recent_pledges, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:create_pledge, name, amount}, _from, state) do
    {:ok, id} = send_pledge_to_service(name, amount)
    new_state = [{name, amount} | Enum.take(state, 2)]
    {:reply, id, new_state}
  end


  def handle_cast(:clear, _state) do
    {:noreply, []}
  end


  defp send_pledge_to_service(_name, _amount) do
    #    code goes here to send to external service
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end

end


