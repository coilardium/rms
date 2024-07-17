defmodule Rms.Repo.Migrations.AddUpdateDateAndBoundTblInterchange do
  use Ecto.Migration

  def up do
    alter table(:tbl_interchange) do
      add :update_date, :date
      add :bound, :string
    end
  end

  def down do
    alter table(:tbl_interchange) do
      remove :update_date
      remove :bound
    end
  end
end
