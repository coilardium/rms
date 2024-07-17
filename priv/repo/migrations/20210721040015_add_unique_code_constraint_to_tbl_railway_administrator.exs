defmodule Rms.Repo.Migrations.AddUniqueCodeConstraintToTblRailwayAdministrator do
  use Ecto.Migration

  def up do
    create(
      unique_index(:tbl_railway_administrator, [:code],
        name: :unique_operator_code,
        where: "code is not null"
      )
    )
  end

  def down do
    drop(index(:tbl_railway_administrator, [:code], name: :unique_operator_code))
  end
end
