defmodule Rms.Repo.Migrations.AlterTblTrainRoutesModifyUniqueContraint do
  use Ecto.Migration

  def up do
    drop(index(:tbl_train_routes, [:code], name: :unique_code))

    create(
      unique_index(:tbl_train_routes, [:code], name: :unique_code, where: "code is not null")
    )
  end

  def down do
    drop(index(:tbl_train_routes, [:code], name: :unique_code))
    create(unique_index(:tbl_train_routes, [:code], name: :unique_code))
  end
end
