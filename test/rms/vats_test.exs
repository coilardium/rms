defmodule Rms.VatsTest do
  use Rms.DataCase

  alias Rms.Vats

  describe "tbl_vat" do
    alias Rms.Vats.Vat

    @valid_attrs %{rate: "some rate", status: "some status"}
    @update_attrs %{rate: "some updated rate", status: "some updated status"}
    @invalid_attrs %{rate: nil, status: nil}

    def vat_fixture(attrs \\ %{}) do
      {:ok, vat} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Vats.create_vat()

      vat
    end

    test "list_tbl_vat/0 returns all tbl_vat" do
      vat = vat_fixture()
      assert Vats.list_tbl_vat() == [vat]
    end

    test "get_vat!/1 returns the vat with given id" do
      vat = vat_fixture()
      assert Vats.get_vat!(vat.id) == vat
    end

    test "create_vat/1 with valid data creates a vat" do
      assert {:ok, %Vat{} = vat} = Vats.create_vat(@valid_attrs)
      assert vat.rate == "some rate"
      assert vat.status == "some status"
    end

    test "create_vat/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Vats.create_vat(@invalid_attrs)
    end

    test "update_vat/2 with valid data updates the vat" do
      vat = vat_fixture()
      assert {:ok, %Vat{} = vat} = Vats.update_vat(vat, @update_attrs)
      assert vat.rate == "some updated rate"
      assert vat.status == "some updated status"
    end

    test "update_vat/2 with invalid data returns error changeset" do
      vat = vat_fixture()
      assert {:error, %Ecto.Changeset{}} = Vats.update_vat(vat, @invalid_attrs)
      assert vat == Vats.get_vat!(vat.id)
    end

    test "delete_vat/1 deletes the vat" do
      vat = vat_fixture()
      assert {:ok, %Vat{}} = Vats.delete_vat(vat)
      assert_raise Ecto.NoResultsError, fn -> Vats.get_vat!(vat.id) end
    end

    test "change_vat/1 returns a vat changeset" do
      vat = vat_fixture()
      assert %Ecto.Changeset{} = Vats.change_vat(vat)
    end
  end
end
