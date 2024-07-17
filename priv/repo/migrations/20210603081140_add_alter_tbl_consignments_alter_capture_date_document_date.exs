defmodule Rms.Repo.Migrations.AddAlterTblConsignmentsAlterCaptureDateDocumentDate do
  use Ecto.Migration

  def up do
    alter table(:tbl_consignments) do
      remove :capture_date
      remove :document_date
      add :capture_date, :date
      add :document_date, :date
    end
  end

  def down do
    alter table(:tbl_consignments) do
      remove :capture_date
      remove :document_date
    end
  end
end
