defmodule Rms.Repo.Migrations.AddUniqueConstraintsToTblConsignment do
  use Ecto.Migration

  def up do
    create unique_index(:tbl_consignments, [:wagon_id, :station_code],
             name: :unique_station_wagon,
             where: "status !='DISCARDED'"
           )

    create unique_index(:tbl_consignments, [:wagon_id, :sale_order],
             name: :unique_sales_order_wagon,
             where: "status !='DISCARDED'"
           )
  end

  def down do
    drop index(:tbl_consignments, [:wagon_id, :station_code],
           name: :unique_station_wagon,
           where: "status !='DISCARDED'"
         )

    drop index(:tbl_consignments, [:wagon_id, :sale_order],
           name: :unique_sales_order_wagon,
           where: "status !='DISCARDED'"
         )
  end
end
