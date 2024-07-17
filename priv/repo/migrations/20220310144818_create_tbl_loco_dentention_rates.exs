defmodule Rms.Repo.Migrations.CreateTblLocoDententionRates do
  use Ecto.Migration

  def change do
    create table(:tbl_loco_dentention_rates) do
      add :rate, :decimal, precision: 18, scale: 2
      add :start_date, :date
      add :status, :string
      add :delay_charge, :integer
      add :maker_id, references(:tbl_users, on_delete: :nothing)
      add :checker_id, references(:tbl_users, on_delete: :nothing)
      add :admin_id, references(:tbl_railway_administrator, on_delete: :nothing)
      add :currency_id, references(:tbl_currency, on_delete: :nothing)

      timestamps()
    end

    create index(:tbl_loco_dentention_rates, [:maker_id])
    create index(:tbl_loco_dentention_rates, [:checker_id])
    create index(:tbl_loco_dentention_rates, [:admin_id])
    create index(:tbl_loco_dentention_rates, [:currency_id])
  end
end
