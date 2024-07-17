defmodule Rms.Repo.Migrations.ModifyTblInterchangeFees do
  use Ecto.Migration

  def up do
    flush()
    create unique_index(:tbl_interchange_fees, [:effective_date, :partner_id, :wagon_type_id, :amount], name: :unique_interchange_fee)
  end

  def down do
    drop index(:tbl_interchange_fees, [:effective_date, :partner_id, :wagon_type_id, :amount], name: :unique_interchange_fee)
    flush()
  end
end
