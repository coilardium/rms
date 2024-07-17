defmodule Rms.Repo.Migrations.CreateTblInterchange do
  use Ecto.Migration

  def change do
    create table(:tbl_interchange) do
      add :comment, :string
      add :direction, :string
      add :status, :string
      add :entry_date, :date
      add :exit_date, :date
      add :accumulative_days, :integer
      add :accumulative_amount, :decimal, precision: 18, scale: 2
      add :interchange_fee, :decimal, precision: 18, scale: 2
      add :maker_id, references(:tbl_users, on_delete: :nothing)
      add :checker_id, references(:tbl_users, on_delete: :nothing)
      add :wagon_id, references(:tbl_wagon, on_delete: :nothing)
      # add :wagon_status_id, references(:tbl_wagon_status, on_delete: :nothing)
      add :commodity_id, references(:tbl_commodity, on_delete: :nothing)
      add :adminstrator_id, references(:tbl_railway_administrator, on_delete: :nothing)
      add :interchange_point, references(:tbl_stations, on_delete: :nothing)
      add :interchange_fee_id, references(:tbl_interchange_fees, on_delete: :nothing)
      add :locomotive_id, references(:tbl_locomotive, on_delete: :nothing)

      timestamps()
    end

    create index(:tbl_interchange, [:maker_id])
    create index(:tbl_interchange, [:checker_id])
    create index(:tbl_interchange, [:wagon_id])
    # create index(:tbl_interchange, [:wagon_status_id])
    create index(:tbl_interchange, [:commodity_id])
    create index(:tbl_interchange, [:adminstrator_id])
    create index(:tbl_interchange, [:interchange_point])
    create index(:tbl_interchange, [:interchange_fee_id])
    create index(:tbl_interchange, [:locomotive_id])
  end
end
