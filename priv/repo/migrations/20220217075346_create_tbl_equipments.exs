defmodule Rms.Repo.Migrations.CreateTblEquipments do
  use Ecto.Migration

  def change do
    create table(:tbl_equipments) do
      add :code, :string
      add :description, :string

      timestamps()
    end
  end
end
