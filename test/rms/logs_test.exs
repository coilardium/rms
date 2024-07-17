defmodule Rms.LogsTest do
  use Rms.DataCase

  alias Rms.Logs

  describe "tbl_user_log" do
    alias Rms.Logs.UserLog

    @valid_attrs %{activity: "some activity", user_id: 42}
    @update_attrs %{activity: "some updated activity", user_id: 43}
    @invalid_attrs %{activity: nil, user_id: nil}

    def user_log_fixture(attrs \\ %{}) do
      {:ok, user_log} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Logs.create_user_log()

      user_log
    end

    test "list_tbl_user_log/0 returns all tbl_user_log" do
      user_log = user_log_fixture()
      assert Logs.list_tbl_user_log() == [user_log]
    end

    test "get_user_log!/1 returns the user_log with given id" do
      user_log = user_log_fixture()
      assert Logs.get_user_log!(user_log.id) == user_log
    end

    test "create_user_log/1 with valid data creates a user_log" do
      assert {:ok, %UserLog{} = user_log} = Logs.create_user_log(@valid_attrs)
      assert user_log.activity == "some activity"
      assert user_log.user_id == 42
    end

    test "create_user_log/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Logs.create_user_log(@invalid_attrs)
    end

    test "update_user_log/2 with valid data updates the user_log" do
      user_log = user_log_fixture()
      assert {:ok, %UserLog{} = user_log} = Logs.update_user_log(user_log, @update_attrs)
      assert user_log.activity == "some updated activity"
      assert user_log.user_id == 43
    end

    test "update_user_log/2 with invalid data returns error changeset" do
      user_log = user_log_fixture()
      assert {:error, %Ecto.Changeset{}} = Logs.update_user_log(user_log, @invalid_attrs)
      assert user_log == Logs.get_user_log!(user_log.id)
    end

    test "delete_user_log/1 deletes the user_log" do
      user_log = user_log_fixture()
      assert {:ok, %UserLog{}} = Logs.delete_user_log(user_log)
      assert_raise Ecto.NoResultsError, fn -> Logs.get_user_log!(user_log.id) end
    end

    test "change_user_log/1 returns a user_log changeset" do
      user_log = user_log_fixture()
      assert %Ecto.Changeset{} = Logs.change_user_log(user_log)
    end
  end
end
