defmodule Rms.Repo.Migrations.DropUniqueIndexUniqueFeeIndex do
  use Ecto.Migration

  def up do
    flush()

    drop index(:tbl_interchange_fees, [:amount, :year, :partner_id, :currency_id],
           name: :unique_fee_index
         )

    create unique_index(:tbl_interchange_fees, [:year, :partner_id],
             name: :unique_interchange_fee_index
           )
  end

  def down do
    create unique_index(:tbl_interchange_fees, [:amount, :year, :partner_id, :currency_id],
             name: :unique_fee_index
           )

    drop index(:tbl_interchange_fees, [:year, :partner_id], name: :unique_interchange_fee_index)

    flush()
  end
end
