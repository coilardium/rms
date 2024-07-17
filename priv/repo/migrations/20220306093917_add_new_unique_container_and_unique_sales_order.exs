defmodule Rms.Repo.Migrations.AddNewUniqueContainerAndUniqueSalesOrder do
  use Ecto.Migration

  def up do
    create unique_index(:tbl_consignments, [:wagon_id, :sale_order, :customer_id],
             name: :unique_sales_order_wagon,
             where: "status !='DISCARDED' and container_no is null"
           )

    create unique_index(:tbl_consignments, [:wagon_id, :sale_order, :customer_id, :container_no],
             name: :unique_container_no_wagon,
             where: "status !='DISCARDED' and container_no is not null"
           )
  end

  def down do
    drop unique_index(:tbl_consignments, [:wagon_id, :sale_order, :customer_id],
           name: :unique_sales_order_wagon,
           where: "status !='DISCARDED' and container_no is null"
         )

    drop unique_index(:tbl_consignments, [:wagon_id, :sale_order, :customer_id, :container_no],
           name: :unique_container_no_wagon,
           where: "status !='DISCARDED' and container_no is not null"
         )
  end
end
