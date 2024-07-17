defmodule Rms.Repo.Migrations.AddUniqueConstraintsToTblMovement do
  use Ecto.Migration

  def up do
    create unique_index(:tbl_movement, [:wagon_id, :station_code],
             name: :unique_station_wagon,
             where: "status !='DISCARDED'"
           )

    create unique_index(:tbl_movement, [:wagon_id, :train_list_no],
             name: :unique_train_list_wagon,
             where: "status !='DISCARDED'"
           )

    create unique_index(:tbl_movement, [:wagon_id, :train_no],
             name: :unique_train_no_wagon,
             where: "status !='DISCARDED'"
           )
  end

  def down do
    drop index(:tbl_movement, [:wagon_id, :station_code],
           name: :unique_station_wagon,
           where: "status !='DISCARDED'"
         )

    drop index(:tbl_movement, [:wagon_id, :train_list_no],
           name: :unique_train_list_wagon,
           where: "status !='DISCARDED'"
         )

    drop index(:tbl_movement, [:wagon_id, :train_no],
           name: :unique_train_no_wagon,
           where: "status !='DISCARDED'"
         )
  end
end
