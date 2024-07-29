defmodule App.Utils.CurrencyConverter do
  @exchange_rates %{
    "USD" => Decimal.new(1),
    "BRL" => Decimal.div(Decimal.new(1), Decimal.new(5)),
    "ETH" => Decimal.new(3000),
    "BTC" => Decimal.new(60_000),
    "IC" => Decimal.new(1_000_000)
  }

  @spec convert(float, String.t(), String.t()) :: {:ok, float} | {:error, String.t()}
  def convert(amount, from_currency, to_currency) do
    with {:ok, from_rate} <- get_rate(from_currency),
         {:ok, to_rate} <- get_rate(to_currency) do
      decimal_amount = convert_to_decimal(amount)
      usd_amount = Decimal.mult(decimal_amount, from_rate)
      result = Decimal.div(usd_amount, to_rate)
      {:ok, Decimal.to_float(result)}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp get_rate(currency) do
    case Map.fetch(@exchange_rates, currency) do
      {:ok, rate} -> {:ok, rate}
      :error -> {:error, "Currency not supported: #{currency}"}
    end
  end

  @spec convert_to_decimal(integer | float) :: {:ok, Decimal.t()}
  defp convert_to_decimal(value) when is_integer(value) do
    Decimal.new(value)
  end

  defp convert_to_decimal(value) when is_float(value) do
    Decimal.from_float(value)
  end
end
