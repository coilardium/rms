defmodule Rms.Repo.Migrations.AddAlterTblConsignmentTariffDestinationIdTariffOriginId do
  use Ecto.Migration

  def up do
    alter table(:tbl_consignments) do
      remove :tariff_origin_id
      remove :tariff_destination_id
      add :tariff_origin_id, references(:tbl_stations, column: :id, on_delete: :nothing)
      add :tariff_destination_id, references(:tbl_stations, column: :id, on_delete: :nothing)
    end
  end

  def down do
    alter table(:tbl_consignments) do
      remove :tariff_origin_id
      remove :tariff_destination_id
    end
  end
end
