defmodule Rms.Repo.Migrations.AddCategoryTblWagonTypes do
  use Ecto.Migration
  def up do
    alter table(:tbl_wagon_type) do
      add :category, :string
    end
  end

  def down do
    alter table(:tbl_wagon_type) do
      remove :category
    end
  end
end
