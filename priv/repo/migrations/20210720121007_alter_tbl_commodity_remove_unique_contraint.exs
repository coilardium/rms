defmodule Rms.Repo.Migrations.AlterTblCommodityRemoveUniqueContraint do
  use Ecto.Migration

  def up do
    drop(index(:tbl_commodity, [:code], name: :unique_code))
  end

  def down do
    create(unique_index(:tbl_commodity, [:code], name: :unique_code))
  end
end
