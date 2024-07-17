defmodule Rms.ExchangeRatesTest do
  use Rms.DataCase

  alias Rms.ExchangeRates

  describe "tbl_exchange_rate" do
    alias Rms.ExchangeRates.ExchangeRate

    @valid_attrs %{
      currency_code: "some currency_code",
      exchange_rate: "some exchange_rate",
      start_date: "some start_date",
      symbol: "some symbol"
    }
    @update_attrs %{
      currency_code: "some updated currency_code",
      exchange_rate: "some updated exchange_rate",
      start_date: "some updated start_date",
      symbol: "some updated symbol"
    }
    @invalid_attrs %{currency_code: nil, exchange_rate: nil, start_date: nil, symbol: nil}

    def exchange_rate_fixture(attrs \\ %{}) do
      {:ok, exchange_rate} =
        attrs
        |> Enum.into(@valid_attrs)
        |> ExchangeRates.create_exchange_rate()

      exchange_rate
    end

    test "list_tbl_exchange_rate/0 returns all tbl_exchange_rate" do
      exchange_rate = exchange_rate_fixture()
      assert ExchangeRates.list_tbl_exchange_rate() == [exchange_rate]
    end

    test "get_exchange_rate!/1 returns the exchange_rate with given id" do
      exchange_rate = exchange_rate_fixture()
      assert ExchangeRates.get_exchange_rate!(exchange_rate.id) == exchange_rate
    end

    test "create_exchange_rate/1 with valid data creates a exchange_rate" do
      assert {:ok, %ExchangeRate{} = exchange_rate} =
               ExchangeRates.create_exchange_rate(@valid_attrs)

      assert exchange_rate.currency_code == "some currency_code"
      assert exchange_rate.exchange_rate == "some exchange_rate"
      assert exchange_rate.start_date == "some start_date"
      assert exchange_rate.symbol == "some symbol"
    end

    test "create_exchange_rate/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = ExchangeRates.create_exchange_rate(@invalid_attrs)
    end

    test "update_exchange_rate/2 with valid data updates the exchange_rate" do
      exchange_rate = exchange_rate_fixture()

      assert {:ok, %ExchangeRate{} = exchange_rate} =
               ExchangeRates.update_exchange_rate(exchange_rate, @update_attrs)

      assert exchange_rate.currency_code == "some updated currency_code"
      assert exchange_rate.exchange_rate == "some updated exchange_rate"
      assert exchange_rate.start_date == "some updated start_date"
      assert exchange_rate.symbol == "some updated symbol"
    end

    test "update_exchange_rate/2 with invalid data returns error changeset" do
      exchange_rate = exchange_rate_fixture()

      assert {:error, %Ecto.Changeset{}} =
               ExchangeRates.update_exchange_rate(exchange_rate, @invalid_attrs)

      assert exchange_rate == ExchangeRates.get_exchange_rate!(exchange_rate.id)
    end

    test "delete_exchange_rate/1 deletes the exchange_rate" do
      exchange_rate = exchange_rate_fixture()
      assert {:ok, %ExchangeRate{}} = ExchangeRates.delete_exchange_rate(exchange_rate)

      assert_raise Ecto.NoResultsError, fn ->
        ExchangeRates.get_exchange_rate!(exchange_rate.id)
      end
    end

    test "change_exchange_rate/1 returns a exchange_rate changeset" do
      exchange_rate = exchange_rate_fixture()
      assert %Ecto.Changeset{} = ExchangeRates.change_exchange_rate(exchange_rate)
    end
  end
end
