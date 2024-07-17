defmodule Rms.Repo.Migrations.CreateTblFuelMonitoring do
  use Ecto.Migration

  def change do
    create table(:tbl_fuel_monitoring) do
      add :loco_no, :string
      add :train_number, :string
      add :requisition_no, :string
      add :seal_number_at_arrival, :string
      add :seal_number_at_depture, :string
      add :seal_color_at_arrival, :string
      add :seal_color_at_depture, :string
      add :time, :string
      add :balance_before_refuel, :decimal
      add :approved_refuel, :decimal
      add :quantity_refueled, :decimal
      add :deff_ctc_actual, :decimal
      add :reading_after_refuel, :decimal
      add :bp_meter_before, :decimal
      add :bp_meter_after, :decimal
      add :reading, :decimal
      add :Km_to_destination, :decimal
      add :fuel_consumed, :decimal
      add :consumption_per_km, :decimal
      add :fuel_rate, :decimal
      add :section, :string
      add :date, :date
      add :week_no, :string
      add :total_cost, :decimal
      add :comment, :string
      add :loco_id, references(:tbl_locomotive_type, on_delete: :nothing)
      add :loco_driver_id, references(:tbl_loco_driver, on_delete: :nothing)
      add :train_type_id, references(:tbl_train_type, on_delete: :nothing)
      add :commercial_clerk_id, references(:tbl_users, on_delete: :nothing)
      add :depo_refueled_id, references(:tbl_fuel_rates, on_delete: :nothing)
      add :train_destination_id, references(:tbl_stations, on_delete: :nothing)
      add :maker_id, references(:tbl_users, on_delete: :nothing)
      add :checker_id, references(:tbl_users, on_delete: :nothing)

      timestamps()
    end

    create index(:tbl_fuel_monitoring, [:loco_id])
    create index(:tbl_fuel_monitoring, [:loco_driver_id])
    create index(:tbl_fuel_monitoring, [:train_type_id])
    create index(:tbl_fuel_monitoring, [:commercial_clerk_id])
    create index(:tbl_fuel_monitoring, [:depo_refueled_id])
    create index(:tbl_fuel_monitoring, [:train_destination_id])
    create index(:tbl_fuel_monitoring, [:maker_id])
    create index(:tbl_fuel_monitoring, [:checker_id])
  end
end
