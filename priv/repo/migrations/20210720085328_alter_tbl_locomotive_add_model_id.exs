defmodule Rms.Repo.Migrations.AlterTblLocomotiveAddModelId do
  use Ecto.Migration

  def up do
    alter table(:tbl_locomotive) do
      add :model_id, references(:tbl_locomotive_models, column: :id, on_delete: :nothing)
    end
  end

  def down do
    alter table(:tbl_locomotive) do
      remove :model_id
    end
  end
end
