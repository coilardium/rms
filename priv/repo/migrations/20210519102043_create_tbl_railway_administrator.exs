defmodule Rms.Repo.Migrations.CreateTblRailwayAdministrator do
  use Ecto.Migration

  def change do
    create table(:tbl_railway_administrator) do
      add :code, :string
      add :description, :string
      add :status, :string
      add :country, :string
      add :maker_id, references(:tbl_users, on_delete: :nothing)
      add :checker_id, references(:tbl_users, on_delete: :nothing)

      timestamps()
    end

    create index(:tbl_railway_administrator, [:maker_id])
    create index(:tbl_railway_administrator, [:checker_id])
  end
end
