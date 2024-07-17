defmodule Rms.Repo.Migrations.AddStationCodeTblCommodity do
  use Ecto.Migration

  def up do
    alter table(:tbl_commodity) do
      add :commodity_code, :string
    end
  end

  def down do
    alter table(:tbl_commodity) do
      remove :commodity_code
    end
  end
end
