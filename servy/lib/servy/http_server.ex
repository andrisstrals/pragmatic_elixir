defmodule Servy.HttpServer do
  @moduledoc false


  #server() ->
  #{ok, LSock} = gen_tcp:listen(5678, [binary, {packet, 0},
  #{active, false}]),
  #{ok, Sock} = gen_tcp:accept(LSock),
  #                           {ok, Bin} = do_recv(Sock, []),
  #ok = gen_tcp:close(Sock),
  #ok = gen_tcp:close(LSock),
  #Bin.

  #    def server do
  #      {:ok, lsock} = :gen_tcp.listen(5678, [:binary, packet: 0, active: false])
  #      {:ok, sock} = :gen_tcp.accept(lsock)
  #      {:ok, bin} = :gen_tcp.recv(sock, 0)
  #      :ok = :gen_tcp.close(sock)
  #      bin
  #
  #    end

  def start(port) when is_integer(port) and port > 1023 do
    # creates socket to listen for client connections
    {:ok, listen_socket} = :gen_tcp.listen(port, [:binary, packet: :raw, active: false])

    # Socket options:
    # :binary - open socket in binary mode and deliver data as binaries
    # packet: :raw - deliver the entire binary without doing any packet handling
    # active: false - receive data when we are ready by calling :gen_tcp.recv/2
    # reuseaddr: true - allows reusing the address if the listener crashes
    IO.puts "\n Listening for connection requests on port #{port}"
    accept_loop(listen_socket)

  end

  def accept_loop(listen_socket) do
    IO.puts "... waiting to accept client connection...\n"
    {:ok, client_socket} = :gen_tcp.accept(listen_socket)
    IO.puts(" connection accpted!\n")
    serve(client_socket)

    accept_loop(listen_socket)
  end

  def serve(client_socket) do
    client_socket
    |> read_request
    |> generate_response
    |> write_response(client_socket)
  end


  def read_request(client_socket) do
    {:ok, request} = :gen_tcp.recv(client_socket, 0)  #all available bytes

    IO.puts "- received request:\n#{request}"
    request
  end

  def generate_response(_request) do
    """
    HTTP/1.1 200 OK\r
    Content-Type: text/plain\r
    Content_Length: 8\r
    \r
    Hello!!!
    """
  end

  def write_response(response, client_socket) do
    :ok = :gen_tcp.send(client_socket, response)

    IO.puts "response sent: #{response}"

    :gen_tcp.close(client_socket)
  end
end