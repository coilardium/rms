defmodule Rms.Repo.Migrations.AddTypeToTblCurrency do
  use Ecto.Migration

  def up do
    alter table(:tbl_currency) do
      add :type, :string
    end
  end

  def down do
    alter table(:tbl_currency) do
      remove :type
    end
  end
end
