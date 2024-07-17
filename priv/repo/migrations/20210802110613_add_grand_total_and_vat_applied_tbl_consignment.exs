defmodule Rms.Repo.Migrations.AddGrandTotalAndVatAppliedTblConsignment do
  use Ecto.Migration

  def up do
    alter table(:tbl_consignments) do
      add :vat_applied, :string
      add :grand_total, :decimal, precision: 18, scale: 2
    end
  end

  def down do
    alter table(:tbl_consignments) do
      remove :vat_applied
      remove :grand_total
    end
  end
end
