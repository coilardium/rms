defmodule Rms.TariffLinesTest do
  use Rms.DataCase

  alias Rms.TariffLines

  describe "tbl_tariff_line" do
    alias Rms.TariffLines.TariffLine

    @valid_attrs %{
      active_from: "some active_from",
      client: "some client",
      commodity: "some commodity",
      currency: "some currency",
      destination: "some destination",
      nll_2005: 120.5,
      nlpi: 120.5,
      origin: "some origin",
      others: 120.5,
      payment_type: "some payment_type",
      rsz: 120.5,
      surcharge: "some surcharge",
      tfr: 120.5,
      total: 120.5,
      tzr: 120.5,
      tzr_project: 120.5
    }
    @update_attrs %{
      active_from: "some updated active_from",
      client: "some updated client",
      commodity: "some updated commodity",
      currency: "some updated currency",
      destination: "some updated destination",
      nll_2005: 456.7,
      nlpi: 456.7,
      origin: "some updated origin",
      others: 456.7,
      payment_type: "some updated payment_type",
      rsz: 456.7,
      surcharge: "some updated surcharge",
      tfr: 456.7,
      total: 456.7,
      tzr: 456.7,
      tzr_project: 456.7
    }
    @invalid_attrs %{
      active_from: nil,
      client: nil,
      commodity: nil,
      currency: nil,
      destination: nil,
      nll_2005: nil,
      nlpi: nil,
      origin: nil,
      others: nil,
      payment_type: nil,
      rsz: nil,
      surcharge: nil,
      tfr: nil,
      total: nil,
      tzr: nil,
      tzr_project: nil
    }

    def tariff_line_fixture(attrs \\ %{}) do
      {:ok, tariff_line} =
        attrs
        |> Enum.into(@valid_attrs)
        |> TariffLines.create_tariff_line()

      tariff_line
    end

    test "list_tbl_tariff_line/0 returns all tbl_tariff_line" do
      tariff_line = tariff_line_fixture()
      assert TariffLines.list_tbl_tariff_line() == [tariff_line]
    end

    test "get_tariff_line!/1 returns the tariff_line with given id" do
      tariff_line = tariff_line_fixture()
      assert TariffLines.get_tariff_line!(tariff_line.id) == tariff_line
    end

    test "create_tariff_line/1 with valid data creates a tariff_line" do
      assert {:ok, %TariffLine{} = tariff_line} = TariffLines.create_tariff_line(@valid_attrs)
      assert tariff_line.active_from == "some active_from"
      assert tariff_line.client == "some client"
      assert tariff_line.commodity == "some commodity"
      assert tariff_line.currency == "some currency"
      assert tariff_line.destination == "some destination"
      assert tariff_line.nll_2005 == 120.5
      assert tariff_line.nlpi == 120.5
      assert tariff_line.origin == "some origin"
      assert tariff_line.others == 120.5
      assert tariff_line.payment_type == "some payment_type"
      assert tariff_line.rsz == 120.5
      assert tariff_line.surcharge == "some surcharge"
      assert tariff_line.tfr == 120.5
      assert tariff_line.total == 120.5
      assert tariff_line.tzr == 120.5
      assert tariff_line.tzr_project == 120.5
    end

    test "create_tariff_line/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = TariffLines.create_tariff_line(@invalid_attrs)
    end

    test "update_tariff_line/2 with valid data updates the tariff_line" do
      tariff_line = tariff_line_fixture()

      assert {:ok, %TariffLine{} = tariff_line} =
               TariffLines.update_tariff_line(tariff_line, @update_attrs)

      assert tariff_line.active_from == "some updated active_from"
      assert tariff_line.client == "some updated client"
      assert tariff_line.commodity == "some updated commodity"
      assert tariff_line.currency == "some updated currency"
      assert tariff_line.destination == "some updated destination"
      assert tariff_line.nll_2005 == 456.7
      assert tariff_line.nlpi == 456.7
      assert tariff_line.origin == "some updated origin"
      assert tariff_line.others == 456.7
      assert tariff_line.payment_type == "some updated payment_type"
      assert tariff_line.rsz == 456.7
      assert tariff_line.surcharge == "some updated surcharge"
      assert tariff_line.tfr == 456.7
      assert tariff_line.total == 456.7
      assert tariff_line.tzr == 456.7
      assert tariff_line.tzr_project == 456.7
    end

    test "update_tariff_line/2 with invalid data returns error changeset" do
      tariff_line = tariff_line_fixture()

      assert {:error, %Ecto.Changeset{}} =
               TariffLines.update_tariff_line(tariff_line, @invalid_attrs)

      assert tariff_line == TariffLines.get_tariff_line!(tariff_line.id)
    end

    test "delete_tariff_line/1 deletes the tariff_line" do
      tariff_line = tariff_line_fixture()
      assert {:ok, %TariffLine{}} = TariffLines.delete_tariff_line(tariff_line)
      assert_raise Ecto.NoResultsError, fn -> TariffLines.get_tariff_line!(tariff_line.id) end
    end

    test "change_tariff_line/1 returns a tariff_line changeset" do
      tariff_line = tariff_line_fixture()
      assert %Ecto.Changeset{} = TariffLines.change_tariff_line(tariff_line)
    end
  end
end
