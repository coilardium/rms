defmodule Rms.Repo.Migrations.AddOnHireDateTblInterchangeAuxiliary do
  use Ecto.Migration

  def up do
    alter table(:tbl_interchange_auxiliary) do
      add :on_hire_date, :date
    end
  end

  def down do
    alter table(:tbl_interchange_auxiliary) do
      remove :on_hire_date
    end
  end
end
