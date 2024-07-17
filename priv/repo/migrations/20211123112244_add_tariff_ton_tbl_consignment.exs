defmodule Rms.Repo.Migrations.AddTariffTonTblConsignment do
  use Ecto.Migration

  def up do
    # alter table(:tbl_consignments) do
    #   add :tariff_ton, :decimal, precision: 18, scale: 2
    # end
  end

  def down do
    # alter table(:tbl_consignments) do
    #   remove :tariff_ton
    # end
  end
end
