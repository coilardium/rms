defmodule Rms.Repo.Migrations.CreateTblConsignments do
  use Ecto.Migration

  def change do
    create table(:tbl_consignments) do
      add :capture_date, :string
      add :code, :string
      add :commodity_id, :integer
      add :consignee_id, :integer
      add :consigner_id, :integer
      add :customer_id, :integer
      add :customer_ref, :string
      add :document_date, :string
      add :final_destination_id, :integer
      add :origin_station_id, :integer
      add :payee_id, :integer
      add :reporting_station_id, :integer
      add :sale_order, :string
      add :station_code, :string
      add :status, :string
      add :tariff_destination_id, :integer
      add :tariff_origin_id, :integer
      add :vat_id, :integer
      add :maker_id, references(:tbl_users, on_delete: :nothing)
      add :checker_id, references(:tbl_users, on_delete: :nothing)

      timestamps()
    end

    create index(:tbl_consignments, [:maker_id])
    create index(:tbl_consignments, [:checker_id])
  end
end
