defmodule App2.WorkerTest do
  use ExUnit.Case, async: true

  alias App2.Worker

  test "last_tick_at is set after a :schedule tick" do
    assert Worker.last_tick_at() == nil or match?(%DateTime{}, Worker.last_tick_at())

    send(Process.whereis(Worker), :schedule)

    assert %DateTime{} = Worker.last_tick_at()
  end

  test "code_change adds last_tick_at to pre-upgrade state missing that key" do
    old_state = %{interval: 2_000}

    assert {:ok, %{interval: 2_000, last_tick_at: nil}} = Worker.code_change("0.4.1", old_state, [])
  end

  test "code_change preserves an existing last_tick_at" do
    now = DateTime.utc_now()
    state = %{interval: 2_000, last_tick_at: now}

    assert {:ok, ^state} = Worker.code_change("0.4.1", state, [])
  end
end
