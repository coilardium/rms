defmodule Rms.TransportTest do
  use Rms.DataCase

  alias Rms.Transport

  describe "tbl_transport_type" do
    alias Rms.Transport.TransportType

    @valid_attrs %{
      code: "some code",
      description: "some description",
      status: "some status",
      transport_type: "some transport_type"
    }
    @update_attrs %{
      code: "some updated code",
      description: "some updated description",
      status: "some updated status",
      transport_type: "some updated transport_type"
    }
    @invalid_attrs %{code: nil, description: nil, status: nil, transport_type: nil}

    def transport_type_fixture(attrs \\ %{}) do
      {:ok, transport_type} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Transport.create_transport_type()

      transport_type
    end

    test "list_tbl_transport_type/0 returns all tbl_transport_type" do
      transport_type = transport_type_fixture()
      assert Transport.list_tbl_transport_type() == [transport_type]
    end

    test "get_transport_type!/1 returns the transport_type with given id" do
      transport_type = transport_type_fixture()
      assert Transport.get_transport_type!(transport_type.id) == transport_type
    end

    test "create_transport_type/1 with valid data creates a transport_type" do
      assert {:ok, %TransportType{} = transport_type} =
               Transport.create_transport_type(@valid_attrs)

      assert transport_type.code == "some code"
      assert transport_type.description == "some description"
      assert transport_type.status == "some status"
      assert transport_type.transport_type == "some transport_type"
    end

    test "create_transport_type/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Transport.create_transport_type(@invalid_attrs)
    end

    test "update_transport_type/2 with valid data updates the transport_type" do
      transport_type = transport_type_fixture()

      assert {:ok, %TransportType{} = transport_type} =
               Transport.update_transport_type(transport_type, @update_attrs)

      assert transport_type.code == "some updated code"
      assert transport_type.description == "some updated description"
      assert transport_type.status == "some updated status"
      assert transport_type.transport_type == "some updated transport_type"
    end

    test "update_transport_type/2 with invalid data returns error changeset" do
      transport_type = transport_type_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Transport.update_transport_type(transport_type, @invalid_attrs)

      assert transport_type == Transport.get_transport_type!(transport_type.id)
    end

    test "delete_transport_type/1 deletes the transport_type" do
      transport_type = transport_type_fixture()
      assert {:ok, %TransportType{}} = Transport.delete_transport_type(transport_type)
      assert_raise Ecto.NoResultsError, fn -> Transport.get_transport_type!(transport_type.id) end
    end

    test "change_transport_type/1 returns a transport_type changeset" do
      transport_type = transport_type_fixture()
      assert %Ecto.Changeset{} = Transport.change_transport_type(transport_type)
    end
  end
end
