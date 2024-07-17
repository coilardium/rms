defmodule Rms.Repo.Migrations.AddUniqueCodeConstriantToTblTrainType do
  use Ecto.Migration

  def up do
    create(
      unique_index(:tbl_train_type, [:code],
        name: :unique_train_type_code,
        where: "code is not null"
      )
    )
  end

  def down do
    drop(index(:tbl_train_type, [:code], name: :unique_train_type_code))
  end
end
