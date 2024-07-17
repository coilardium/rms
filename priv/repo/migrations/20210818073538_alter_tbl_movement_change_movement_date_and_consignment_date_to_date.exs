defmodule Rms.Repo.Migrations.AlterTblMovementChangeMovementDateAndConsignmentDateToDate do
  use Ecto.Migration

  def up do
    alter table(:tbl_movement) do
      remove :consignment_date
      remove :movement_date
      add :consignment_date, :date
      add :movement_date, :date
    end
  end

  def down do
    alter table(:tbl_movement) do
      remove :consignment_date
      remove :movement_date
      add :consignment_date, :string
      add :movement_date, :string
    end
  end
end
