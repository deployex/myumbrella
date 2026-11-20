defmodule App2.Worker do
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

    {:ok, %{interval: interval, last_tick_at: nil}}
  end

  @impl true
  def handle_info(:schedule, state) do
    schedule_new_deployment(state.interval)

    last_tick_at = DateTime.utc_now()

    Logger.info(
      "Running #{__MODULE__} Scheduler (/•ิ_•ิ) 🔥 (╯°□°)╯ 🔥🔥🔥🔥🔥  last_tick_at=#{last_tick_at}"
    )

    {:noreply, %{state | last_tick_at: last_tick_at}}
  end

  @impl true
  def handle_call(:last_tick_at, _from, state) do
    {:reply, state.last_tick_at, state}
  end

  # Runs when a hot upgrade installs a version whose state shape changed.
  # Older state has no :last_tick_at key, so it is added rather than assumed.
  @impl true
  def code_change(_old_vsn, state, _extra) do
    Logger.info("Hot-upgrading #{__MODULE__} state")

    {:ok, Map.put_new(state, :last_tick_at, nil)}
  end

  ### ==========================================================================
  ### Public API
  ### ==========================================================================

  def last_tick_at, do: GenServer.call(__MODULE__, :last_tick_at)

  ### ==========================================================================
  ### Private functions
  ### ==========================================================================

  defp schedule_new_deployment(timeout), do: Process.send_after(self(), :schedule, timeout)
end
