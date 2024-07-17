defmodule Rms.Repo.Migrations.AddTrainOriginToTblFuelMonitoring do
  use Ecto.Migration

  def up do
    alter table(:tbl_fuel_monitoring) do
      add :train_origin_id, references(:tbl_stations, column: :id, on_delete: :nilify_all)
      add :km_to_destin, :decimal, precision: 18, scale: 2
    end
  end

  def down do
    alter table(:tbl_fuel_monitoring) do
      remove :train_origin_id
      remove :km_to_destin
    end
  end
end
