defmodule Rms.Repo.Migrations.AddOnHireDateTblInterchange do
  use Ecto.Migration

  def up do
    alter table(:tbl_interchange) do
      add :on_hire_date, :date
    end
  end

  def down do
    alter table(:tbl_interchange) do
      remove :on_hire_date
    end
  end
end
