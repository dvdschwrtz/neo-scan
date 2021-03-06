defmodule NeoscanMonitor.Utils do
  alias NeoscanSync.Blockchain

 @seeds [
    "http://seed1.cityofzion.io:8080",
    "http://seed2.cityofzion.io:8080",
    "http://seed3.cityofzion.io:8080",
    "http://seed4.cityofzion.io:8080",
    "http://seed5.cityofzion.io:8080",
    "http://api.otcgo.cn:10332",
    "http://seed1.neo.org:10332",
    "http://seed2.neo.org:10332",
    "http://seed3.neo.org:10332",
    "http://seed4.neo.org:10332",
    "http://seed5.neo.org:10332"
  ]

  def load() do
    data = @seeds
    |> Stream.map(fn x -> {x, Blockchain.get_current_height(x)} end)
    |> Stream.filter( fn { _x , result } -> evaluate_result(result)  end)
    |> Stream.map(fn { x , { :ok, height } } -> { x, height } end)
    |> Enum.to_list()

    height = filter_height(data)
    %{:nodes => filter_nodes(data, height), :height => {:ok, height}, :data => data}
  end

  defp filter_nodes(data, height) do
    data
    |> Stream.filter(fn { _url, hgt } -> hgt == height end)
    |> Stream.map(fn {url, _height} -> url end)
    |> Enum.to_list
  end

  defp filter_height(data) do
    {height , _count} = data
      |> Stream.map(fn { _url, height } -> height end)
      |> Enum.reduce(%{}, fn(height, acc) -> Map.update(acc, height, 1, &(&1 + 1)) end)
      |> Enum.to_list
      |> Enum.max_by(fn { _height , count} -> count end)
    height
  end

  defp evaluate_result ({ :ok , _height}) do
    true
  end

  defp evaluate_result ({ :error , _height}) do
    false
  end

end
