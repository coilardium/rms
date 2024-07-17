defmodule Rms.Repo.Migrations.AddUniqueWagonIdEquipmentIdtblInterchangeAuxiliary do
  use Ecto.Migration

  def up do
    create unique_index(:tbl_interchange_auxiliary, [:wagon_id, :equipment_id],
             name: :unique_interchange_auxiliary,
             where: "auth_status ='PENDING'"
           )
  end

  def down do
    drop unique_index(:tbl_interchange_auxiliary, [:wagon_id, :equipment_id],
           name: :unique_interchange_auxiliary,
           where: "auth_status ='PENDING'"
         )
  end
end
