defmodule CurrencyConverterTest do
  use ExUnit.Case

  alias CurrencyConverter

  describe "convert" do
    test "convert USD to BRL" do
      assert {:ok, 50.0} = CurrencyConverter.convert(10, "USD", "BRL")
    end

    test "convert USD to ETH" do
      assert {:ok, 0.166666666666666666} = CurrencyConverter.convert(500, "USD", "ETH")
    end

    test "convert USD to BTC" do
      assert {:ok, 0.578390805110913} = CurrencyConverter.convert(34703.44830665478, "USD", "BTC")
    end

    test "convert USD to IC" do
      assert {:ok, 0.000005} = CurrencyConverter.convert(5, "USD", "IC")
    end

    test "convert BRL to USD" do
      assert {:ok, 32_866.27327837584} = CurrencyConverter.convert(164331.3663918792, "BRL", "USD")
    end

    test "convert BRL to ETH" do
      assert {:ok, 0.166666666666666666} = CurrencyConverter.convert(2500, "BRL", "ETH")
    end

    test "convert BRL to BTC" do
      assert {:ok, 0.008333333333333333} = CurrencyConverter.convert(2500, "BRL", "BTC")
    end

    test "convert BRL to IC" do
      assert {:ok, 0.002} = CurrencyConverter.convert(10000, "BRL", "IC")
    end

    test "convert ETH to BTC" do
      assert {:ok, 1.0} = CurrencyConverter.convert(20, "ETH", "BTC")
    end

    test "convert ETH to IC" do
      assert {:ok, 0.15} = CurrencyConverter.convert(50, "ETH", "IC")
    end

    test "convert ETH to USD" do
      assert {:ok, 75000.0} = CurrencyConverter.convert(25, "ETH", "USD")
    end

    test "convert ETH to BRL" do
      assert {:ok, 15000.0} = CurrencyConverter.convert(1, "ETH", "BRL")
    end

    test "convert BTC to ETH" do
      assert {:ok, 3286627.327837584} = CurrencyConverter.convert(164331.3663918792, "BTC", "ETH")
    end

    test "convert BTC to IC" do
      assert {:ok, 2082.2068983992867} = CurrencyConverter.convert(34703.44830665478, "BTC", "IC")
    end

    test "convert BTC to USD" do
      assert {:ok, 0.009} = CurrencyConverter.convert(0.00000015, "BTC", "USD")
    end

    test "convert BTC to BRL" do
      assert {:ok, 300000.0} = CurrencyConverter.convert(1, "BTC", "BRL")
    end

    test "convert IC to ETH" do
      assert {:ok, 85.0} = CurrencyConverter.convert(0.255, "IC", "ETH")
    end

    test "convert IC to BTC" do
      assert {:ok, 0.13333333333333333} = CurrencyConverter.convert(0.008, "IC", "BTC")
    end

    test "convert IC to USD" do
      assert {:ok, 25500000.0} = CurrencyConverter.convert(25.5, "IC", "USD")
    end

    test "convert IC to BRL" do
      assert {:ok, 127500000.0} = CurrencyConverter.convert(25.5, "IC", "BRL")
    end

    test "should return an error when the source currency is not supported" do
      assert {:error, "Currency not supported: XYZ"} = CurrencyConverter.convert(50, "XYZ", "USD")
    end

    test "should return an error when the destination currency is not supported" do
      assert {:error, "Currency not supported: XYZ"} = CurrencyConverter.convert(50, "USD", "XYZ")
    end
  end
end
