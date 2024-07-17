defmodule Rms.Repo.Migrations.AddUnqiueCodeConstraintsTblWagon do
  use Ecto.Migration

  def up do
    create(unique_index(:tbl_wagon, [:code], name: :unique_code))
  end

  def down do
    drop(index(:tbl_wagon, [:code], name: :unique_code))
  end
end
