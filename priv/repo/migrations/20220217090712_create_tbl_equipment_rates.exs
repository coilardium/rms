defmodule Rms.Repo.Migrations.CreateTblEquipmentRates do
  use Ecto.Migration

  def change do
    create table(:tbl_equipment_rates) do
      add :rate, :decimal, precision: 18, scale: 2
      add :status, :string
      add :year, :string
      add :maker_id, references(:tbl_users, on_delete: :nothing)
      add :checker_id, references(:tbl_users, on_delete: :nothing)
      add :partner_id, references(:tbl_railway_administrator, on_delete: :nothing)
      add :equipment_id, references(:tbl_equipments, on_delete: :nothing)
      add :currency_id, references(:tbl_currency, on_delete: :nothing)

      timestamps()
    end

    create index(:tbl_equipment_rates, [:maker_id])
    create index(:tbl_equipment_rates, [:checker_id])
    create index(:tbl_equipment_rates, [:partner_id])
    create index(:tbl_equipment_rates, [:equipment_id])
    create index(:tbl_equipment_rates, [:currency_id])
  end
end
