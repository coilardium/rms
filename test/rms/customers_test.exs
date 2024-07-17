defmodule Rms.CustomersTest do
  use Rms.DataCase

  alias Rms.Customers

  describe "tbl_clients" do
    alias Rms.Customers.Clients

    @valid_attrs %{
      address: "some address",
      client_account: "some client_account",
      client_name: "some client_name",
      email: "some email",
      phone_number: "some phone_number",
      status: "some status"
    }
    @update_attrs %{
      address: "some updated address",
      client_account: "some updated client_account",
      client_name: "some updated client_name",
      email: "some updated email",
      phone_number: "some updated phone_number",
      status: "some updated status"
    }
    @invalid_attrs %{
      address: nil,
      client_account: nil,
      client_name: nil,
      email: nil,
      phone_number: nil,
      status: nil
    }

    def clients_fixture(attrs \\ %{}) do
      {:ok, clients} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Customers.create_clients()

      clients
    end

    test "list_tbl_clients/0 returns all tbl_clients" do
      clients = clients_fixture()
      assert Customers.list_tbl_clients() == [clients]
    end

    test "get_clients!/1 returns the clients with given id" do
      clients = clients_fixture()
      assert Customers.get_clients!(clients.id) == clients
    end

    test "create_clients/1 with valid data creates a clients" do
      assert {:ok, %Clients{} = clients} = Customers.create_clients(@valid_attrs)
      assert clients.address == "some address"
      assert clients.client_account == "some client_account"
      assert clients.client_name == "some client_name"
      assert clients.email == "some email"
      assert clients.phone_number == "some phone_number"
      assert clients.status == "some status"
    end

    test "create_clients/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Customers.create_clients(@invalid_attrs)
    end

    test "update_clients/2 with valid data updates the clients" do
      clients = clients_fixture()
      assert {:ok, %Clients{} = clients} = Customers.update_clients(clients, @update_attrs)
      assert clients.address == "some updated address"
      assert clients.client_account == "some updated client_account"
      assert clients.client_name == "some updated client_name"
      assert clients.email == "some updated email"
      assert clients.phone_number == "some updated phone_number"
      assert clients.status == "some updated status"
    end

    test "update_clients/2 with invalid data returns error changeset" do
      clients = clients_fixture()
      assert {:error, %Ecto.Changeset{}} = Customers.update_clients(clients, @invalid_attrs)
      assert clients == Customers.get_clients!(clients.id)
    end

    test "delete_clients/1 deletes the clients" do
      clients = clients_fixture()
      assert {:ok, %Clients{}} = Customers.delete_clients(clients)
      assert_raise Ecto.NoResultsError, fn -> Customers.get_clients!(clients.id) end
    end

    test "change_clients/1 returns a clients changeset" do
      clients = clients_fixture()
      assert %Ecto.Changeset{} = Customers.change_clients(clients)
    end
  end
end
