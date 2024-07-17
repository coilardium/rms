defmodule Rms.Repo.Migrations.AddUnqiueCodeConstraintsTblLocomotiveType do
  use Ecto.Migration

  def up do
    create(unique_index(:tbl_locomotive_type, [:code], name: :unique_code))
  end

  def down do
    drop(index(:tbl_locomotive_type, [:code], name: :unique_code))
  end
end
