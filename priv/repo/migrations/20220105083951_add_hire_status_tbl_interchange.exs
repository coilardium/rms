defmodule Rms.Repo.Migrations.AddHireStatusTblInterchange do
  use Ecto.Migration

  def up do
    alter table(:tbl_interchange) do
      add :hire_status, :string
    end
  end

  def down do
    alter table(:tbl_interchange) do
      remove :hire_status
    end
  end
end
