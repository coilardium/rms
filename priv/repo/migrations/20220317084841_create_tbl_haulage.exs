defmodule Rms.Repo.Migrations.CreateTblHaulage do
  use Ecto.Migration

  def change do
    create table(:tbl_haulage) do
      add :date, :date
      add :train_no, :string
      add :status, :string
      add :loco_no, :string
      add :comment, :string
      add :direction, :string
      add :observation, :string
      add :total_wagons, :integer
      add :wagon_ratio, :string
      add :rate_type, :string
      add :wagon_grand_total, :integer
      add :amount, :decimal, precision: 18, scale: 2
      add :rate, :decimal, precision: 18, scale: 2
      add :admin_id, references(:tbl_railway_administrator, on_delete: :nothing)
      add :rate_id, references(:tbl_haulage_rates, on_delete: :nothing)
      add :maker_id, references(:tbl_users, on_delete: :nothing)
      add :checker_id, references(:tbl_users, on_delete: :nothing)
      add :currency_id, references(:tbl_currency, on_delete: :nothing)

      timestamps()
    end

    create index(:tbl_haulage, [:admin_id])
    create index(:tbl_haulage, [:rate_id])
    create index(:tbl_haulage, [:maker_id])
    create index(:tbl_haulage, [:checker_id])
    create index(:tbl_haulage, [:currency_id])
  end
end
