defmodule Rms.Repo.Migrations.AddUniqueCodeToTblComGroup do
  use Ecto.Migration

  def up do
    create unique_index(:tbl_commodity_group, [:code], name: :unique_group_code)
  end

  def down do
    drop index(:tbl_commodity_group, [:code], name: :unique_group_code)
  end
end
