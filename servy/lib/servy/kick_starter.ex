defmodule Servy.KickStarter do
  @moduledoc false

  use GenServer

  def start_link(_arg) do
    IO.puts "Starting the kickstarter"
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def get_server do
    GenServer.call(__MODULE__, :get_server)
  end

  def init(:ok) do
    Process.flag(:trap_exit, true)
    {:ok, start_server()}
  end

  def handle_info({:EXIT, state, reason}, state) do
    IO.puts "It seems like shit happened to HTTP server... reason:#{inspect reason} state:#{inspect state}"
    {:noreply, start_server()}
  end

  def handle_call(:get_server, _from, state) do
    {:reply, state, state}
  end


  defp start_server do
    IO.puts "Stasrting HTTP server"
    port = Application.get_env(:servy, :port)
    server_pid = spawn_link(Servy.HttpServer, :start, [port])
    Process.register(server_pid, :http_server)
    server_pid
  end

end
