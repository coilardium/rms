defmodule Rms.Repo.Migrations.AddNewUniqueContraintsToTblMovenment do
  use Ecto.Migration

  def up do
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

    create unique_index(:tbl_movement, [:wagon_id, :station_code],
             name: :unique_station_wagon,
             where: "status !='DISCARDED' and station_code is not null"
           )

    create unique_index(:tbl_movement, [:wagon_id, :train_list_no],
             name: :unique_train_list_wagon,
             where: "status !='DISCARDED' and train_list_no is not null"
           )

    create unique_index(:tbl_movement, [:wagon_id, :train_no],
             name: :unique_train_no_wagon,
             where: "status !='DISCARDED'and train_no is not null"
           )
  end

  def down do
    drop index(:tbl_movement, [:wagon_id, :station_code],
           name: :unique_station_wagon,
           where: "status !='DISCARDED' and station_code is not null"
         )

    drop index(:tbl_movement, [:wagon_id, :train_list_no],
           name: :unique_train_list_wagon,
           where: "status !='DISCARDED' and train_list_no is not null"
         )

    drop index(:tbl_movement, [:wagon_id, :train_no],
           name: :unique_train_no_wagon,
           where: "status !='DISCARDED'and train_no is not null"
         )

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
end
