defmodule Rms.Repo.Migrations.AddAdditionalChgTblTariffline do
  use Ecto.Migration

  def up do
    alter table(:tbl_tariff_line) do
      add(:additional_chg, :decimal, precision: 18, scale: 2)
    end
  end

  def down do
    alter table(:tbl_tariff_line) do
      remove(:additional_chg)
    end
  end
end
