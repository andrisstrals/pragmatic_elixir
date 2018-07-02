defmodule HandlerTest do
  use ExUnit.Case
  doctest Servy.Handler
  alias Servy.Parser
  import Servy.Handler, only: [handle: 1]

  test "parses a list of header fields into a map" do
    header_lines = ["A: 1", "B: 2"]
    headers = Parser.parse_headers(header_lines)
    assert headers == %{"A" => "1", "B" => "2"}
  end

  test "GET /wildlife" do
    request = """
    GET /wildlife HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    response = handle(request)

    assert response == """
           HTTP/1.1 404 Not Found\r
           Content-Type: text/html\r
           Content-Length: 23\r
           \r
           No path /wildlife found
           """
  end

  test "GET /bears" do
    request = """
    GET /bears HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    response = handle(request)

    expected = """
    HTTP/1.1 200 OK
    Content-Type: text/html
    Content-Length: 335

    <h1>All The Bears</h1>

    <ul>
    		<li> Brutus - Grizzly</li>
    		<li> Iceman - Polar</li>
    		<li> Kenai - Grizzly</li>
    		<li> Paddington - Brown</li>
    		<li> Roscoe - Panda</li>
    		<li> Rosie - Black</li>
    		<li> Scarface - Grizzly</li>
    		<li> Smokey - Black</li>
    		<li> Snow - Polar</li>
    		<li> Teddy - Brown</li>
    </ul>

    """

    assert remove_whitespace(response) == remove_whitespace(expected)
  end

  test "GET /bears/3" do
    request = """
    GET /bears/3 HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    response = handle(request)

    expected = """
    HTTP/1.1 200 OK
    Content-Type: text/html
    Content-Length: 78

    <h1>Show Bear</h1>
    <p>
    Is Paddington hibernating? <strong>false</strong>
    </p>

    """

    assert remove_whitespace(response) == remove_whitespace(expected)
  end

  test "GET /about" do
    request = """
    GET /about HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    response = handle(request)

    expected = """
    HTTP/1.1 200 OK
    Content-Type: text/html
    Content-Length: 321

    <h1>Clark's Wildthings Refuge</h1>

    <blockquote>
    When we contemplate the whole globe as one great dewdrop, striped and dotted
    with continents and islands, flying through space with other stars all singing
    and shining together as one, the whole universe appears as an infinite storm of
     beauty. -- John Muir
    </blockquote>

    """

    assert remove_whitespace(response) == remove_whitespace(expected)
  end

  test "GET /bears/new" do
    request = """
    GET /bears/new HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    response = handle(request)

    expected = """
    HTTP/1.1 200 OK
    Content-Type: text/html
    Content-Length: 240

    <form action="/bears" method="POST">
      <p>
        Name:<br/>
        <input type="text" name="name">    
      </p>
      <p>
        Type:<br/>
        <input type="text" name="type">    
      </p>
      <p>
        <input type="submit" value="Create Bear">
      </p>
    </form>

    """

    assert remove_whitespace(response) == remove_whitespace(expected)
  end

  # -------------------------------

  test "POST /bears" do
    request = """
    POST /bears HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    Content-Type: application/x-www-form-urlencoded\r
    Content-Length: 21\r
    \r
    name=Ballo&type=Browny
    """

    response = handle(request)

    expected = """
    HTTP/1.1 201 Created
    Content-Type: text/html
    Content-Length: 34

    Created a Browny bear named Ballo!
    """

    assert remove_whitespace(response) == remove_whitespace(expected)
  end

  defp remove_whitespace(text) do
    String.replace(text, ~r{\s}, "")
  end
end
