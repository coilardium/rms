defmodule Rms.Repo.Migrations.AddCommentTblInterchangeMaterial do
  use Ecto.Migration

  def up do
    alter table(:tbl_interchange_material) do
      add :comment, :string
    end
  end

  def down do
    alter table(:tbl_interchange_material) do
      remove :comment
    end
  end
end
