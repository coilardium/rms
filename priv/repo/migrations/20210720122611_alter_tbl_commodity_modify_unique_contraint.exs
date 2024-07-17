defmodule Rms.Repo.Migrations.AlterTblCommodityModifyUniqueContraint do
  use Ecto.Migration

  def up do
    create(unique_index(:tbl_commodity, [:code], name: :unique_code, where: "code is not null"))
  end

  def down do
    drop(index(:tbl_commodity, [:code], name: :unique_code))
  end
end
