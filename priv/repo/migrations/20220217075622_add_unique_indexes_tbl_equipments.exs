defmodule Rms.Repo.Migrations.AddUniqueIndexesTblEquipments do
  use Ecto.Migration

  def up do
    create(unique_index(:tbl_equipments, [:code], name: :unique_code, where: "code is not null"))
    create(unique_index(:tbl_equipments, [:description], name: :unique_description))
  end

  def down do
    drop(unique_index(:tbl_equipments, [:code], name: :unique_code))
    drop(unique_index(:tbl_equipments, [:code], name: :unique_description))
  end
end
