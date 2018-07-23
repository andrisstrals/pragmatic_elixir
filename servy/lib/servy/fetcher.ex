defmodule Servy.Fetcher do


  def async(fun) do
    this = self
    spawn(fn -> send(this, {:result, fun.()}) end)
  end

  def get_result() do
    receive do {:result, value} -> value end
  end

end