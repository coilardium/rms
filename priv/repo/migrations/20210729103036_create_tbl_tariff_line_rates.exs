defmodule Rms.Repo.Migrations.CreateTblTariffLineRates do
  use Ecto.Migration

  def change do
    create table(:tbl_tariff_line_rates) do
      add :rate, :decimal, precision: 18, scale: 2
      add :admin_id, references(:tbl_railway_administrator, on_delete: :nothing)
      add :tariff_id, references(:tbl_tariff_line, on_delete: :nothing)

      timestamps()
    end

    create index(:tbl_tariff_line_rates, [:admin_id])
    create index(:tbl_tariff_line_rates, [:tariff_id])
  end
end
