defmodule Rms.Repo.Migrations.AddHasConsignmentTblMovement do
  use Ecto.Migration

  def up do
    alter table(:tbl_movement) do
      add :has_consignmt, :string
    end
  end

  def down do
    alter table(:tbl_movement) do
      remove :has_consignmt
    end
  end
end
