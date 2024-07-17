defmodule Rms.Repo.Migrations.ModifyTarifFields do
  use Ecto.Migration

  def up do
    alter table(:tbl_tariff_line) do
      add :commodity_id, references(:tbl_commodity, column: :id, on_delete: :nothing)
      add :client_id, references(:tbl_clients, column: :id, on_delete: :delete_all)
      add :orig_station_id, references(:tbl_stations, column: :id, on_delete: :nothing)
      add :destin_station_id, references(:tbl_stations, column: :id, on_delete: :nothing)
      add :pay_type_id, references(:tbl_payment_type, column: :id, on_delete: :nothing)
      add :currency_id, references(:tbl_currency, column: :id, on_delete: :nothing)
      add :surcharge_id, references(:tbl_surcharge, column: :id, on_delete: :nothing)
      add :addional_chg, :decimal, precision: 18, scale: 2
      add :start_dt, :date
    end
  end

  def down do
    alter table(:tbl_tariff_line) do
      remove :commodity_id
      remove :client_id
      remove :orig_station_id
      remove :destin_station_id
      remove :pay_type_id
      remove :currency_id
      remove :surcharge_id
      remove :start_dt
      remove :addional_chg
    end
  end
end
