defmodule Rms.Repo.Migrations.AddPurCodeTblWagonStatus do
  use Ecto.Migration

  def up do
    alter table(:tbl_wagon_status) do
      add :pur_code, :string
    end
  end

  def down do
    alter table(:tbl_wagon_status) do
      remove :pur_code
    end
  end
end
