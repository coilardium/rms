defmodule Rms.Repo.Migrations.AddLocoNoTblMovement do
  use Ecto.Migration

  def up do
    alter table(:tbl_movement) do
      add :loco_no, :string
    end
  end

  def down do
    alter table(:tbl_movement) do
      remove :loco_no
    end
  end
end
