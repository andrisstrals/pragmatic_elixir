defmodule Servy.VideoCam do
  @doc """
  Simulates sending a request to an external API
  to get a snapshot image from a video camera.
  """

  def get_snapshot(camera_name) do
    # TODO add code to send request to the external API

    # Sleep for 1 sec to simulate API call
    :timer.sleep(1000)

    # example response
    "#{camera_name}-snapshot-#{:rand.uniform(1000)}.jpg"
  end


end
