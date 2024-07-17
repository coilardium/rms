defmodule Rms.MovementExceptionsTest do
  use Rms.DataCase

  alias Rms.MovementExceptions

  describe "tbl_mvt_exceptions" do
    alias Rms.MovementExceptions.MovementException

    @valid_attrs %{
      axles: "120.5",
      capture_date: ~D[2010-04-17],
      derailment: "120.5",
      empty_wagons: "120.5",
      light_engines: "120.5",
      status: "some status"
    }
    @update_attrs %{
      axles: "456.7",
      capture_date: ~D[2011-05-18],
      derailment: "456.7",
      empty_wagons: "456.7",
      light_engines: "456.7",
      status: "some updated status"
    }
    @invalid_attrs %{
      axles: nil,
      capture_date: nil,
      derailment: nil,
      empty_wagons: nil,
      light_engines: nil,
      status: nil
    }

    def movement_exception_fixture(attrs \\ %{}) do
      {:ok, movement_exception} =
        attrs
        |> Enum.into(@valid_attrs)
        |> MovementExceptions.create_movement_exception()

      movement_exception
    end

    test "list_tbl_mvt_exceptions/0 returns all tbl_mvt_exceptions" do
      movement_exception = movement_exception_fixture()
      assert MovementExceptions.list_tbl_mvt_exceptions() == [movement_exception]
    end

    test "get_movement_exception!/1 returns the movement_exception with given id" do
      movement_exception = movement_exception_fixture()

      assert MovementExceptions.get_movement_exception!(movement_exception.id) ==
               movement_exception
    end

    test "create_movement_exception/1 with valid data creates a movement_exception" do
      assert {:ok, %MovementException{} = movement_exception} =
               MovementExceptions.create_movement_exception(@valid_attrs)

      assert movement_exception.axles == Decimal.new("120.5")
      assert movement_exception.capture_date == ~D[2010-04-17]
      assert movement_exception.derailment == Decimal.new("120.5")
      assert movement_exception.empty_wagons == Decimal.new("120.5")
      assert movement_exception.light_engines == Decimal.new("120.5")
      assert movement_exception.status == "some status"
    end

    test "create_movement_exception/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               MovementExceptions.create_movement_exception(@invalid_attrs)
    end

    test "update_movement_exception/2 with valid data updates the movement_exception" do
      movement_exception = movement_exception_fixture()

      assert {:ok, %MovementException{} = movement_exception} =
               MovementExceptions.update_movement_exception(movement_exception, @update_attrs)

      assert movement_exception.axles == Decimal.new("456.7")
      assert movement_exception.capture_date == ~D[2011-05-18]
      assert movement_exception.derailment == Decimal.new("456.7")
      assert movement_exception.empty_wagons == Decimal.new("456.7")
      assert movement_exception.light_engines == Decimal.new("456.7")
      assert movement_exception.status == "some updated status"
    end

    test "update_movement_exception/2 with invalid data returns error changeset" do
      movement_exception = movement_exception_fixture()

      assert {:error, %Ecto.Changeset{}} =
               MovementExceptions.update_movement_exception(movement_exception, @invalid_attrs)

      assert movement_exception ==
               MovementExceptions.get_movement_exception!(movement_exception.id)
    end

    test "delete_movement_exception/1 deletes the movement_exception" do
      movement_exception = movement_exception_fixture()

      assert {:ok, %MovementException{}} =
               MovementExceptions.delete_movement_exception(movement_exception)

      assert_raise Ecto.NoResultsError, fn ->
        MovementExceptions.get_movement_exception!(movement_exception.id)
      end
    end

    test "change_movement_exception/1 returns a movement_exception changeset" do
      movement_exception = movement_exception_fixture()
      assert %Ecto.Changeset{} = MovementExceptions.change_movement_exception(movement_exception)
    end
  end
end
