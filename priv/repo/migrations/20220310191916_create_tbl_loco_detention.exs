defmodule Rms.Repo.Migrations.CreateTblLocoDetention do
  use Ecto.Migration

  def change do
    create table(:tbl_loco_detention) do
      add :status, :string
      add :comment, :string
      add :interchange_date, :date
      add :arrival_date, :date
      add :arrival_time, :string
      add :departure_date, :date
      add :departure_time, :string
      add :train_no, :string
      add :direction, :string
      add :chargeable_delay, :integer
      add :actual_delay, :integer
      add :grace_period, :integer
      add :amount, :decimal, precision: 18, scale: 2
      add :rate, :decimal, precision: 18, scale: 2
      add :maker_id, references(:tbl_users, on_delete: :nothing)
      add :checker_id, references(:tbl_users, on_delete: :nothing)
      add :admin_id, references(:tbl_railway_administrator, on_delete: :nothing)
      add :locomotive_id, references(:tbl_locomotive, on_delete: :nothing)
      add :currency_id, references(:tbl_currency, on_delete: :nothing)
      add :dentention_rate_id, references(:tbl_loco_dentention_rates, on_delete: :nothing)

      timestamps()
    end

    create index(:tbl_loco_detention, [:maker_id])
    create index(:tbl_loco_detention, [:checker_id])
    create index(:tbl_loco_detention, [:admin_id])
    create index(:tbl_loco_detention, [:locomotive_id])
    create index(:tbl_loco_detention, [:currency_id])
    create index(:tbl_loco_detention, [:dentention_rate_id])
  end
end
