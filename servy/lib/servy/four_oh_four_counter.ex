defmodule Servy.FourOhFourCounter do
  @moduledoc false

  @pid :bump_server


  #  Client interface functions
  def start do
    IO.puts "Starting the bump count server..."
    pid = spawn(__MODULE__, :listen_loop, [%{}])
    Process.register(pid, @pid)
    pid
  end

  def bump_count(path) do
    send @pid, {self(), :bump_count, path}
    receive do {:response, status} -> status end
  end


  def get_count(path) do
    send @pid, {self(), :get_count, path}
    receive do {:response, status} -> status end
  end


  def get_counts do
    send @pid, {self(), :get_counts}
    receive do {:response, status} -> status end
  end






  # Server

  def listen_loop(state) do
    IO.puts "\nWaiting for a message..."

    receive do
      {sender, :bump_count, path} ->
        #        count = updateCount(Map.fetch(state, path))
        count = case Map.fetch(state, path) do
          {:ok, cnt} -> cnt + 1
          :error -> 1
        end

        new_state = Map.put(state, path, count)
        send sender, {:response, count}
        listen_loop(new_state)

      {sender, :get_count, path} ->
        count = case Map.fetch(Map.take(state, [path]), path) do
          {:ok, cnt} -> cnt
          :error -> 0
        end
        send sender, {:response, count}
        listen_loop(state)

      {sender, :get_counts} ->
        send sender, {:response, state}
        listen_loop(state)

      unexpected ->
        IO.puts "Unexpected message #{IO.inspect(unexpected)}"
        listen_loop(state)

    end
  end


end
