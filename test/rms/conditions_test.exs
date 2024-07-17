defmodule Rms.ConditionsTest do
  use Rms.DataCase

  alias Rms.Conditions

  describe "tbl_condition" do
    alias Rms.Conditions.Condition

    @valid_attrs %{
      code: "some code",
      con_status: "some con_status",
      description: "some description"
    }
    @update_attrs %{
      code: "some updated code",
      con_status: "some updated con_status",
      description: "some updated description"
    }
    @invalid_attrs %{code: nil, con_status: nil, description: nil}

    def condition_fixture(attrs \\ %{}) do
      {:ok, condition} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Conditions.create_condition()

      condition
    end

    test "list_tbl_condition/0 returns all tbl_condition" do
      condition = condition_fixture()
      assert Conditions.list_tbl_condition() == [condition]
    end

    test "get_condition!/1 returns the condition with given id" do
      condition = condition_fixture()
      assert Conditions.get_condition!(condition.id) == condition
    end

    test "create_condition/1 with valid data creates a condition" do
      assert {:ok, %Condition{} = condition} = Conditions.create_condition(@valid_attrs)
      assert condition.code == "some code"
      assert condition.con_status == "some con_status"
      assert condition.description == "some description"
    end

    test "create_condition/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Conditions.create_condition(@invalid_attrs)
    end

    test "update_condition/2 with valid data updates the condition" do
      condition = condition_fixture()

      assert {:ok, %Condition{} = condition} =
               Conditions.update_condition(condition, @update_attrs)

      assert condition.code == "some updated code"
      assert condition.con_status == "some updated con_status"
      assert condition.description == "some updated description"
    end

    test "update_condition/2 with invalid data returns error changeset" do
      condition = condition_fixture()
      assert {:error, %Ecto.Changeset{}} = Conditions.update_condition(condition, @invalid_attrs)
      assert condition == Conditions.get_condition!(condition.id)
    end

    test "delete_condition/1 deletes the condition" do
      condition = condition_fixture()
      assert {:ok, %Condition{}} = Conditions.delete_condition(condition)
      assert_raise Ecto.NoResultsError, fn -> Conditions.get_condition!(condition.id) end
    end

    test "change_condition/1 returns a condition changeset" do
      condition = condition_fixture()
      assert %Ecto.Changeset{} = Conditions.change_condition(condition)
    end
  end
end
