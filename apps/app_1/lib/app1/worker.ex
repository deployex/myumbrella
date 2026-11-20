defmodule App1.Worker do
  @moduledoc false

  use GenServer
  require Logger

  ### ==========================================================================
  ### Callback functions
  ### ==========================================================================

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init(_args) do
    Logger.info("Initialising App1 server")

    interval = 2_000

    schedule_new_deployment(interval)

    {:ok, %{interval: interval, tick_count: 0}}
  end

  @impl true
  def handle_info(:schedule, state) do
    schedule_new_deployment(state.interval)

    tick_count = state.tick_count + 1

    Logger.info("Running #{__MODULE__} Scheduler (/•ิ_•ิ) 🔥🔥 tick=#{tick_count}")

    {:noreply, %{state | tick_count: tick_count}}
  end

  @impl true
  def handle_call(:tick_count, _from, state) do
    {:reply, state.tick_count, state}
  end

  # Runs when a hot upgrade installs a version whose state shape changed.
  # Older state has no :tick_count key, so it is added rather than assumed.
  @impl true
  def code_change(_old_vsn, state, _extra) do
    Logger.info("Hot-upgrading #{__MODULE__} state")

    {:ok, Map.put_new(state, :tick_count, 0)}
  end

  ### ==========================================================================
  ### Public API
  ### ==========================================================================

  def tick_count, do: GenServer.call(__MODULE__, :tick_count)

  ### ==========================================================================
  ### Private functions
  ### ==========================================================================

  defp schedule_new_deployment(timeout), do: Process.send_after(self(), :schedule, timeout)
end
