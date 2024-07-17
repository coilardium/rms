defmodule Rms.Repo.Migrations.AddCatalogeTblSpare do
  use Ecto.Migration

  def up do
    alter table(:tbl_spare_fees) do
      add :cataloge, :string
    end
  end

  def down do
    alter table(:tbl_spare_fees) do
      remove :cataloge
    end
  end
end
