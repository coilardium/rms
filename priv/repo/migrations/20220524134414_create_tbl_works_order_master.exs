defmodule Rms.Repo.Migrations.CreateTblWorksOrderMaster do
  use Ecto.Migration

  def change do
    create table(:tbl_works_order_master) do
      add :comment, :string
      add :date_on_label, :date
      add :off_loading_date, :date
      add :order_no, :string
      add :time_out, :string
      add :yard_foreman, :string
      add :area_name, :string
      add :train_no, :string
      add :driver_name, :string
      add :departure_time, :string
      add :departure_date, :date
      add :time_arrival, :string
      add :placed, :string
      add :load_date, :date
      add :supplied, :string
      add :client_id, references(:tbl_clients, on_delete: :nothing)
      add :wagon_id, references(:tbl_wagon, on_delete: :nothing)
      add :commodity_id, references(:tbl_commodity, on_delete: :nothing)
      add :origin_station_id, references(:tbl_stations, on_delete: :nothing)
      add :destin_station_id, references(:tbl_stations, on_delete: :nothing)
      add :maker_id, references(:tbl_users, on_delete: :nothing)

      timestamps()
    end

    create index(:tbl_works_order_master, [:client_id])
    create index(:tbl_works_order_master, [:wagon_id])
    create index(:tbl_works_order_master, [:commodity_id])
    create index(:tbl_works_order_master, [:origin_station_id])
    create index(:tbl_works_order_master, [:destin_station_id])
    create index(:tbl_works_order_master, [:maker_id])
  end
end
