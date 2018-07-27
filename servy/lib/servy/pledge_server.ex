defmodule Servy.PledgeServer do


  def start do
    IO.puts "Starting the pledge server..."
    spawn(__MODULE__, :listen_loop, [[]])
  end

  def listen_loop(state) do
    IO.puts "\nWaiting for a message..."

    receive do
      {sender, :create_pledge, name, amount} ->
        {:ok, id} = send_pledge_to_service(name, amount)
        new_state = [{name, amount} | Enum.take(state, 2)]
        send sender, {:response, id}
        listen_loop(new_state)

      {sender, :recent_pledges} ->
        send sender, {:response, state}
        listen_loop(state)
    end
  end


  def create_pledge(pid, name, amount) do
    send pid, {self(), :create_pledge, name, amount}
    receive do {:response, status} -> status end
  end

  def recent_pledges(pid) do
    send pid, {self(), :recent_pledges}
    receive do {:response, pledges} -> pledges end
  end

  defp send_pledge_to_service(_name, _amount) do
    #    code goes here to send to external service
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end


#  alias Servy.PledgeServer
#    pid = PledgeServer.start
#  #
  #  Servy.PledgeServer.create_pledge(pid, "lary", 10)
  #  Servy.PledgeServer.create_pledge(pid, "moe", 20)
  #  Servy.PledgeServer.create_pledge(pid, "curly", 30)
  #  Servy.PledgeServer.create_pledge(pid, "daisy", 40)
  #  Servy.PledgeServer.create_pledge(pid, "grace", 50)

  #  send pid, { self(), :recent_pledges}
  #  receive do {:response, pledges} -> IO.inspect(pledges) end

end
