defmodule Rms.Repo.Migrations.AlterTblMovementAddTrainListNo do
  use Ecto.Migration

  def up do
    alter table(:tbl_movement) do
      add :train_list_no, :string
    end
  end

  def down do
    alter table(:tbl_movement) do
      remove :train_list_no
    end
  end
end
