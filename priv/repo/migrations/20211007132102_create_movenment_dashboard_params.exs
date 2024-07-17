defmodule Rms.Repo.Migrations.CreateMovenmentDashboardParams do
  use Ecto.Migration

  def change do
    execute """
            CREATE VIEW [dbo].[vw_movement_dashboard_params] AS(
              SELECT
              id,
              netweight,
              container_no,
              sales_order,
              station_code,
              movement_time,
              train_no,
              dead_loco,
              maker_id,
              checker_id,
              inserted_at,
              updated_at,
              consignment_id,
              batch_id,
              wagon_id,
              commodity_id,
              origin_station_id,
              destin_station_id,
              payer_id,
              loco_id,
              movement_destination_id,
              movement_origin_id,
              movement_reporting_station_id,
              train_list_no,
              consignee_id,
              consigner_id,
              consignment_date,
              movement_date,
              loco_no,
              manual_matching,
              comment,
              user_region_id,
            CASE WHEN status = 'APPROVED' THEN 'MOVEMENT_COMPLETE'
            WHEN status = 'DISCARED' THEN 'MOVEMENT_DISCARED'
            WHEN status = 'PENDING_VERIFICATION' THEN 'MOVEMENT_PENDING_VERIFICATION'
            WHEN status = 'REJECTED' THEN 'MOVEMENT_REJECTED'
            END AS status
            FROM tbl_movement
            
            )
            """,
            "DROP VIEW [dbo].[vw_movement_dashboard_params]"
  end
end
