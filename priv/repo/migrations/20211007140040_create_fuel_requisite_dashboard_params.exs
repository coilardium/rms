defmodule Rms.Repo.Migrations.CreateFuelRequisiteDashboardParams do
  use Ecto.Migration

  def change do
    execute """
            CREATE VIEW [dbo].[vw_fuel_requisite_dashboard_params] AS(
            SELECT
              id,
               loco_no,
               train_number,
               requisition_no,
               seal_number_at_arrival,
               seal_number_at_depture,
               seal_color_at_arrival,
               seal_color_at_depture,
               time,
               balance_before_refuel,
               approved_refuel,
               quantity_refueled,
               deff_ctc_actual,
               reading_after_refuel,
               bp_meter_before,
               bp_meter_after,
               reading,
               Km_to_destination,
               fuel_consumed,
               consumption_per_km,
               fuel_rate,
               section,
               date,
               week_no,
               total_cost,
               comment,
               loco_id,
               loco_driver_id,
               train_type_id,
               commercial_clerk_id,
               depo_refueled_id,
               train_destination_id,
               maker_id,
               checker_id,
               inserted_at,
               updated_at,
               batch_id,
               train_origin_id,
               km_to_destin,
               meter_at_destin,
               oil_rep_name,
               asset_protection_officers_name,
               other_refuel,
               other_refuel_no,
               stn_foreman,
               depo_stn_rate,
               refuel_type,
               section_id,
               user_region_id,
            CASE WHEN status = 'COMPLETE' THEN 'FUEL_REQUISITE_COMPLETE'
            WHEN status = 'PENDING_CONTROL' THEN 'FUEL_REQUISITE_PENDING_CONTROL'
            WHEN status = 'PENDING_COMPLETION' THEN 'FUEL_REQUISITE_PENDING_COMPLETION'
            WHEN status = 'REJECTED' THEN 'FUEL_REQUISITE_REJECTED'
            WHEN status = 'PENDING_APPROVAL' THEN 'FUEL_REQUISITE_PENDING_APPROVAL'
            
            END AS status
            FROM tbl_fuel_monitoring
            )
            """,
            "DROP VIEW [dbo].[vw_fuel_requisite_dashboard_params]"
  end
end
