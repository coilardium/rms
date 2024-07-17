defmodule Rms.Repo.Migrations.AddStatusTblTariffLine do
  use Ecto.Migration

  def up do
    alter table(:tbl_tariff_line) do
      add :status, :string
    end
  end

  def down do
    alter table(:tbl_tariff_line) do
      remove :status
    end
  end
end
