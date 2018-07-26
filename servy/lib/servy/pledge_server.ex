defmodule Servy.PledgeServer do

  def create_pledge(name, amount) do
    {:ok, _id} = send_pledge_to_service(name, amount)

    [ {"larry", 10}]
  end

  def recent_pledges do
    [ {"larry", 10}]
  end
  defp send_pledge_to_service(_name, _amount) do
#    code goes here to send to external service
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end
end
