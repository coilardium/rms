defmodule Rms.Repo.Migrations.AddTblMovementManualMatching do
  use Ecto.Migration

  def up do
    alter table(:tbl_movement) do
      add :manual_matching, :string
    end
  end

  def down do
    alter table(:tbl_movement) do
      remove :manual_matching
    end
  end
end
