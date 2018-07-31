defmodule Servy.PledgeServer do

  @pid :pledge_server

  #  Client interface functions
  def start do
    IO.puts "Starting the pledge server..."
    pid = spawn(__MODULE__, :listen_loop, [[]])
    Process.register(pid, @pid)
    pid
  end

  def create_pledge(name, amount) do
    call @pid, {:create_pledge, name, amount}
  end

  def recent_pledges() do
    call @pid, :recent_pledges
  end

  def total_pledged() do
    call @pid, :total_pledged
  end

  def clear do
    cast @pid, :clear
  end

  #  Helper functions

  def call(pid, message) do
    send pid, {:call, self(), message}
    receive do {:response, response} -> response end
  end

  def cast(pid, message) do
    send pid, {:cast, message}
  end
  # Server

  def listen_loop(state) do
    IO.puts "\nWaiting for a message..."

    receive do

      {:call, sender, message} when is_pid(sender) ->
        {response, new_state} = handle_call(message, state)
        send sender, {:response, response}
        listen_loop new_state

      {:cast, message} ->
        new_state = handle_cast(message, state)
        listen_loop new_state

      unexpected ->
        IO.puts "Unexpected message #{IO.inspect(unexpected)}"
        listen_loop(state)

    end
  end

  defp handle_call(:total_pledged, state) do
    total = Enum.map(state, &elem(&1, 1))
            |> Enum.sum
    {total, state}
  end

  defp handle_call(:recent_pledges, state) do
    {state, state}
  end

  defp handle_call({:create_pledge, name, amount}, state) do
    {:ok, id} = send_pledge_to_service(name, amount)
    new_state = [{name, amount} | Enum.take(state, 2)]
    {id, new_state}
  end


  defp handle_cast(:clear, _state) do
    []
  end


  defp send_pledge_to_service(_name, _amount) do
    #    code goes here to send to external service
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end

end


