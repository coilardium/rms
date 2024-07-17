defmodule Rms.RailwayAdministratorsTest do
  use Rms.DataCase

  alias Rms.RailwayAdministrators

  describe "tbl_railway_administrator" do
    alias Rms.RailwayAdministrators.RailwayAdministrator

    @valid_attrs %{
      code: "some code",
      country: "some country",
      description: "some description",
      status: "some status"
    }
    @update_attrs %{
      code: "some updated code",
      country: "some updated country",
      description: "some updated description",
      status: "some updated status"
    }
    @invalid_attrs %{code: nil, country: nil, description: nil, status: nil}

    def railway_administrator_fixture(attrs \\ %{}) do
      {:ok, railway_administrator} =
        attrs
        |> Enum.into(@valid_attrs)
        |> RailwayAdministrators.create_railway_administrator()

      railway_administrator
    end

    test "list_tbl_railway_administrator/0 returns all tbl_railway_administrator" do
      railway_administrator = railway_administrator_fixture()
      assert RailwayAdministrators.list_tbl_railway_administrator() == [railway_administrator]
    end

    test "get_railway_administrator!/1 returns the railway_administrator with given id" do
      railway_administrator = railway_administrator_fixture()

      assert RailwayAdministrators.get_railway_administrator!(railway_administrator.id) ==
               railway_administrator
    end

    test "create_railway_administrator/1 with valid data creates a railway_administrator" do
      assert {:ok, %RailwayAdministrator{} = railway_administrator} =
               RailwayAdministrators.create_railway_administrator(@valid_attrs)

      assert railway_administrator.code == "some code"
      assert railway_administrator.country == "some country"
      assert railway_administrator.description == "some description"
      assert railway_administrator.status == "some status"
    end

    test "create_railway_administrator/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               RailwayAdministrators.create_railway_administrator(@invalid_attrs)
    end

    test "update_railway_administrator/2 with valid data updates the railway_administrator" do
      railway_administrator = railway_administrator_fixture()

      assert {:ok, %RailwayAdministrator{} = railway_administrator} =
               RailwayAdministrators.update_railway_administrator(
                 railway_administrator,
                 @update_attrs
               )

      assert railway_administrator.code == "some updated code"
      assert railway_administrator.country == "some updated country"
      assert railway_administrator.description == "some updated description"
      assert railway_administrator.status == "some updated status"
    end

    test "update_railway_administrator/2 with invalid data returns error changeset" do
      railway_administrator = railway_administrator_fixture()

      assert {:error, %Ecto.Changeset{}} =
               RailwayAdministrators.update_railway_administrator(
                 railway_administrator,
                 @invalid_attrs
               )

      assert railway_administrator ==
               RailwayAdministrators.get_railway_administrator!(railway_administrator.id)
    end

    test "delete_railway_administrator/1 deletes the railway_administrator" do
      railway_administrator = railway_administrator_fixture()

      assert {:ok, %RailwayAdministrator{}} =
               RailwayAdministrators.delete_railway_administrator(railway_administrator)

      assert_raise Ecto.NoResultsError, fn ->
        RailwayAdministrators.get_railway_administrator!(railway_administrator.id)
      end
    end

    test "change_railway_administrator/1 returns a railway_administrator changeset" do
      railway_administrator = railway_administrator_fixture()

      assert %Ecto.Changeset{} =
               RailwayAdministrators.change_railway_administrator(railway_administrator)
    end
  end
end
