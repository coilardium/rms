defmodule Rms.OrderTest do
  use Rms.DataCase

  alias Rms.Order

  describe "tbl_movement" do
    alias Rms.Order.Movement

    @valid_attrs %{
      commodity_id: "some commodity_id",
      consignee: "some consignee",
      consigner: "some consigner",
      consignment_date: "some consignment_date",
      container_no: "some container_no",
      dead_loco: "some dead_loco",
      destin_station_id: "some destin_station_id",
      destination: "some destination",
      loco_id: "some loco_id",
      movement_date: "some movement_date",
      movement_time: "some movement_time",
      netweight: "some netweight",
      orgin_station_id: "some orgin_station_id",
      origin: "some origin",
      payer_id: "some payer_id",
      reporting_station: "some reporting_station",
      sales_order: "some sales_order",
      station_code: "some station_code",
      train_no: "some train_no",
      wagon_id: "some wagon_id"
    }
    @update_attrs %{
      commodity_id: "some updated commodity_id",
      consignee: "some updated consignee",
      consigner: "some updated consigner",
      consignment_date: "some updated consignment_date",
      container_no: "some updated container_no",
      dead_loco: "some updated dead_loco",
      destin_station_id: "some updated destin_station_id",
      destination: "some updated destination",
      loco_id: "some updated loco_id",
      movement_date: "some updated movement_date",
      movement_time: "some updated movement_time",
      netweight: "some updated netweight",
      orgin_station_id: "some updated orgin_station_id",
      origin: "some updated origin",
      payer_id: "some updated payer_id",
      reporting_station: "some updated reporting_station",
      sales_order: "some updated sales_order",
      station_code: "some updated station_code",
      train_no: "some updated train_no",
      wagon_id: "some updated wagon_id"
    }
    @invalid_attrs %{
      commodity_id: nil,
      consignee: nil,
      consigner: nil,
      consignment_date: nil,
      container_no: nil,
      dead_loco: nil,
      destin_station_id: nil,
      destination: nil,
      loco_id: nil,
      movement_date: nil,
      movement_time: nil,
      netweight: nil,
      orgin_station_id: nil,
      origin: nil,
      payer_id: nil,
      reporting_station: nil,
      sales_order: nil,
      station_code: nil,
      train_no: nil,
      wagon_id: nil
    }

    def movement_fixture(attrs \\ %{}) do
      {:ok, movement} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Order.create_movement()

      movement
    end

    test "list_tbl_movement/0 returns all tbl_movement" do
      movement = movement_fixture()
      assert Order.list_tbl_movement() == [movement]
    end

    test "get_movement!/1 returns the movement with given id" do
      movement = movement_fixture()
      assert Order.get_movement!(movement.id) == movement
    end

    test "create_movement/1 with valid data creates a movement" do
      assert {:ok, %Movement{} = movement} = Order.create_movement(@valid_attrs)
      assert movement.commodity_id == "some commodity_id"
      assert movement.consignee == "some consignee"
      assert movement.consigner == "some consigner"
      assert movement.consignment_date == "some consignment_date"
      assert movement.container_no == "some container_no"
      assert movement.dead_loco == "some dead_loco"
      assert movement.destin_station_id == "some destin_station_id"
      assert movement.destination == "some destination"
      assert movement.loco_id == "some loco_id"
      assert movement.movement_date == "some movement_date"
      assert movement.movement_time == "some movement_time"
      assert movement.netweight == "some netweight"
      assert movement.orgin_station_id == "some orgin_station_id"
      assert movement.origin == "some origin"
      assert movement.payer_id == "some payer_id"
      assert movement.reporting_station == "some reporting_station"
      assert movement.sales_order == "some sales_order"
      assert movement.station_code == "some station_code"
      assert movement.train_no == "some train_no"
      assert movement.wagon_id == "some wagon_id"
    end

    test "create_movement/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Order.create_movement(@invalid_attrs)
    end

    test "update_movement/2 with valid data updates the movement" do
      movement = movement_fixture()
      assert {:ok, %Movement{} = movement} = Order.update_movement(movement, @update_attrs)
      assert movement.commodity_id == "some updated commodity_id"
      assert movement.consignee == "some updated consignee"
      assert movement.consigner == "some updated consigner"
      assert movement.consignment_date == "some updated consignment_date"
      assert movement.container_no == "some updated container_no"
      assert movement.dead_loco == "some updated dead_loco"
      assert movement.destin_station_id == "some updated destin_station_id"
      assert movement.destination == "some updated destination"
      assert movement.loco_id == "some updated loco_id"
      assert movement.movement_date == "some updated movement_date"
      assert movement.movement_time == "some updated movement_time"
      assert movement.netweight == "some updated netweight"
      assert movement.orgin_station_id == "some updated orgin_station_id"
      assert movement.origin == "some updated origin"
      assert movement.payer_id == "some updated payer_id"
      assert movement.reporting_station == "some updated reporting_station"
      assert movement.sales_order == "some updated sales_order"
      assert movement.station_code == "some updated station_code"
      assert movement.train_no == "some updated train_no"
      assert movement.wagon_id == "some updated wagon_id"
    end

    test "update_movement/2 with invalid data returns error changeset" do
      movement = movement_fixture()
      assert {:error, %Ecto.Changeset{}} = Order.update_movement(movement, @invalid_attrs)
      assert movement == Order.get_movement!(movement.id)
    end

    test "delete_movement/1 deletes the movement" do
      movement = movement_fixture()
      assert {:ok, %Movement{}} = Order.delete_movement(movement)
      assert_raise Ecto.NoResultsError, fn -> Order.get_movement!(movement.id) end
    end

    test "change_movement/1 returns a movement changeset" do
      movement = movement_fixture()
      assert %Ecto.Changeset{} = Order.change_movement(movement)
    end
  end

  describe "tbl_batch" do
    alias Rms.Order.Batch

    @valid_attrs %{
      batch_no: "some batch_no",
      batch_type: "some batch_type",
      status: "some status",
      trans_date: "some trans_date",
      uuid: "some uuid"
    }
    @update_attrs %{
      batch_no: "some updated batch_no",
      batch_type: "some updated batch_type",
      status: "some updated status",
      trans_date: "some updated trans_date",
      uuid: "some updated uuid"
    }
    @invalid_attrs %{batch_no: nil, batch_type: nil, status: nil, trans_date: nil, uuid: nil}

    def batch_fixture(attrs \\ %{}) do
      {:ok, batch} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Order.create_batch()

      batch
    end

    test "list_tbl_batch/0 returns all tbl_batch" do
      batch = batch_fixture()
      assert Order.list_tbl_batch() == [batch]
    end

    test "get_batch!/1 returns the batch with given id" do
      batch = batch_fixture()
      assert Order.get_batch!(batch.id) == batch
    end

    test "create_batch/1 with valid data creates a batch" do
      assert {:ok, %Batch{} = batch} = Order.create_batch(@valid_attrs)
      assert batch.batch_no == "some batch_no"
      assert batch.batch_type == "some batch_type"
      assert batch.status == "some status"
      assert batch.trans_date == "some trans_date"
      assert batch.uuid == "some uuid"
    end

    test "create_batch/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Order.create_batch(@invalid_attrs)
    end

    test "update_batch/2 with valid data updates the batch" do
      batch = batch_fixture()
      assert {:ok, %Batch{} = batch} = Order.update_batch(batch, @update_attrs)
      assert batch.batch_no == "some updated batch_no"
      assert batch.batch_type == "some updated batch_type"
      assert batch.status == "some updated status"
      assert batch.trans_date == "some updated trans_date"
      assert batch.uuid == "some updated uuid"
    end

    test "update_batch/2 with invalid data returns error changeset" do
      batch = batch_fixture()
      assert {:error, %Ecto.Changeset{}} = Order.update_batch(batch, @invalid_attrs)
      assert batch == Order.get_batch!(batch.id)
    end

    test "delete_batch/1 deletes the batch" do
      batch = batch_fixture()
      assert {:ok, %Batch{}} = Order.delete_batch(batch)
      assert_raise Ecto.NoResultsError, fn -> Order.get_batch!(batch.id) end
    end

    test "change_batch/1 returns a batch changeset" do
      batch = batch_fixture()
      assert %Ecto.Changeset{} = Order.change_batch(batch)
    end
  end

  describe "tbl_works_order_master" do
    alias Rms.Order.WorksOrders

    @valid_attrs %{area_name: "some area_name", comment: "some comment", date_on_label: ~D[2010-04-17], departure_date: ~D[2010-04-17], departure_time: "some departure_time", driver_name: "some driver_name", load_date: ~D[2010-04-17], off_loading_date: ~D[2010-04-17], order_no: "some order_no", placed: "some placed", supplied: "some supplied", time_arrival: "some time_arrival", time_out: "some time_out", train_no: "some train_no", yard_foreman: "some yard_foreman"}
    @update_attrs %{area_name: "some updated area_name", comment: "some updated comment", date_on_label: ~D[2011-05-18], departure_date: ~D[2011-05-18], departure_time: "some updated departure_time", driver_name: "some updated driver_name", load_date: ~D[2011-05-18], off_loading_date: ~D[2011-05-18], order_no: "some updated order_no", placed: "some updated placed", supplied: "some updated supplied", time_arrival: "some updated time_arrival", time_out: "some updated time_out", train_no: "some updated train_no", yard_foreman: "some updated yard_foreman"}
    @invalid_attrs %{area_name: nil, comment: nil, date_on_label: nil, departure_date: nil, departure_time: nil, driver_name: nil, load_date: nil, off_loading_date: nil, order_no: nil, placed: nil, supplied: nil, time_arrival: nil, time_out: nil, train_no: nil, yard_foreman: nil}

    def works_orders_fixture(attrs \\ %{}) do
      {:ok, works_orders} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Order.create_works_orders()

      works_orders
    end

    test "list_tbl_works_order_master/0 returns all tbl_works_order_master" do
      works_orders = works_orders_fixture()
      assert Order.list_tbl_works_order_master() == [works_orders]
    end

    test "get_works_orders!/1 returns the works_orders with given id" do
      works_orders = works_orders_fixture()
      assert Order.get_works_orders!(works_orders.id) == works_orders
    end

    test "create_works_orders/1 with valid data creates a works_orders" do
      assert {:ok, %WorksOrders{} = works_orders} = Order.create_works_orders(@valid_attrs)
      assert works_orders.area_name == "some area_name"
      assert works_orders.comment == "some comment"
      assert works_orders.date_on_label == ~D[2010-04-17]
      assert works_orders.departure_date == ~D[2010-04-17]
      assert works_orders.departure_time == "some departure_time"
      assert works_orders.driver_name == "some driver_name"
      assert works_orders.load_date == ~D[2010-04-17]
      assert works_orders.off_loading_date == ~D[2010-04-17]
      assert works_orders.order_no == "some order_no"
      assert works_orders.placed == "some placed"
      assert works_orders.supplied == "some supplied"
      assert works_orders.time_arrival == "some time_arrival"
      assert works_orders.time_out == "some time_out"
      assert works_orders.train_no == "some train_no"
      assert works_orders.yard_foreman == "some yard_foreman"
    end

    test "create_works_orders/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Order.create_works_orders(@invalid_attrs)
    end

    test "update_works_orders/2 with valid data updates the works_orders" do
      works_orders = works_orders_fixture()
      assert {:ok, %WorksOrders{} = works_orders} = Order.update_works_orders(works_orders, @update_attrs)
      assert works_orders.area_name == "some updated area_name"
      assert works_orders.comment == "some updated comment"
      assert works_orders.date_on_label == ~D[2011-05-18]
      assert works_orders.departure_date == ~D[2011-05-18]
      assert works_orders.departure_time == "some updated departure_time"
      assert works_orders.driver_name == "some updated driver_name"
      assert works_orders.load_date == ~D[2011-05-18]
      assert works_orders.off_loading_date == ~D[2011-05-18]
      assert works_orders.order_no == "some updated order_no"
      assert works_orders.placed == "some updated placed"
      assert works_orders.supplied == "some updated supplied"
      assert works_orders.time_arrival == "some updated time_arrival"
      assert works_orders.time_out == "some updated time_out"
      assert works_orders.train_no == "some updated train_no"
      assert works_orders.yard_foreman == "some updated yard_foreman"
    end

    test "update_works_orders/2 with invalid data returns error changeset" do
      works_orders = works_orders_fixture()
      assert {:error, %Ecto.Changeset{}} = Order.update_works_orders(works_orders, @invalid_attrs)
      assert works_orders == Order.get_works_orders!(works_orders.id)
    end

    test "delete_works_orders/1 deletes the works_orders" do
      works_orders = works_orders_fixture()
      assert {:ok, %WorksOrders{}} = Order.delete_works_orders(works_orders)
      assert_raise Ecto.NoResultsError, fn -> Order.get_works_orders!(works_orders.id) end
    end

    test "change_works_orders/1 returns a works_orders changeset" do
      works_orders = works_orders_fixture()
      assert %Ecto.Changeset{} = Order.change_works_orders(works_orders)
    end
  end
end
