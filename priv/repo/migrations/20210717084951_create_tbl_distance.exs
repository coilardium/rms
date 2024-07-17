defmodule Rms.Repo.Migrations.CreateTblDistance do
  use Ecto.Migration

  def change do
    create table(:tbl_distance) do
      add :station_orig, :string
      add :destin, :string
      add :distance, :decimal
      add :maker_id, references(:tbl_users, on_delete: :nothing)
      add :checker_id, references(:tbl_users, on_delete: :nothing)

      timestamps()
    end

    create index(:tbl_distance, [:maker_id])
    create index(:tbl_distance, [:checker_id])
  end
end
