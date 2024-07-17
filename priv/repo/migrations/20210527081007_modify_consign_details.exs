defmodule Rms.Repo.Migrations.ModifyConsignDetails do
  use Ecto.Migration

  def up do
    alter table(:tbl_consignments) do
      remove_if_exists(:commodity_id, :integer)
      remove_if_exists(:consignee_id, :integer)
      remove_if_exists(:consigner_id, :integer)
      remove_if_exists(:customer_id, :integer)
      remove_if_exists(:final_destination_id, :integer)
      remove_if_exists(:origin_station_id, :integer)
      remove_if_exists(:reporting_station_id, :integer)
      add :commodity_id, references(:tbl_commodity, column: :id)
      add :consignee_id, references(:tbl_clients, column: :id)
      add :consigner_id, references(:tbl_clients, column: :id)
      add :customer_id, references(:tbl_clients, column: :id)
      add :final_destination_id, references(:tbl_stations, column: :id)
      add :origin_station_id, references(:tbl_stations, column: :id)
      add :reporting_station_id, references(:tbl_stations, column: :id)
      add :tarrif_id, references(:tbl_tariff_line, column: :id)
      add :vat_amount, :decimal, precision: 18, scale: 2
      add :invoice_no, :string
      add :payer_id, references(:tbl_clients, column: :id)
      add :rsz, :decimal, precision: 18, scale: 2
      add :nlpi, :decimal, precision: 18, scale: 2
      add :nll_2005, :decimal, precision: 18, scale: 2
      add :tfr, :decimal, precision: 18, scale: 2
      add :tzr, :decimal, precision: 18, scale: 2
      add :tzr_project, :decimal, precision: 18, scale: 2
      add :additional_chg, :decimal, precision: 18, scale: 2
    end

    create index(:tbl_consignments, [:commodity_id])
    create index(:tbl_consignments, [:consignee_id])
    create index(:tbl_consignments, [:consigner_id])
    create index(:tbl_consignments, [:customer_id])
    create index(:tbl_consignments, [:final_destination_id])
    create index(:tbl_consignments, [:origin_station_id])
    create index(:tbl_consignments, [:reporting_station_id])
    create index(:tbl_consignments, [:tarrif_id])
    create index(:tbl_consignments, [:payer_id])
  end

  def down do
    alter table(:tbl_consignments) do
      remove_if_exists(:commodity_id, references(:tbl_commodity, column: :id))
      remove_if_exists(:consignee_id, references(:tbl_clients, column: :id))
      remove_if_exists(:consigner_id, references(:tbl_clients, column: :id))
      remove_if_exists(:customer_id, references(:tbl_clients, column: :id))
      remove_if_exists(:final_destination_id, references(:tbl_stations, column: :id))
      remove_if_exists(:origin_station_id, references(:tbl_stations, column: :id))
      remove_if_exists(:reporting_station_id, references(:tbl_stations, column: :id))
      remove_if_exists(:tarrif_id, references(:tbl_tariff_line, column: :id))
      remove_if_exists(:vat_amount, :decimal)
      remove_if_exists(:invoice_no, :string)
      remove_if_exists(:payer_id, references(:tbl_clients, column: :id))
      remove_if_exists(:rsz, :decimal)
      remove_if_exists(:nlpi, :decimal)
      remove_if_exists(:nll_2005, :decimal)
      remove_if_exists(:tfr, :decimal)
      remove_if_exists(:tzr, :decimal)
      remove_if_exists(:tzr_project, :decimal)
      remove_if_exists(:additional_chg, :decimal)
      add_if_not_exists(:commodity_id, :integer)
      add_if_not_exists(:consignee_id, :integer)
      add_if_not_exists(:consigner_id, :integer)
      add_if_not_exists(:customer_id, :integer)
      add_if_not_exists(:final_destination_id, :integer)
      add_if_not_exists(:origin_station_id, :integer)
      add_if_not_exists(:reporting_station_id, :integer)
    end
  end
end
