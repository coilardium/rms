defmodule Rms.Repo.Migrations.AddUnqiueCodeConstraintsTblTblInterchangeFees do
  use Ecto.Migration

  def up do
    flush()

    create unique_index(:tbl_interchange_fees, [:amount, :year, :partner_id, :currency_id],
             name: :unique_fee_index
           )
  end

  def down do
    drop index(:tbl_interchange_fees, [:amount, :year, :partner_id, :currency_id],
           name: :unique_fee_index
         )

    flush()
  end
end
