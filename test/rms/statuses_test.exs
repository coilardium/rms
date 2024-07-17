defmodule Rms.StatusesTest do
  use Rms.DataCase

  alias Rms.Statuses

  describe "tbl_status" do
    alias Rms.Statuses.Status

    @valid_attrs %{
      code: "some code",
      description: "some description",
      rec_status: "some rec_status"
    }
    @update_attrs %{
      code: "some updated code",
      description: "some updated description",
      rec_status: "some updated rec_status"
    }
    @invalid_attrs %{code: nil, description: nil, rec_status: nil}

    def status_fixture(attrs \\ %{}) do
      {:ok, status} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Statuses.create_status()

      status
    end

    test "list_tbl_status/0 returns all tbl_status" do
      status = status_fixture()
      assert Statuses.list_tbl_status() == [status]
    end

    test "get_status!/1 returns the status with given id" do
      status = status_fixture()
      assert Statuses.get_status!(status.id) == status
    end

    test "create_status/1 with valid data creates a status" do
      assert {:ok, %Status{} = status} = Statuses.create_status(@valid_attrs)
      assert status.code == "some code"
      assert status.description == "some description"
      assert status.rec_status == "some rec_status"
    end

    test "create_status/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Statuses.create_status(@invalid_attrs)
    end

    test "update_status/2 with valid data updates the status" do
      status = status_fixture()
      assert {:ok, %Status{} = status} = Statuses.update_status(status, @update_attrs)
      assert status.code == "some updated code"
      assert status.description == "some updated description"
      assert status.rec_status == "some updated rec_status"
    end

    test "update_status/2 with invalid data returns error changeset" do
      status = status_fixture()
      assert {:error, %Ecto.Changeset{}} = Statuses.update_status(status, @invalid_attrs)
      assert status == Statuses.get_status!(status.id)
    end

    test "delete_status/1 deletes the status" do
      status = status_fixture()
      assert {:ok, %Status{}} = Statuses.delete_status(status)
      assert_raise Ecto.NoResultsError, fn -> Statuses.get_status!(status.id) end
    end

    test "change_status/1 returns a status changeset" do
      status = status_fixture()
      assert %Ecto.Changeset{} = Statuses.change_status(status)
    end
  end
end
