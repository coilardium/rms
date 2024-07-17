defmodule Rms.Repo.Migrations.AddPendingInviceCosgntDashboadVwCreate do
  use Ecto.Migration

  def change do
    execute """
            CREATE VIEW [dbo].[vw_consgnt_dashboard_params] AS(
              SELECT
              id,
              code,
              customer_ref,
              payee_id,
              sale_order,
              station_code,
              vat_id,
              maker_id,
              checker_id,
              inserted_at,
              updated_at,
              commodity_id,
              consignee_id,
              consigner_id,
              customer_id,
              final_destination_id,
              origin_station_id,
              reporting_station_id,
              tarrif_id,
              vat_amount,
              invoice_no,
              payer_id,
              wagon_id,
              comment,
              capacity_tonnes,
              actual_tonnes,
              tariff_tonnage,
              batch_id,
              tariff_origin_id,
              tariff_destination_id,
              capture_date,
              document_date,
              verifier_id,
              acc_checker_id,
              invoice_date,
              invoice_amount,
              invoice_term,
              invoice_currency_id,
              route_id,
              vat_applied,
              grand_total,
              total,
              user_region_id,
              total_containers,
            CASE WHEN status = 'COMPLETE' THEN 'CONSIGNMENT_COMPLETE'
            WHEN status = 'PENDING_INVOICE' THEN 'CONSIGNMENT_COMPLETE'
            WHEN status = 'PENDING_APPROVAL' THEN 'CONSIGNMENT_PENDING_APPROVAL'
            WHEN status = 'DISCARDED' THEN 'CONSIGNMENT_DISCARDED'
            WHEN status = 'REJECTED' THEN 'CONSIGNMENT_REJECTED'
            WHEN status = 'PENDING_VERIFICATION' THEN 'CONSIGNMENT_PENDING_VERIFICATION'

            END AS status
            FROM tbl_consignments

            )
            """,
            "DROP VIEW [dbo].[vw_consgnt_dashboard_params]"
  end
end
