defmodule Rms.Repo.Migrations.AlterTblCommodityGroupRemoveUniqueContraint do
  use Ecto.Migration

  def up do
    drop(index(:tbl_commodity_group, [:code], name: :unique_group_code))

    create(
      unique_index(:tbl_commodity_group, [:code],
        name: :unique_group_code,
        where: "code is not null"
      )
    )
  end

  def down do
    drop(index(:tbl_commodity_group, [:code], name: :unique_group_code))
    create(unique_index(:tbl_commodity_group, [:code], name: :unique_group_code))
  end
end
