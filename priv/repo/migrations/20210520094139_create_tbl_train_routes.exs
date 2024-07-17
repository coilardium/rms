defmodule Rms.Repo.Migrations.CreateTblTrainRoutes do
  use Ecto.Migration

  def change do
    create table(:tbl_train_routes) do
      add :code, :string
      add :description, :string
      add :origin_station, :string
      add :destination_station, :string
      add :status, :string
      add :transport_type, :string
      add :distance, :string
      add :operator, :string
      add :maker_id, references(:tbl_users, on_delete: :nothing)
      add :checker_id, references(:tbl_users, on_delete: :nothing)

      timestamps()
    end

    create index(:tbl_train_routes, [:maker_id])
    create index(:tbl_train_routes, [:checker_id])
  end
end
