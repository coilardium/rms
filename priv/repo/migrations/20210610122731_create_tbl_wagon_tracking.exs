defmodule Rms.Repo.Migrations.CreateTblWagonTracking do
  use Ecto.Migration

  def change do
    create table(:tbl_wagon_tracking) do
      add :update_date, :date
      add :departure, :string
      add :arrival, :string
      add :train_no, :string
      add :yard_siding, :string
      add :sub_category, :string
      add :comment, :string
      add :net_ton, :decimal
      add :bound, :string
      add :allocated_to_customer, :string
      add :hire, :string
      add :wagon_id, references(:tbl_wagon, on_delete: :nothing)
      add :current_location_id, references(:tbl_stations, on_delete: :nothing)
      add :condition_id, references(:tbl_condition, on_delete: :nothing)
      add :commodity_id, references(:tbl_commodity, on_delete: :nothing)
      add :customer_id, references(:tbl_users, on_delete: :nothing)
      add :origin_id, references(:tbl_stations, on_delete: :nothing)
      add :destination_id, references(:tbl_stations, on_delete: :nothing)
      add :maker_id, references(:tbl_users, on_delete: :nothing)
      add :checker_id, references(:tbl_users, on_delete: :nothing)

      timestamps()
    end

    create index(:tbl_wagon_tracking, [:wagon_id])
    create index(:tbl_wagon_tracking, [:current_location_id])
    create index(:tbl_wagon_tracking, [:condition_id])
    create index(:tbl_wagon_tracking, [:commodity_id])
    create index(:tbl_wagon_tracking, [:customer_id])
    create index(:tbl_wagon_tracking, [:origin_id])
    create index(:tbl_wagon_tracking, [:destination_id])
    create index(:tbl_wagon_tracking, [:maker_id])
    create index(:tbl_wagon_tracking, [:checker_id])
  end
end
