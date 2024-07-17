defmodule Rms.Repo.Migrations.AddRefuelDepoIdToTblFuelRates do
  use Ecto.Migration

  def up do
    alter table(:tbl_fuel_rates) do
      add :refueling_depo_id, references(:tbl_distance, column: :id, on_delete: :nothing)
    end
  end

  def down do
    alter table(:tbl_fuel_rates) do
      remove :refueling_depo_id
    end
  end
end
