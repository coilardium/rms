defmodule Rms.SytemUtilitiesTest do
  use Rms.DataCase

  alias Rms.SytemUtilities

  describe "tbl_haulage_rates" do
    alias Rms.SytemUtilities.HaulageRate

    @valid_attrs %{
      distance: "120.5",
      rate: "120.5",
      rate_type: "some rate_type",
      start_date: ~D[2010-04-17],
      status: "some status"
    }
    @update_attrs %{
      distance: "456.7",
      rate: "456.7",
      rate_type: "some updated rate_type",
      start_date: ~D[2011-05-18],
      status: "some updated status"
    }
    @invalid_attrs %{distance: nil, rate: nil, rate_type: nil, start_date: nil, status: nil}

    def haulage_rate_fixture(attrs \\ %{}) do
      {:ok, haulage_rate} =
        attrs
        |> Enum.into(@valid_attrs)
        |> SytemUtilities.create_haulage_rate()

      haulage_rate
    end

    test "list_tbl_haulage_rates/0 returns all tbl_haulage_rates" do
      haulage_rate = haulage_rate_fixture()
      assert SytemUtilities.list_tbl_haulage_rates() == [haulage_rate]
    end

    test "get_haulage_rate!/1 returns the haulage_rate with given id" do
      haulage_rate = haulage_rate_fixture()
      assert SytemUtilities.get_haulage_rate!(haulage_rate.id) == haulage_rate
    end

    test "create_haulage_rate/1 with valid data creates a haulage_rate" do
      assert {:ok, %HaulageRate{} = haulage_rate} =
               SytemUtilities.create_haulage_rate(@valid_attrs)

      assert haulage_rate.distance == Decimal.new("120.5")
      assert haulage_rate.rate == Decimal.new("120.5")
      assert haulage_rate.rate_type == "some rate_type"
      assert haulage_rate.start_date == ~D[2010-04-17]
      assert haulage_rate.status == "some status"
    end

    test "create_haulage_rate/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = SytemUtilities.create_haulage_rate(@invalid_attrs)
    end

    test "update_haulage_rate/2 with valid data updates the haulage_rate" do
      haulage_rate = haulage_rate_fixture()

      assert {:ok, %HaulageRate{} = haulage_rate} =
               SytemUtilities.update_haulage_rate(haulage_rate, @update_attrs)

      assert haulage_rate.distance == Decimal.new("456.7")
      assert haulage_rate.rate == Decimal.new("456.7")
      assert haulage_rate.rate_type == "some updated rate_type"
      assert haulage_rate.start_date == ~D[2011-05-18]
      assert haulage_rate.status == "some updated status"
    end

    test "update_haulage_rate/2 with invalid data returns error changeset" do
      haulage_rate = haulage_rate_fixture()

      assert {:error, %Ecto.Changeset{}} =
               SytemUtilities.update_haulage_rate(haulage_rate, @invalid_attrs)

      assert haulage_rate == SytemUtilities.get_haulage_rate!(haulage_rate.id)
    end

    test "delete_haulage_rate/1 deletes the haulage_rate" do
      haulage_rate = haulage_rate_fixture()
      assert {:ok, %HaulageRate{}} = SytemUtilities.delete_haulage_rate(haulage_rate)

      assert_raise Ecto.NoResultsError, fn ->
        SytemUtilities.get_haulage_rate!(haulage_rate.id)
      end
    end

    test "change_haulage_rate/1 returns a haulage_rate changeset" do
      haulage_rate = haulage_rate_fixture()
      assert %Ecto.Changeset{} = SytemUtilities.change_haulage_rate(haulage_rate)
    end
  end
end
