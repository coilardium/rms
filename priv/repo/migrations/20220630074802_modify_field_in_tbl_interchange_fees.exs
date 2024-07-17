defmodule Rms.Repo.Migrations.ModifyFieldInTblInterchangeFees do
  use Ecto.Migration

  def up do
    alter table(:tbl_interchange_fees) do
      add :effective_date, :date
    end
  end

  def down do
    alter table(:tbl_interchange_fees) do
      remove :effective_date
    end
  end
end
