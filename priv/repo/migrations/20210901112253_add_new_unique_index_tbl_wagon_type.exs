defmodule Rms.Repo.Migrations.AddNewUniqueIndexTblWagonType do
  use Ecto.Migration

  def up do
    drop(index(:tbl_wagon_type, [:code], name: :unique_code))
    create(unique_index(:tbl_wagon_type, [:code], name: :unique_code, where: "code is not null"))
  end

  def down do
    drop(index(:tbl_wagon_type, [:code], name: :unique_code))
    create(unique_index(:tbl_wagon_type, [:code], name: :unique_code))
  end
end
