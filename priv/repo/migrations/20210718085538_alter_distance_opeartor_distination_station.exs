defmodule Rms.Repo.Migrations.AlterDistanceOpeartorDistinationStation do
  use Ecto.Migration

  def up do
    alter table(:tbl_train_routes) do
      remove :destination_station
      remove :distance
      remove :operator
      remove :origin_station
      remove :transport_type
      add :destination_station, references(:tbl_stations, column: :id, on_delete: :nothing)
      add :origin_station, references(:tbl_stations, column: :id, on_delete: :nothing)
      add :operator, references(:tbl_railway_administrator, column: :id, on_delete: :nothing)
      add :transport_type, references(:tbl_transport_type, column: :id, on_delete: :nothing)
      add :distance, :decimal, precision: 18, scale: 2
    end
  end

  def down do
    alter table(:tbl_train_routes) do
      remove :destination_station
      remove :distance
      remove :operator
      remove :origin_station
      remove :transport_type
      add :destination_station, :string
      add :distance, :string
      add :operator, :string
      add :origin_station, :string
      add :transport_type, :string
    end
  end
end
