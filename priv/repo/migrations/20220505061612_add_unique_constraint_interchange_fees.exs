defmodule Rms.Repo.Migrations.AddUniqueConstraintInterchangeFees do
  use Ecto.Migration

  def up do
    flush()

    drop_if_exists unique_index(:tbl_interchange_fees, [:year, :partner_id],
                     name: :unique_interchange_fee_index
                   )

    create_if_not_exists unique_index(:tbl_interchange_fees, [:year, :partner_id, :wagon_type_id],
                           name: :unique_interchange_fee_index
                         )
  end

  def down do
    flush()

    drop_if_exists unique_index(:tbl_interchange_fees, [:year, :partner_id, :wagon_type_id],
                     name: :unique_interchange_fee_index
                   )

    create_if_not_exists unique_index(:tbl_interchange_fees, [:year, :partner_id],
                           name: :unique_interchange_fee_index
                         )
  end
end
