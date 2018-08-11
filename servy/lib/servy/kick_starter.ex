defmodule Servy.KickStarter do
  @moduledoc false

  use GenServer

  def start do
    IO.puts "Starting the kickstarter"
    GenServer.start(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    Process.flag(:trap_exit, true)
    {:ok, start_server()}
  end

  def handle_info({:EXIT, state, reason}, state) do
    IO.puts "It seems like shit happened to HTTP server... reason:#{inspect reason} state:#{inspect state}"
    {:noreply, start_server()}
  end

  defp start_server do
    IO.puts "Stasrting HTTP server"
    server_pid = spawn_link(Servy.HttpServer, :start, [4000])
    Process.register(server_pid, :http_server)
    server_pid
  end

end
