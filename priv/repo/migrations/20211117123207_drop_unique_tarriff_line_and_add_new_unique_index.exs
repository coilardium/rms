defmodule Rms.Repo.Migrations.DropUniqueTarriffLineAndAddNewUniqueIndex do
  use Ecto.Migration

  def up do
    # drop index(:tbl_tariff_line, [:client_id, :orig_station_id, :destin_station_id, :commodity_id], name: :unique_tariff_line)
    # create unique_index(:tbl_tariff_line, [:client_id, :orig_station_id, :destin_station_id, :commodity_id, :start_dt], name: :unique_tariff_line)
  end

  def down do
    # drop index(:tbl_tariff_line, [:client_id, :orig_station_id, :destin_station_id, :commodity_id, :start_dt], name: :unique_tariff_line)
    # create unique_index(:tbl_tariff_line, [:client_id, :orig_station_id, :destin_station_id, :commodity_id], name: :unique_tariff_line)
  end
end
