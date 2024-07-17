defmodule Rms.Repo.Migrations.AddTrainNoTblInterchange do
  use Ecto.Migration

  def up do
    alter table(:tbl_interchange) do
      add :train_no, :string
    end
  end

  def down do
    alter table(:tbl_interchange) do
      remove :train_no
    end
  end
end
