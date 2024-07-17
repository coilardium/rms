defmodule Rms.Repo.Migrations.AddAmountManHoursSurchangeIdCurrency do
  use Ecto.Migration

  def up do
    alter table(:tbl_defects) do
      add :currency_id, references(:tbl_currency, column: :id, on_delete: :nothing)
      # add :surchange_id, references(:tbl_surcharge, column: :id, on_delete: :nothing)
      add :type, :string
      add :cost, :decimal, precision: 18, scale: 2
      add :man_hours, :decimal, precision: 18, scale: 2
    end
  end

  def down do
    alter table(:tbl_defects) do
      remove :currency_id
      # remove :surchange_id
      remove :type
      remove :cost
      remove :man_hours
    end
  end
end
