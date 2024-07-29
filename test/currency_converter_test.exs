defmodule CurrencyConverterTest do
  use ExUnit.Case

  alias CurrencyConverter

  describe "convert" do
    test "convert USD to BRL" do
      assert {:ok, 50.0} = CurrencyConverter.convert(10, "usd", "br")
    end

    test "convert USD to ETH" do
      assert {:ok, 0.166666666666666666} = CurrencyConverter.convert(500, "usd", "eth")
    end

    test "convert USD to BTC" do
      assert {:ok, 0.578390805110913} = CurrencyConverter.convert(34703.44830665478, "usd", "btc")
    end

    test "convert USD to IC" do
      assert {:ok, 0.000005} = CurrencyConverter.convert(5, "usd", "ic")
    end

    test "convert BRL to USD" do
      assert {:ok, 32_866.27327837584} =
               CurrencyConverter.convert(164_331.3663918792, "br", "usd")
    end

    test "convert BRL to ETH" do
      assert {:ok, 0.166666666666666666} = CurrencyConverter.convert(2500, "br", "eth")
    end

    test "convert BRL to BTC" do
      assert {:ok, 0.008333333333333333} = CurrencyConverter.convert(2500, "br", "btc")
    end

    test "convert BRL to IC" do
      assert {:ok, 0.002} = CurrencyConverter.convert(10000, "br", "ic")
    end

    test "convert ETH to BTC" do
      assert {:ok, 1.0} = CurrencyConverter.convert(20, "eth", "btc")
    end

    test "convert ETH to IC" do
      assert {:ok, 0.15} = CurrencyConverter.convert(50, "eth", "ic")
    end

    test "convert ETH to USD" do
      assert {:ok, 75000.0} = CurrencyConverter.convert(25, "eth", "usd")
    end

    test "convert ETH to BRL" do
      assert {:ok, 15000.0} = CurrencyConverter.convert(1, "eth", "br")
    end

    test "convert BTC to ETH" do
      assert {:ok, 3_286_627.327837584} =
               CurrencyConverter.convert(164_331.3663918792, "btc", "eth")
    end

    test "convert BTC to IC" do
      assert {:ok, 2082.2068983992867} = CurrencyConverter.convert(34703.44830665478, "btc", "ic")
    end

    test "convert BTC to USD" do
      assert {:ok, 0.009} = CurrencyConverter.convert(0.00000015, "btc", "usd")
    end

    test "convert BTC to BRL" do
      assert {:ok, 300_000.0} = CurrencyConverter.convert(1, "btc", "br")
    end

    test "convert IC to ETH" do
      assert {:ok, 85.0} = CurrencyConverter.convert(0.255, "ic", "eth")
    end

    test "convert IC to BTC" do
      assert {:ok, 0.13333333333333333} = CurrencyConverter.convert(0.008, "ic", "btc")
    end

    test "convert IC to USD" do
      assert {:ok, 25_500_000.0} = CurrencyConverter.convert(25.5, "ic", "usd")
    end

    test "convert IC to BRL" do
      assert {:ok, 127_500_000.0} = CurrencyConverter.convert(25.5, "ic", "br")
    end

    test "should return an error when the source currency is not supported" do
      assert {:error, "Currency not supported: XYZ"} = CurrencyConverter.convert(50, "XYZ", "usd")
    end

    test "should return an error when the destination currency is not supported" do
      assert {:error, "Currency not supported: XYZ"} = CurrencyConverter.convert(50, "usd", "XYZ")
    end
  end
end
