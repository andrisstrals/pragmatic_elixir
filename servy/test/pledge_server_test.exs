defmodule PledgyTest do
  use ExUnit.Case

  alias Servy.PledgeServer

  test "creates pledges" do
    PledgeServer.start()

    PledgeServer.create_pledge("larry", 10)
    PledgeServer.create_pledge("moe", 20)
    PledgeServer.create_pledge("curly", 30)
    PledgeServer.create_pledge("daisy", 40)
    PledgeServer.create_pledge("grace", 50)

    pledges = PledgeServer.recent_pledges()
    total = PledgeServer.total_pledged()

    assert pledges === [{"grace", 50}, {"daisy", 40}, {"curly", 30}]
    assert total === 120

    PledgeServer.clear
    assert PledgeServer.recent_pledges() === []
    assert PledgeServer.total_pledged() === 0

    PledgeServer.set_cache_size(4)
    PledgeServer.create_pledge("larry", 10)
    PledgeServer.create_pledge("moe", 20)
    PledgeServer.create_pledge("curly", 30)
    PledgeServer.create_pledge("daisy", 40)
    PledgeServer.create_pledge("grace", 50)

    pledges = PledgeServer.recent_pledges()
    total = PledgeServer.total_pledged()

    assert pledges === [{"grace", 50}, {"daisy", 40}, {"curly", 30}, {"moe", 20}]
    assert total === 140

  end

end