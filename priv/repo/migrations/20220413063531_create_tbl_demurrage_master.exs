defmodule Rms.Repo.Migrations.CreateTblDemurrageMaster do
  use Ecto.Migration

  def change do
    create table(:tbl_demurrage_master) do
      add :yard, :integer
      add :sidings, :integer
      add :total_days, :integer
      add :total_charge, :decimal, precision: 18, scale: 2
      add :charge_rate, :decimal, precision: 18, scale: 2
      add :comment, :string
      add :arrival_dt, :date
      add :date_placed, :date
      add :dt_placed_over_weekend, :date
      add :date_offloaded, :date
      add :date_loaded, :date
      add :date_cleared, :date
      add :commodity_in_id, references(:tbl_commodity, on_delete: :nothing)
      add :commodity_out_id, references(:tbl_commodity, on_delete: :nothing)
      add :wagon_id, references(:tbl_wagon, on_delete: :nothing)
      add :maker_id, references(:tbl_users, on_delete: :nothing)
      add :currency_id, references(:tbl_currency, on_delete: :nothing)

      timestamps()
    end

    create index(:tbl_demurrage_master, [:commodity_in_id])
    create index(:tbl_demurrage_master, [:commodity_out_id])
    create index(:tbl_demurrage_master, [:wagon_id])
    create index(:tbl_demurrage_master, [:maker_id])
    create index(:tbl_demurrage_master, [:currency_id])
  end
end
