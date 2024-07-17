defmodule Rms.Railway_AdministratorsTest do
  use Rms.DataCase

  alias Rms.Railway_Administrators

  describe "tbl_railway_administrator" do
    alias Rms.Railway_Administrators.Railway_Administrator

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

    def railway__administrator_fixture(attrs \\ %{}) do
      {:ok, railway__administrator} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Railway_Administrators.create_railway__administrator()

      railway__administrator
    end

    test "list_tbl_railway_administrator/0 returns all tbl_railway_administrator" do
      railway__administrator = railway__administrator_fixture()
      assert Railway_Administrators.list_tbl_railway_administrator() == [railway__administrator]
    end

    test "get_railway__administrator!/1 returns the railway__administrator with given id" do
      railway__administrator = railway__administrator_fixture()

      assert Railway_Administrators.get_railway__administrator!(railway__administrator.id) ==
               railway__administrator
    end

    test "create_railway__administrator/1 with valid data creates a railway__administrator" do
      assert {:ok, %Railway_Administrator{} = railway__administrator} =
               Railway_Administrators.create_railway__administrator(@valid_attrs)

      assert railway__administrator.code == "some code"
      assert railway__administrator.country == "some country"
      assert railway__administrator.description == "some description"
      assert railway__administrator.status == "some status"
    end

    test "create_railway__administrator/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Railway_Administrators.create_railway__administrator(@invalid_attrs)
    end

    test "update_railway__administrator/2 with valid data updates the railway__administrator" do
      railway__administrator = railway__administrator_fixture()

      assert {:ok, %Railway_Administrator{} = railway__administrator} =
               Railway_Administrators.update_railway__administrator(
                 railway__administrator,
                 @update_attrs
               )

      assert railway__administrator.code == "some updated code"
      assert railway__administrator.country == "some updated country"
      assert railway__administrator.description == "some updated description"
      assert railway__administrator.status == "some updated status"
    end

    test "update_railway__administrator/2 with invalid data returns error changeset" do
      railway__administrator = railway__administrator_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Railway_Administrators.update_railway__administrator(
                 railway__administrator,
                 @invalid_attrs
               )

      assert railway__administrator ==
               Railway_Administrators.get_railway__administrator!(railway__administrator.id)
    end

    test "delete_railway__administrator/1 deletes the railway__administrator" do
      railway__administrator = railway__administrator_fixture()

      assert {:ok, %Railway_Administrator{}} =
               Railway_Administrators.delete_railway__administrator(railway__administrator)

      assert_raise Ecto.NoResultsError, fn ->
        Railway_Administrators.get_railway__administrator!(railway__administrator.id)
      end
    end

    test "change_railway__administrator/1 returns a railway__administrator changeset" do
      railway__administrator = railway__administrator_fixture()

      assert %Ecto.Changeset{} =
               Railway_Administrators.change_railway__administrator(railway__administrator)
    end
  end
end
