defmodule ServyTest do
  use ExUnit.Case
  doctest Servy

  test "the truth is not false" do
    assert 1 + 1 == 2
    refute 2 + 1 == 2
    # assert Servy.hello() == :world
  end
end
