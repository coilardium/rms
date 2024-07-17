defmodule Rms.Repo.Migrations.AddSurchargePercentToSurchargeFields do
  use Ecto.Migration

  def up do
    alter table(:tbl_surcharge) do
      add :surcharge_percent, :decimal, precision: 18, scale: 2
    end
  end

  def down do
    alter table(:tbl_surcharge) do
      remove :surcharge_percent
    end
  end
end
