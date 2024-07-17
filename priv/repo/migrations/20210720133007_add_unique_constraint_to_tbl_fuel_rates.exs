defmodule Rms.Repo.Migrations.AddUniqueConstraintToTblFuelRates do
  use Ecto.Migration

  def up do
    create(
      unique_index(:tbl_fuel_rates, [:code], name: :unique_fuel_code, where: "code is not null")
    )
  end

  def down do
    drop(index(:tbl_fuel_rates, [:code], name: :unique_fuel_code))
  end
end
