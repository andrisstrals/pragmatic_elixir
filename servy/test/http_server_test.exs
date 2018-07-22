defmodule HttpServerTest do
  use ExUnit.Case

  test "check server response" do
    server = spawn(Servy.HttpServer, :start, [4000])

    request = """
    GET /bears HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    response = Servy.HttpClient.send_request(request)
    assert response== """
           HTTP/1.1 200 OK\r
           Content-Type: text/html\r
           Content-Length: 335\r
           \r
           <h1>All The Bears</h1>\n\n<ul>\n\t\n\t\t<li> Brutus - Grizzly</li>\n\t\n\t\t<li> Iceman - Polar</li>\n\t\n\t\t<li> Kenai - Grizzly</li>\n\t\n\t\t<li> Paddington - Brown</li>\n\t\n\t\t<li> Roscoe - Panda</li>\n\t\n\t\t<li> Rosie - Black</li>\n\t\n\t\t<li> Scarface - Grizzly</li>\n\t\n\t\t<li> Smokey - Black</li>\n\t\n\t\t<li> Snow - Polar</li>\n\t\n\t\t<li> Teddy - Brown</li>\n\t\n</ul>\n\n
           """

  end
end