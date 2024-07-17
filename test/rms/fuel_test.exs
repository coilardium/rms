defmodule Rms.FuelTest do
  use Rms.DataCase

  alias Rms.Fuel

  describe "tbl_fuel_rates" do
    alias Rms.Fuel.Rates

    @valid_attrs %{
      code: "some code",
      fuel_rate: "some fuel_rate",
      month: "some month",
      refueling_depo: "some refueling_depo",
      status: "some status"
    }
    @update_attrs %{
      code: "some updated code",
      fuel_rate: "some updated fuel_rate",
      month: "some updated month",
      refueling_depo: "some updated refueling_depo",
      status: "some updated status"
    }
    @invalid_attrs %{code: nil, fuel_rate: nil, month: nil, refueling_depo: nil, status: nil}

    def rates_fixture(attrs \\ %{}) do
      {:ok, rates} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Fuel.create_rates()

      rates
    end

    test "list_tbl_fuel_rates/0 returns all tbl_fuel_rates" do
      rates = rates_fixture()
      assert Fuel.list_tbl_fuel_rates() == [rates]
    end

    test "get_rates!/1 returns the rates with given id" do
      rates = rates_fixture()
      assert Fuel.get_rates!(rates.id) == rates
    end

    test "create_rates/1 with valid data creates a rates" do
      assert {:ok, %Rates{} = rates} = Fuel.create_rates(@valid_attrs)
      assert rates.code == "some code"
      assert rates.fuel_rate == "some fuel_rate"
      assert rates.month == "some month"
      assert rates.refueling_depo == "some refueling_depo"
      assert rates.status == "some status"
    end

    test "create_rates/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Fuel.create_rates(@invalid_attrs)
    end

    test "update_rates/2 with valid data updates the rates" do
      rates = rates_fixture()
      assert {:ok, %Rates{} = rates} = Fuel.update_rates(rates, @update_attrs)
      assert rates.code == "some updated code"
      assert rates.fuel_rate == "some updated fuel_rate"
      assert rates.month == "some updated month"
      assert rates.refueling_depo == "some updated refueling_depo"
      assert rates.status == "some updated status"
    end

    test "update_rates/2 with invalid data returns error changeset" do
      rates = rates_fixture()
      assert {:error, %Ecto.Changeset{}} = Fuel.update_rates(rates, @invalid_attrs)
      assert rates == Fuel.get_rates!(rates.id)
    end

    test "delete_rates/1 deletes the rates" do
      rates = rates_fixture()
      assert {:ok, %Rates{}} = Fuel.delete_rates(rates)
      assert_raise Ecto.NoResultsError, fn -> Fuel.get_rates!(rates.id) end
    end

    test "change_rates/1 returns a rates changeset" do
      rates = rates_fixture()
      assert %Ecto.Changeset{} = Fuel.change_rates(rates)
    end
  end
end
