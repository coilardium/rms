defmodule Rms.SurchagesTest do
  use Rms.DataCase

  alias Rms.Surchages

  describe "tbl_surcharge" do
    alias Rms.Surchages.Surchage

    @valid_attrs %{code: "some code", description: "some description", status: "some status"}
    @update_attrs %{
      code: "some updated code",
      description: "some updated description",
      status: "some updated status"
    }
    @invalid_attrs %{code: nil, description: nil, status: nil}

    def surchage_fixture(attrs \\ %{}) do
      {:ok, surchage} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Surchages.create_surchage()

      surchage
    end

    test "list_tbl_surcharge/0 returns all tbl_surcharge" do
      surchage = surchage_fixture()
      assert Surchages.list_tbl_surcharge() == [surchage]
    end

    test "get_surchage!/1 returns the surchage with given id" do
      surchage = surchage_fixture()
      assert Surchages.get_surchage!(surchage.id) == surchage
    end

    test "create_surchage/1 with valid data creates a surchage" do
      assert {:ok, %Surchage{} = surchage} = Surchages.create_surchage(@valid_attrs)
      assert surchage.code == "some code"
      assert surchage.description == "some description"
      assert surchage.status == "some status"
    end

    test "create_surchage/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Surchages.create_surchage(@invalid_attrs)
    end

    test "update_surchage/2 with valid data updates the surchage" do
      surchage = surchage_fixture()
      assert {:ok, %Surchage{} = surchage} = Surchages.update_surchage(surchage, @update_attrs)
      assert surchage.code == "some updated code"
      assert surchage.description == "some updated description"
      assert surchage.status == "some updated status"
    end

    test "update_surchage/2 with invalid data returns error changeset" do
      surchage = surchage_fixture()
      assert {:error, %Ecto.Changeset{}} = Surchages.update_surchage(surchage, @invalid_attrs)
      assert surchage == Surchages.get_surchage!(surchage.id)
    end

    test "delete_surchage/1 deletes the surchage" do
      surchage = surchage_fixture()
      assert {:ok, %Surchage{}} = Surchages.delete_surchage(surchage)
      assert_raise Ecto.NoResultsError, fn -> Surchages.get_surchage!(surchage.id) end
    end

    test "change_surchage/1 returns a surchage changeset" do
      surchage = surchage_fixture()
      assert %Ecto.Changeset{} = Surchages.change_surchage(surchage)
    end
  end
end
