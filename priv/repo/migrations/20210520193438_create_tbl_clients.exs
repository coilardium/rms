defmodule Rms.Repo.Migrations.CreateTblClients do
  use Ecto.Migration

  def change do
    create table(:tbl_clients) do
      add :client_account, :string
      add :client_name, :string
      add :address, :string
      add :phone_number, :string
      add :email, :string
      add :status, :string
      add :maker_id, references(:tbl_users, on_delete: :nothing)
      add :checker_id, references(:tbl_users, on_delete: :nothing)

      timestamps()
    end

    create index(:tbl_clients, [:maker_id])
    create index(:tbl_clients, [:checker_id])
  end
end
