defmodule Rms.Repo.Migrations.AddModifierIdTblMovement do
  use Ecto.Migration

  def up do
    alter table(:tbl_movement) do
      add :modifier_id, references(:tbl_users, column: :id, on_delete: :nothing)
    end
  end

  def down do
    alter table(:tbl_movement) do
      remove :modifier_id
    end
  end
end
