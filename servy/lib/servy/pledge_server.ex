defmodule Servy.PledgeServer do

  @pid :pledge_server

  alias Servy.GenericServer

  #  Client interface functions
  def start do
    IO.puts "Starting the pledge server..."
    GenericServer.start(__MODULE__, [], @pid)
  end

  def create_pledge(name, amount) do
    GenericServer.call @pid, {:create_pledge, name, amount}
  end

  def recent_pledges() do
    GenericServer.call @pid, :recent_pledges
  end

  def total_pledged() do
    GenericServer.call @pid, :total_pledged
  end

  def clear do
    GenericServer.cast @pid, :clear
  end


  # Server callbacks
  def handle_call(:total_pledged, state) do
    total = Enum.map(state, &elem(&1, 1))
            |> Enum.sum
    {total, state}
  end

  def handle_call(:recent_pledges, state) do
    {state, state}
  end

  def handle_call({:create_pledge, name, amount}, state) do
    {:ok, id} = send_pledge_to_service(name, amount)
    new_state = [{name, amount} | Enum.take(state, 2)]
    {id, new_state}
  end


  def handle_cast(:clear, _state) do
    []
  end


  defp send_pledge_to_service(_name, _amount) do
    #    code goes here to send to external service
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end

end


