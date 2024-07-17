defmodule Rms.Repo.Migrations.CreateUniqueIndexCodeInTblRefuelingType do
  use Ecto.Migration

  def up do
    create(
      unique_index(:tbl_refueling_type, [:code],
        name: :unique_refueling_code,
        where: "code is not null"
      )
    )
  end

  def down do
    drop(index(:tbl_refueling_type, [:code], name: :unique_refueling_code))
  end
end
