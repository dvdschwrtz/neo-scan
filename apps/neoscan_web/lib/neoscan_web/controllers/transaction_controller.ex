defmodule NeoscanWeb.TransactionController do
  use NeoscanWeb, :controller

  alias Neoscan.Transactions

  def index(conn, %{"txid" => transaction_hash}) do
    transaction = Transactions.get_transaction_by_hash_for_view(transaction_hash)
    render(conn, "transaction.html", transaction: transaction)
  end

  def round_or_not(value) do
    float = case  Kernel.is_float(value) do
      true ->
        value
      false ->
        case Kernel.is_integer(value) do
          true ->
            value
          false ->
          {num, _} = Float.parse(value)
          num
        end
    end

    cond do
      Kernel.round(float) == float ->
        Kernel.round(float)
      Kernel.round(float) != float ->
        value
    end
  end

end
