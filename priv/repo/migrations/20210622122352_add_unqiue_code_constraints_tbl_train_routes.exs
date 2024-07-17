defmodule Rms.Repo.Migrations.AddUnqiueCodeConstraintsTblTrainRoutes do
  use Ecto.Migration

  def up do
    create(unique_index(:tbl_train_routes, [:code], name: :unique_code))
  end

  def down do
    drop(index(:tbl_train_routes, [:code], name: :unique_code))
  end
end
