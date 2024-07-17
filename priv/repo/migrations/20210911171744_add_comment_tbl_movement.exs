defmodule Rms.Repo.Migrations.AddCommentTblMovement do
  use Ecto.Migration

  def up do
    alter table(:tbl_movement) do
      add :comment, :string
    end
  end

  def down do
    alter table(:tbl_movement) do
      remove :comment
    end
  end
end
