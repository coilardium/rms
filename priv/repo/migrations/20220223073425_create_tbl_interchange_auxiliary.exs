defmodule Rms.Repo.Migrations.CreateTblInterchangeAuxiliary do
  use Ecto.Migration

  def change do
    create table(:tbl_interchange_auxiliary) do
      add :amount, :decimal, precision: 18, scale: 2
      add :sent_date, :date
      add :received_date, :date
      add :dirction, :string
      add :status, :string
      add :accumlative_days, :integer
      add :off_hire_date, :date
      add :maker_id, references(:tbl_users, on_delete: :nothing)
      add :equipment_id, references(:tbl_equipments, on_delete: :nothing)
      add :admin_id, references(:tbl_railway_administrator, on_delete: :nothing)
      add :equipment_rate_id, references(:tbl_equipment_rates, on_delete: :nothing)
      add :currency_id, references(:tbl_currency, on_delete: :nothing)

      timestamps()
    end

    create index(:tbl_interchange_auxiliary, [:maker_id])
    create index(:tbl_interchange_auxiliary, [:equipment_id])
    create index(:tbl_interchange_auxiliary, [:admin_id])
    create index(:tbl_interchange_auxiliary, [:equipment_rate_id])
    create index(:tbl_interchange_auxiliary, [:currency_id])
  end
end
