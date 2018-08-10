defmodule Servy.SensorServer do
  @moduledoc false

  @name :sensor_server

  defmodule State do
    defstruct sensor_data: %{}, refresh_interval: :timer.seconds(5)
  end

  use GenServer

  def start do
    GenServer.start(__MODULE__, %State{}, name: @name)
  end

  def get_sensor_data do
    GenServer.call(@name, :get_sensor_data)
  end

  def set_refresh_interval(interval) do
    GenServer.cast(@name, {:set_interval, interval})
  end


#  Server callbacks

  def init(state) do
    initial_data = run_tasks_to_get_sensor_data()
    schedule_refresh(state.refresh_interval)
    {:ok, %{state | sensor_data: initial_data}}
  end

  def handle_call(:get_sensor_data, _from, state) do
    {:reply, state.sensor_data, state}
  end

  def handle_cast( {:set_interval, interval}, state) do
    {:noreply, %{ state | refresh_interval: interval}}
  end

  def handle_info(:refresh, state) do
    IO.puts "Refreshing sensor data cache..."
    sensor_data = run_tasks_to_get_sensor_data()
    schedule_refresh(state.refresh_interval)
    {:noreply, %{state | sensor_data: sensor_data}}
  end

  defp run_tasks_to_get_sensor_data do
    IO.puts "Running tasks to get sensor data... #{Time.utc_now()}"
    task = Task.async(fn -> Servy.Tracker.get_location("bigfoot") end)

    snapshots =
      ["cam-1", "cam-2", "cam-3"]
      |> Enum.map(&Task.async(fn -> Servy.VideoCam.get_snapshot(&1) end))
      |> Enum.map(&Task.await/1)

    where_is_bigfoot = Task.await(task)

    %{snapshots: snapshots, location: where_is_bigfoot}
  end

  defp schedule_refresh(refresh_interval) do
    Process.send_after(self(), :refresh, refresh_interval)  #direct message; handled in handle_info callback
  end
end