defmodule Rms.Repo.Migrations.AddPurCodeTblCondition do
  use Ecto.Migration

  def up do
    alter table(:tbl_condition) do
      add :pur_code, :string
    end
  end

  def down do
    alter table(:tbl_condition) do
      remove :pur_code
    end
  end
end
