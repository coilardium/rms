defmodule Rms.Repo.Migrations.ModifyTotalAccAmountTblInterchangeAuxilxilary do
  use Ecto.Migration

  def up do
    alter table(:tbl_interchange_auxiliary) do
      add :total_amount, :decimal, precision: 18, scale: 2
    end
  end

  def down do
    alter table(:tbl_interchange_auxiliary) do
      remove :total_amount
    end
  end
end
