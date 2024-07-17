defmodule Rms.Repo.Migrations.MakerStationUnqiIdTblUserGroup do
  use Ecto.Migration

  def up do
    create unique_index(:tbl_user_region, [:station_id],
             name: :unique_station,
             where: "station_id is not null"
           )
  end

  def down do
    drop index(:tbl_user_region, [:station_id], name: :unique_station)
  end
end
