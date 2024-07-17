defmodule Rms.Repo.Migrations.DropUniqueAccountIndexTblClients do
  use Ecto.Migration

  def up do
    drop(index(:tbl_clients, [:client_account], name: :unique_client_account))

    create(
      unique_index(:tbl_clients, [:client_account],
        name: :unique_client_account,
        where: "client_account is not null"
      )
    )
  end

  def down do
    drop(index(:tbl_clients, [:client_account], name: :unique_client_account))
    create(unique_index(:tbl_clients, [:client_account], name: :unique_client_account))
  end
end
