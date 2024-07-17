defmodule Rms.Repo.Migrations.CreateTblRegion do
  use Ecto.Migration

  def change do
    create table(:tbl_region) do
      add :code, :string
      add :description, :string
      add :status, :string
      add :maker_id, references(:tbl_users, on_delete: :nothing)
      add :checker_id, references(:tbl_users, on_delete: :nothing)

      timestamps()
    end

    create index(:tbl_region, [:maker_id])
    create index(:tbl_region, [:checker_id])
  end
end
