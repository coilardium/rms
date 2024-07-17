defmodule Rms.ActivityTest do
  use Rms.DataCase

  alias Rms.Activity

  describe "tbl_sys_exception" do
    alias Rms.Activity.Sys_exception

    @valid_attrs %{
      col_ind: "some col_ind",
      error_code: "some error_code",
      error_msg: "some error_msg"
    }
    @update_attrs %{
      col_ind: "some updated col_ind",
      error_code: "some updated error_code",
      error_msg: "some updated error_msg"
    }
    @invalid_attrs %{col_ind: nil, error_code: nil, error_msg: nil}

    def sys_exception_fixture(attrs \\ %{}) do
      {:ok, sys_exception} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Activity.create_sys_exception()

      sys_exception
    end

    test "list_tbl_sys_exception/0 returns all tbl_sys_exception" do
      sys_exception = sys_exception_fixture()
      assert Activity.list_tbl_sys_exception() == [sys_exception]
    end

    test "get_sys_exception!/1 returns the sys_exception with given id" do
      sys_exception = sys_exception_fixture()
      assert Activity.get_sys_exception!(sys_exception.id) == sys_exception
    end

    test "create_sys_exception/1 with valid data creates a sys_exception" do
      assert {:ok, %Sys_exception{} = sys_exception} = Activity.create_sys_exception(@valid_attrs)
      assert sys_exception.col_ind == "some col_ind"
      assert sys_exception.error_code == "some error_code"
      assert sys_exception.error_msg == "some error_msg"
    end

    test "create_sys_exception/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Activity.create_sys_exception(@invalid_attrs)
    end

    test "update_sys_exception/2 with valid data updates the sys_exception" do
      sys_exception = sys_exception_fixture()

      assert {:ok, %Sys_exception{} = sys_exception} =
               Activity.update_sys_exception(sys_exception, @update_attrs)

      assert sys_exception.col_ind == "some updated col_ind"
      assert sys_exception.error_code == "some updated error_code"
      assert sys_exception.error_msg == "some updated error_msg"
    end

    test "update_sys_exception/2 with invalid data returns error changeset" do
      sys_exception = sys_exception_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Activity.update_sys_exception(sys_exception, @invalid_attrs)

      assert sys_exception == Activity.get_sys_exception!(sys_exception.id)
    end

    test "delete_sys_exception/1 deletes the sys_exception" do
      sys_exception = sys_exception_fixture()
      assert {:ok, %Sys_exception{}} = Activity.delete_sys_exception(sys_exception)
      assert_raise Ecto.NoResultsError, fn -> Activity.get_sys_exception!(sys_exception.id) end
    end

    test "change_sys_exception/1 returns a sys_exception changeset" do
      sys_exception = sys_exception_fixture()
      assert %Ecto.Changeset{} = Activity.change_sys_exception(sys_exception)
    end
  end

  describe "tbl_user_activity" do
    alias Rms.Activity.UserLog

    @valid_attrs %{activity: "some activity"}
    @update_attrs %{activity: "some updated activity"}
    @invalid_attrs %{activity: nil}

    def user_log_fixture(attrs \\ %{}) do
      {:ok, user_log} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Activity.create_user_log()

      user_log
    end

    test "list_tbl_user_activity/0 returns all tbl_user_activity" do
      user_log = user_log_fixture()
      assert Activity.list_tbl_user_activity() == [user_log]
    end

    test "get_user_log!/1 returns the user_log with given id" do
      user_log = user_log_fixture()
      assert Activity.get_user_log!(user_log.id) == user_log
    end

    test "create_user_log/1 with valid data creates a user_log" do
      assert {:ok, %UserLog{} = user_log} = Activity.create_user_log(@valid_attrs)
      assert user_log.activity == "some activity"
    end

    test "create_user_log/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Activity.create_user_log(@invalid_attrs)
    end

    test "update_user_log/2 with valid data updates the user_log" do
      user_log = user_log_fixture()
      assert {:ok, %UserLog{} = user_log} = Activity.update_user_log(user_log, @update_attrs)
      assert user_log.activity == "some updated activity"
    end

    test "update_user_log/2 with invalid data returns error changeset" do
      user_log = user_log_fixture()
      assert {:error, %Ecto.Changeset{}} = Activity.update_user_log(user_log, @invalid_attrs)
      assert user_log == Activity.get_user_log!(user_log.id)
    end

    test "delete_user_log/1 deletes the user_log" do
      user_log = user_log_fixture()
      assert {:ok, %UserLog{}} = Activity.delete_user_log(user_log)
      assert_raise Ecto.NoResultsError, fn -> Activity.get_user_log!(user_log.id) end
    end

    test "change_user_log/1 returns a user_log changeset" do
      user_log = user_log_fixture()
      assert %Ecto.Changeset{} = Activity.change_user_log(user_log)
    end
  end
end
