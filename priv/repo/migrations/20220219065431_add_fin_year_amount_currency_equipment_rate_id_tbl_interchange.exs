defmodule Rms.Repo.Migrations.AddFinYearAmountCurrencyEquipmentRateIdTblInterchange do
  use Ecto.Migration

  def up do
    alter table(:tbl_interchange_material) do
      add :currency_id, references(:tbl_currency, column: :id, on_delete: :nothing)
      add :equipment_rate_id, references(:tbl_equipment_rates, column: :id, on_delete: :nothing)
      add :fin_year, :string
      add :amount, :decimal, precision: 18, scale: 2
    end
  end

  def down do
    alter table(:tbl_interchange_material) do
      remove :currency_id
      remove :equipment_rate_id
      remove :fin_year
      remove :amount
    end
  end
end
