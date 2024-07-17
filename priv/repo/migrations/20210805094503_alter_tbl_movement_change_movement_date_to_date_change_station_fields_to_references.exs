defmodule Rms.Repo.Migrations.AlterTblMovementChangeMovementDateToDateChangeStationFieldsToReferences do
  use Ecto.Migration

  def up do
    alter table(:tbl_movement) do
      remove :origin
      remove :destination
      remove :reporting_station
      add :movement_destination_id, references(:tbl_stations, column: :id, on_delete: :nothing)
      add :movement_origin_id, references(:tbl_stations, column: :id, on_delete: :nothing)

      add :movement_reporting_station_id,
          references(:tbl_stations, column: :id, on_delete: :nothing)
    end
  end

  def down do
    alter table(:tbl_movement) do
      remove :movement_destination_id
      remove :movement_origin_id
      remove :movement_reporting_station_id
      add :destination, :string
      add :origin, :string
      add :reporting_station, :string
    end
  end

  # field :consignee, :string
  #   field :consigner, :string
  #   field :consignment_date, :string
  #   field :container_no, :string
  #   field :dead_loco, :string
  #   field :status, :string, default: "PENDING"
  #   # field :destin_station_id, :integer
  #   field :, :string
  #   # field :loco_id, :integer
  #   field :movement_date, :string
  #   field :movement_time, :string
  #   field :netweight, :string
  #   # field :orgin_station_id, :integer
  #   field :, :string
  #   # field :payer_id, :integer
  #   field :, :string
  #   field :sales_order, :string
  #   field :station_code, :string
  #   field :train_no, :string
end
