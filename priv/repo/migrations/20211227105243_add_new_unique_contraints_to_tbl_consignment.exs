defmodule Rms.Repo.Migrations.AddNewUniqueContraintsToTblConsignment do
  use Ecto.Migration

  def up do
    drop index(:tbl_consignments, [:wagon_id, :station_code],
           name: :unique_station_wagon,
           where: "status !='DISCARDED'"
         )

    drop index(:tbl_consignments, [:wagon_id, :sale_order],
           name: :unique_sales_order_wagon,
           where: "status !='DISCARDED'"
         )

    create unique_index(:tbl_consignments, [:wagon_id, :station_code],
             name: :unique_station_wagon,
             where: "status !='DISCARDED'and station_code is not null"
           )

    create unique_index(:tbl_consignments, [:wagon_id, :sale_order],
             name: :unique_sales_order_wagon,
             where: "status !='DISCARDED' and sale_order is not null"
           )
  end

  def down do
    drop index(:tbl_consignments, [:wagon_id, :station_code],
           name: :unique_station_wagon,
           where: "status !='DISCARDED'and station_code is not null"
         )

    drop index(:tbl_consignments, [:wagon_id, :sale_order],
           name: :unique_sales_order_wagon,
           where: "status !='DISCARDED' and sale_order is not null"
         )

    create unique_index(:tbl_consignments, [:wagon_id, :station_code],
             name: :unique_station_wagon,
             where: "status !='DISCARDED'"
           )

    create unique_index(:tbl_consignments, [:wagon_id, :sale_order],
             name: :unique_sales_order_wagon,
             where: "status !='DISCARDED'"
           )
  end
end
