defmodule Rms.Repo.Migrations.CreateTblMovement do
  use Ecto.Migration

  def change do
    create table(:tbl_movement) do
      add :wagon_id, :string
      add :orgin_station_id, :string
      add :destin_station_id, :string
      add :commodity_id, :string
      add :netweight, :string
      add :consigner, :string
      add :consignee, :string
      add :container_no, :string
      add :sales_order, :string
      add :station_code, :string
      add :consignment_date, :string
      add :payer_id, :string
      add :movement_date, :string
      add :movement_time, :string
      add :reporting_station, :string
      add :train_no, :string
      add :loco_id, :string
      add :dead_loco, :string
      add :origin, :string
      add :destination, :string
      add :maker_id, references(:tbl_users, on_delete: :nothing)
      add :checker_id, references(:tbl_users, on_delete: :nothing)

      timestamps()
    end

    create index(:tbl_movement, [:maker_id])
    create index(:tbl_movement, [:checker_id])
  end
end
