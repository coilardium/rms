defmodule Rms.AccountsTest do
  use Rms.DataCase

  alias Rms.Accounts

  describe "tbl_users" do
    alias Rms.Accounts.User

    @valid_attrs %{
      email: "some email",
      first_name: "some first_name",
      last_name: "some last_name",
      mobile: "some mobile",
      password: "some password",
      status: "some status",
      user_id: 42,
      user_role: 42,
      username: "some username"
    }
    @update_attrs %{
      email: "some updated email",
      first_name: "some updated first_name",
      last_name: "some updated last_name",
      mobile: "some updated mobile",
      password: "some updated password",
      status: "some updated status",
      user_id: 43,
      user_role: 43,
      username: "some updated username"
    }
    @invalid_attrs %{
      email: nil,
      first_name: nil,
      last_name: nil,
      mobile: nil,
      password: nil,
      status: nil,
      user_id: nil,
      user_role: nil,
      username: nil
    }

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_user()

      user
    end

    test "list_tbl_users/0 returns all tbl_users" do
      user = user_fixture()
      assert Accounts.list_tbl_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.email == "some email"
      assert user.first_name == "some first_name"
      assert user.last_name == "some last_name"
      assert user.mobile == "some mobile"
      assert user.password == "some password"
      assert user.status == "some status"
      assert user.user_id == 42
      assert user.user_role == 42
      assert user.username == "some username"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, %User{} = user} = Accounts.update_user(user, @update_attrs)
      assert user.email == "some updated email"
      assert user.first_name == "some updated first_name"
      assert user.last_name == "some updated last_name"
      assert user.mobile == "some updated mobile"
      assert user.password == "some updated password"
      assert user.status == "some updated status"
      assert user.user_id == 43
      assert user.user_role == 43
      assert user.username == "some updated username"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end

  describe "tbl_user_role" do
    alias Rms.Accounts.UserRole

    @valid_attrs %{
      maker_id: 42,
      role_desc: "some role_desc",
      role_str: "some role_str",
      status: "some status"
    }
    @update_attrs %{
      maker_id: 43,
      role_desc: "some updated role_desc",
      role_str: "some updated role_str",
      status: "some updated status"
    }
    @invalid_attrs %{maker_id: nil, role_desc: nil, role_str: nil, status: nil}

    def user_role_fixture(attrs \\ %{}) do
      {:ok, user_role} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_user_role()

      user_role
    end

    test "list_tbl_user_role/0 returns all tbl_user_role" do
      user_role = user_role_fixture()
      assert Accounts.list_tbl_user_role() == [user_role]
    end

    test "get_user_role!/1 returns the user_role with given id" do
      user_role = user_role_fixture()
      assert Accounts.get_user_role!(user_role.id) == user_role
    end

    test "create_user_role/1 with valid data creates a user_role" do
      assert {:ok, %UserRole{} = user_role} = Accounts.create_user_role(@valid_attrs)
      assert user_role.maker_id == 42
      assert user_role.role_desc == "some role_desc"
      assert user_role.role_str == "some role_str"
      assert user_role.status == "some status"
    end

    test "create_user_role/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user_role(@invalid_attrs)
    end

    test "update_user_role/2 with valid data updates the user_role" do
      user_role = user_role_fixture()
      assert {:ok, %UserRole{} = user_role} = Accounts.update_user_role(user_role, @update_attrs)
      assert user_role.maker_id == 43
      assert user_role.role_desc == "some updated role_desc"
      assert user_role.role_str == "some updated role_str"
      assert user_role.status == "some updated status"
    end

    test "update_user_role/2 with invalid data returns error changeset" do
      user_role = user_role_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user_role(user_role, @invalid_attrs)
      assert user_role == Accounts.get_user_role!(user_role.id)
    end

    test "delete_user_role/1 deletes the user_role" do
      user_role = user_role_fixture()
      assert {:ok, %UserRole{}} = Accounts.delete_user_role(user_role)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user_role!(user_role.id) end
    end

    test "change_user_role/1 returns a user_role changeset" do
      user_role = user_role_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user_role(user_role)
    end
  end

  describe "tbl_user_region" do
    alias Rms.Accounts.UserRegion

    @valid_attrs %{code: "some code", description: "some description"}
    @update_attrs %{code: "some updated code", description: "some updated description"}
    @invalid_attrs %{code: nil, description: nil}

    def user_region_fixture(attrs \\ %{}) do
      {:ok, user_region} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_user_region()

      user_region
    end

    test "list_tbl_user_region/0 returns all tbl_user_region" do
      user_region = user_region_fixture()
      assert Accounts.list_tbl_user_region() == [user_region]
    end

    test "get_user_region!/1 returns the user_region with given id" do
      user_region = user_region_fixture()
      assert Accounts.get_user_region!(user_region.id) == user_region
    end

    test "create_user_region/1 with valid data creates a user_region" do
      assert {:ok, %UserRegion{} = user_region} = Accounts.create_user_region(@valid_attrs)
      assert user_region.code == "some code"
      assert user_region.description == "some description"
    end

    test "create_user_region/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user_region(@invalid_attrs)
    end

    test "update_user_region/2 with valid data updates the user_region" do
      user_region = user_region_fixture()

      assert {:ok, %UserRegion{} = user_region} =
               Accounts.update_user_region(user_region, @update_attrs)

      assert user_region.code == "some updated code"
      assert user_region.description == "some updated description"
    end

    test "update_user_region/2 with invalid data returns error changeset" do
      user_region = user_region_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Accounts.update_user_region(user_region, @invalid_attrs)

      assert user_region == Accounts.get_user_region!(user_region.id)
    end

    test "delete_user_region/1 deletes the user_region" do
      user_region = user_region_fixture()
      assert {:ok, %UserRegion{}} = Accounts.delete_user_region(user_region)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user_region!(user_region.id) end
    end

    test "change_user_region/1 returns a user_region changeset" do
      user_region = user_region_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user_region(user_region)
    end
  end
end
