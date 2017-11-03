defmodule NeoscanMonitor.Server do
  @moduledoc """
  GenServer module responsable to retrive blocks, states, transactions
  and assets. Common interface to handle it is NeoscanMonitor.
  Api module(look there for more info)
  The state is updated using handle_info(:state_update, state)
  """

  use GenServer
  alias Neoscan.ChainAssets

  def start_link(callback) do
    GenServer.start_link(__MODULE__, callback, name: __MODULE__)
  end

  def init(callback) do
    IO.puts "callback"
    IO.inspect callback
    {:ok, %{ "callback" => callback }}
  end

  def handle_info({:state_update, new_state}, state) do
    new_state_with_callback = Map.put(new_state, "callback", state.callback)
    schedule_work()
    {:noreply, new_state_with_callback}
  end

  def handle_info(:broadcast, state) do
    schedule_work() # Reschedule once more
    data = Map.delete(state, "callback")
    state.callback.(data)
    {:noreply, state}
  end

  def handle_call(:nodes, _from, state) do
    {:reply, state.monitor.nodes, state}
  end

  def handle_call(:height, _from, state) do
    {:reply, state.monitor.height, state}
  end

  def handle_call(:transactions, _from, state) do
    {:reply, state.transactions, state}
  end

  def handle_call(:blocks, _from, state) do
    {:reply, state.blocks, state}
  end

  def handle_call(:assets, _from, state) do
    {:reply, state.assets, state}
  end

  def handle_call({:asset, hash}, _from, state) do
    asset = Enum.find(state.assets, fn %{:txid => txid} -> txid == hash end)

    {:reply, asset, state}
  end

  def handle_call({:asset_name, hash}, _from, state) do
    name = Enum.find(state.assets, fn %{:txid => txid} -> txid == hash end)
            |> Map.get(:name)
            |> ChainAssets.filter_name
    {:reply, name, state}
  end

  def handle_call(:addresses, _from, state) do
    {:reply, state.addresses, state}
  end

  def handle_call(:contracts, _from, state) do
    {:reply, state.contracts, state}
  end

  def handle_call(:data, _from, state) do
    {:reply, state.monitor.data, state}
  end

  def handle_call(:price, _from, state) do
    {:reply, state.price, state}
  end

  def handle_call(:stats, _from, state) do
    {:reply, state.stats, state}
  end

  defp schedule_work do
    Process.send_after(self(), :broadcast, 10_000) # In 10 seconds
  end
end
