defmodule Rms.Repo.Migrations.AddContainerNumberUniqueNumberDropAllUniqueConstraint do
  use Ecto.Migration

  def up do
    drop unique_index(:tbl_consignments, [:wagon_id, :station_code],
           name: :unique_station_wagon,
           where: "status !='DISCARDED'and station_code is not null"
         )

    drop unique_index(:tbl_consignments, [:wagon_id, :sale_order],
           name: :unique_sales_order_wagon,
           where: "status !='DISCARDED' and sale_order is not null"
         )
  end

  def down do
    create index(:tbl_consignments, [:wagon_id, :station_code],
             name: :unique_station_wagon,
             where: "status !='DISCARDED'and station_code is not null"
           )

    create index(:tbl_consignments, [:wagon_id, :sale_order],
             name: :unique_sales_order_wagon,
             where: "status !='DISCARDED' and sale_order is not null"
           )
  end
end
