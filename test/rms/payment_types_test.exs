defmodule Rms.PaymentTypesTest do
  use Rms.DataCase

  alias Rms.PaymentTypes

  describe "tbl_payment_type" do
    alias Rms.PaymentTypes.PaymentType

    @valid_attrs %{code: "some code", description: "some description"}
    @update_attrs %{code: "some updated code", description: "some updated description"}
    @invalid_attrs %{code: nil, description: nil}

    def payment_type_fixture(attrs \\ %{}) do
      {:ok, payment_type} =
        attrs
        |> Enum.into(@valid_attrs)
        |> PaymentTypes.create_payment_type()

      payment_type
    end

    test "list_tbl_payment_type/0 returns all tbl_payment_type" do
      payment_type = payment_type_fixture()
      assert PaymentTypes.list_tbl_payment_type() == [payment_type]
    end

    test "get_payment_type!/1 returns the payment_type with given id" do
      payment_type = payment_type_fixture()
      assert PaymentTypes.get_payment_type!(payment_type.id) == payment_type
    end

    test "create_payment_type/1 with valid data creates a payment_type" do
      assert {:ok, %PaymentType{} = payment_type} = PaymentTypes.create_payment_type(@valid_attrs)
      assert payment_type.code == "some code"
      assert payment_type.description == "some description"
    end

    test "create_payment_type/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = PaymentTypes.create_payment_type(@invalid_attrs)
    end

    test "update_payment_type/2 with valid data updates the payment_type" do
      payment_type = payment_type_fixture()

      assert {:ok, %PaymentType{} = payment_type} =
               PaymentTypes.update_payment_type(payment_type, @update_attrs)

      assert payment_type.code == "some updated code"
      assert payment_type.description == "some updated description"
    end

    test "update_payment_type/2 with invalid data returns error changeset" do
      payment_type = payment_type_fixture()

      assert {:error, %Ecto.Changeset{}} =
               PaymentTypes.update_payment_type(payment_type, @invalid_attrs)

      assert payment_type == PaymentTypes.get_payment_type!(payment_type.id)
    end

    test "delete_payment_type/1 deletes the payment_type" do
      payment_type = payment_type_fixture()
      assert {:ok, %PaymentType{}} = PaymentTypes.delete_payment_type(payment_type)
      assert_raise Ecto.NoResultsError, fn -> PaymentTypes.get_payment_type!(payment_type.id) end
    end

    test "change_payment_type/1 returns a payment_type changeset" do
      payment_type = payment_type_fixture()
      assert %Ecto.Changeset{} = PaymentTypes.change_payment_type(payment_type)
    end
  end
end
