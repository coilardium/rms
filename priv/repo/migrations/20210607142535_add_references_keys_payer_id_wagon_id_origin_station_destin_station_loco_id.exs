defmodule Rms.Repo.Migrations.AddReferencesKeysPayerIdWagonIdOriginStationDestinStationLocoId do
  use Ecto.Migration

  def up do
    alter table(:tbl_movement) do
      remove :wagon_id
      remove :orgin_station_id
      remove :destin_station_id
      remove :commodity_id
      remove :payer_id
      remove :loco_id
      add :wagon_id, references(:tbl_wagon, column: :id)
      add :commodity_id, references(:tbl_commodity, column: :id)
      add :origin_station_id, references(:tbl_stations, column: :id, on_delete: :nothing)
      add :destin_station_id, references(:tbl_stations, column: :id, on_delete: :nothing)
      add :payer_id, references(:tbl_clients, column: :id, on_delete: :nothing)
      add :loco_id, references(:tbl_locomotive, column: :id, on_delete: :nothing)
    end
  end

  def down do
    alter table(:tbl_movement) do
      add :wagon_id, :string
      add :orgin_station_id, :string
      add :destin_station_id, :string
      add :commodity_id, :string
      add :payer_id, :string
      add :loco_id, :string
    end
  end
end
