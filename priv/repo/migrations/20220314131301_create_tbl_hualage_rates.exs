defmodule Rms.Repo.Migrations.CreateTblHualageRates do
  use Ecto.Migration

  def change do
    create table(:tbl_haulage_rates) do
      add :rate, :decimal, precision: 18, scale: 2
      add :start_date, :date
      add :status, :string
      add :category, :string
      add :rate_type, :string
      add :distance, :decimal, precision: 18, scale: 2
      add :admin_id, references(:tbl_railway_administrator, on_delete: :nothing)
      add :currency_id, references(:tbl_currency, on_delete: :nothing)
      add :maker_id, references(:tbl_users, on_delete: :nothing)
      add :checker_id, references(:tbl_users, on_delete: :nothing)

      timestamps()
    end

    create index(:tbl_haulage_rates, [:admin_id])
    create index(:tbl_haulage_rates, [:currency_id])
    create index(:tbl_haulage_rates, [:maker_id])
    create index(:tbl_haulage_rates, [:checker_id])
  end
end
