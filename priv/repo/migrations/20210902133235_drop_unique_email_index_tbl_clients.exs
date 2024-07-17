defmodule Rms.Repo.Migrations.DropUniqueEmailIndexTblClients do
  use Ecto.Migration

  def up do
    drop(index(:tbl_clients, [:email], name: :unique_email))
    create(unique_index(:tbl_clients, [:email], name: :unique_email, where: "email is not null"))
  end

  def down do
    drop(index(:tbl_clients, [:email], name: :unique_email))
    create(unique_index(:tbl_clients, [:email], name: :unique_email))
  end
end
