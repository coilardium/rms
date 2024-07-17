defmodule Rms.Repo.Migrations.CreateTblFuelRates do
  use Ecto.Migration

  def change do
    create table(:tbl_fuel_rates) do
      add :code, :string
      add :fuel_rate, :decimal
      add :month, :string
      add :refueling_depo, :string
      add :status, :string
      add :maker_id, references(:tbl_users, on_delete: :nothing)
      add :checker_id, references(:tbl_users, on_delete: :nothing)

      timestamps()
    end

    create index(:tbl_fuel_rates, [:maker_id])
    create index(:tbl_fuel_rates, [:checker_id])
  end
end
