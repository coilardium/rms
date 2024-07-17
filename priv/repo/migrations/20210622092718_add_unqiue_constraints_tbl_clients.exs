defmodule Rms.Repo.Migrations.AddUnqiueConstraintsTblClients do
  use Ecto.Migration

  def up do
    create(unique_index(:tbl_clients, [:client_account], name: :unique_client_account))
    create(unique_index(:tbl_clients, [:client_name], name: :unique_client_name))
    create(unique_index(:tbl_clients, [:email], name: :unique_email))
    create(unique_index(:tbl_clients, [:phone_number], name: :unique_phone_number))
  end

  def down do
    drop(index(:tbl_clients, [:client_account], name: :unique_client_account))
    drop(index(:tbl_clients, [:client_name], name: :unique_client_name))
    drop(index(:tbl_clients, [:email], name: :unique_email))
    drop(index(:tbl_clients, [:phone_number], name: :unique_phone_number))
  end
end
