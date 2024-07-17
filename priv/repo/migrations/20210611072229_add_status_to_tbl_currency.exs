defmodule Rms.Repo.Migrations.AddStatusToTblCurrency do
  use Ecto.Migration

  def up do
    alter table(:tbl_currency) do
      add :status, :string
    end
  end

  def down do
    alter table(:tbl_currency) do
      remove :status
    end
  end
end
