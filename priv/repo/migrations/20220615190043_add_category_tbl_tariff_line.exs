defmodule Rms.Repo.Migrations.AddCategoryTblTariffLine do
  use Ecto.Migration

  def up do
    alter table(:tbl_tariff_line) do
      add :category, :string
    end
  end

  def down do
    alter table(:tbl_tariff_line) do
      remove :category
    end
  end
end
