defmodule Rms.Repo.Migrations.AddFieldToTblWagon do
  use Ecto.Migration

  def up do
    alter table(:tbl_wagon) do
      add :wagon_symbol, :string
    end
  end

  def down do
    alter table(:tbl_wagon) do
      remove :wagon_symbol
    end
  end
end
