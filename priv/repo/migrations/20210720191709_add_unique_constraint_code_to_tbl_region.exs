defmodule Rms.Repo.Migrations.AddUniqueConstraintCodeToTblRegion do
  use Ecto.Migration

  def up do
    create(
      unique_index(:tbl_region, [:code], name: :unique_region_code, where: "code is not null")
    )
  end

  def down do
    drop(index(:tbl_region, [:code], name: :unique_region_code))
  end
end
