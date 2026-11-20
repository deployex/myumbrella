defmodule App1.WorkerTest do
  use ExUnit.Case, async: true

  alias App1.Worker

  test "tick_count increments on each :schedule tick" do
    assert Worker.tick_count() >= 0

    send(Process.whereis(Worker), :schedule)

    count = Worker.tick_count()
    send(Process.whereis(Worker), :schedule)

    assert Worker.tick_count() == count + 1
  end

  test "code_change adds tick_count to pre-upgrade state missing that key" do
    old_state = %{interval: 2_000}

    assert {:ok, %{interval: 2_000, tick_count: 0}} = Worker.code_change("0.4.1", old_state, [])
  end

  test "code_change preserves an existing tick_count" do
    state = %{interval: 2_000, tick_count: 7}

    assert {:ok, ^state} = Worker.code_change("0.4.1", state, [])
  end
end
