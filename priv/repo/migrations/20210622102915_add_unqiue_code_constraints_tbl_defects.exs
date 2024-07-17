defmodule Rms.Repo.Migrations.AddUnqiueCodeConstraintsTblDefects do
  use Ecto.Migration

  def up do
    create(unique_index(:tbl_defects, [:code], name: :unique_code))
  end

  def down do
    drop(index(:tbl_defects, [:code], name: :unique_code))
  end
end
