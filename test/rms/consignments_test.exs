defmodule Rms.ConsignmentsTest do
  use Rms.DataCase

  alias Rms.Consignments

  describe "tbl_consignments" do
    alias Rms.Consignments.Consignment

    @valid_attrs %{
      capture_date: "some capture_date",
      code: "some code",
      commodity: "some commodity",
      consignee: "some consignee",
      consigner: "some consigner",
      customer: "some customer",
      customer_ref: "some customer_ref",
      document_date: "some document_date",
      final_destination: "some final_destination",
      origin_station: "some origin_station",
      payer: "some payer",
      reporting_station: "some reporting_station",
      sale_order: "some sale_order",
      station_code: "some station_code",
      status: "some status",
      tariff_destination: "some tariff_destination",
      tariff_origin: "some tariff_origin"
    }
    @update_attrs %{
      capture_date: "some updated capture_date",
      code: "some updated code",
      commodity: "some updated commodity",
      consignee: "some updated consignee",
      consigner: "some updated consigner",
      customer: "some updated customer",
      customer_ref: "some updated customer_ref",
      document_date: "some updated document_date",
      final_destination: "some updated final_destination",
      origin_station: "some updated origin_station",
      payer: "some updated payer",
      reporting_station: "some updated reporting_station",
      sale_order: "some updated sale_order",
      station_code: "some updated station_code",
      status: "some updated status",
      tariff_destination: "some updated tariff_destination",
      tariff_origin: "some updated tariff_origin"
    }
    @invalid_attrs %{
      capture_date: nil,
      code: nil,
      commodity: nil,
      consignee: nil,
      consigner: nil,
      customer: nil,
      customer_ref: nil,
      document_date: nil,
      final_destination: nil,
      origin_station: nil,
      payer: nil,
      reporting_station: nil,
      sale_order: nil,
      station_code: nil,
      status: nil,
      tariff_destination: nil,
      tariff_origin: nil
    }

    def consignment_fixture(attrs \\ %{}) do
      {:ok, consignment} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Consignments.create_consignment()

      consignment
    end

    test "list_tbl_consignments/0 returns all tbl_consignments" do
      consignment = consignment_fixture()
      assert Consignments.list_tbl_consignments() == [consignment]
    end

    test "get_consignment!/1 returns the consignment with given id" do
      consignment = consignment_fixture()
      assert Consignments.get_consignment!(consignment.id) == consignment
    end

    test "create_consignment/1 with valid data creates a consignment" do
      assert {:ok, %Consignment{} = consignment} = Consignments.create_consignment(@valid_attrs)
      assert consignment.capture_date == "some capture_date"
      assert consignment.code == "some code"
      assert consignment.commodity == "some commodity"
      assert consignment.consignee == "some consignee"
      assert consignment.consigner == "some consigner"
      assert consignment.customer == "some customer"
      assert consignment.customer_ref == "some customer_ref"
      assert consignment.document_date == "some document_date"
      assert consignment.final_destination == "some final_destination"
      assert consignment.origin_station == "some origin_station"
      assert consignment.payer == "some payer"
      assert consignment.reporting_station == "some reporting_station"
      assert consignment.sale_order == "some sale_order"
      assert consignment.station_code == "some station_code"
      assert consignment.status == "some status"
      assert consignment.tariff_destination == "some tariff_destination"
      assert consignment.tariff_origin == "some tariff_origin"
    end

    test "create_consignment/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Consignments.create_consignment(@invalid_attrs)
    end

    test "update_consignment/2 with valid data updates the consignment" do
      consignment = consignment_fixture()

      assert {:ok, %Consignment{} = consignment} =
               Consignments.update_consignment(consignment, @update_attrs)

      assert consignment.capture_date == "some updated capture_date"
      assert consignment.code == "some updated code"
      assert consignment.commodity == "some updated commodity"
      assert consignment.consignee == "some updated consignee"
      assert consignment.consigner == "some updated consigner"
      assert consignment.customer == "some updated customer"
      assert consignment.customer_ref == "some updated customer_ref"
      assert consignment.document_date == "some updated document_date"
      assert consignment.final_destination == "some updated final_destination"
      assert consignment.origin_station == "some updated origin_station"
      assert consignment.payer == "some updated payer"
      assert consignment.reporting_station == "some updated reporting_station"
      assert consignment.sale_order == "some updated sale_order"
      assert consignment.station_code == "some updated station_code"
      assert consignment.status == "some updated status"
      assert consignment.tariff_destination == "some updated tariff_destination"
      assert consignment.tariff_origin == "some updated tariff_origin"
    end

    test "update_consignment/2 with invalid data returns error changeset" do
      consignment = consignment_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Consignments.update_consignment(consignment, @invalid_attrs)

      assert consignment == Consignments.get_consignment!(consignment.id)
    end

    test "delete_consignment/1 deletes the consignment" do
      consignment = consignment_fixture()
      assert {:ok, %Consignment{}} = Consignments.delete_consignment(consignment)
      assert_raise Ecto.NoResultsError, fn -> Consignments.get_consignment!(consignment.id) end
    end

    test "change_consignment/1 returns a consignment changeset" do
      consignment = consignment_fixture()
      assert %Ecto.Changeset{} = Consignments.change_consignment(consignment)
    end
  end
end
