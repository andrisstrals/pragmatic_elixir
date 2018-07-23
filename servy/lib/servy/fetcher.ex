defmodule Servy.Fetcher do


  def async(fun) do
    this = self
    spawn(fn -> send(this, {self(), :result, fun.()}) end)
  end

  def get_result(pid) do
    receive do {^pid, :result, value} -> value end
  end

end