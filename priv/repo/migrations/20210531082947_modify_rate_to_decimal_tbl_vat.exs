defmodule Rms.Repo.Migrations.ModifyRateToDecimalTblVat do
  use Ecto.Migration

  def up do
    alter table(:tbl_vat) do
      remove(:rate)
      add(:rate, :decimal, precision: 18, scale: 2)
    end
  end

  def down do
    alter table(:tbl_vat) do
      remove(:rate)
      add(:rate, :string)
    end
  end
end
