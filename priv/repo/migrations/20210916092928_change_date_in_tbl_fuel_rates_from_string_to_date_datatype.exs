defmodule Rms.Repo.Migrations.ChangeDateInTblFuelRatesFromStringToDateDatatype do
  use Ecto.Migration

  def up do
    alter table(:tbl_fuel_rates) do
      add :start_date, :date
    end
  end

  def down do
    alter table(:tbl_fuel_rates) do
      remove :start_date
    end
  end
end
