defmodule Rms.Repo.Migrations.AddTblConsignmentManualMatching do
  use Ecto.Migration

  def up do
    alter table(:tbl_consignments) do
      add :manual_matching, :string
    end
  end

  def down do
    alter table(:tbl_consignments) do
      remove :manual_matching
    end
  end
end
