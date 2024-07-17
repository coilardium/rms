defmodule Rms.Repo.Migrations.AddStatusTblLocoDetention do
  use Ecto.Migration

  def up do
    alter table(:tbl_loco_detention) do
      add :modification_reason, :string
    end
  end

  def down do
    alter table(:tbl_loco_detention) do
      remove :modification_reason
    end
  end
end
