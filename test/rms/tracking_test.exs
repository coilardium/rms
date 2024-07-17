defmodule Rms.TrackingTest do
  use Rms.DataCase

  alias Rms.Tracking

  describe "tbl_wagon_tracking" do
    alias Rms.Tracking.WagonTracking

    @valid_attrs %{
      allocated_to_customer: "some allocated_to_customer",
      arrival: "some arrival",
      bound: "some bound",
      comment: "some comment",
      departure: "some departure",
      hire: "some hire",
      net_ton: "120.5",
      sub_category: "some sub_category",
      train_no: "some train_no",
      update_date: ~D[2010-04-17],
      yard_siding: "some yard_siding"
    }
    @update_attrs %{
      allocated_to_customer: "some updated allocated_to_customer",
      arrival: "some updated arrival",
      bound: "some updated bound",
      comment: "some updated comment",
      departure: "some updated departure",
      hire: "some updated hire",
      net_ton: "456.7",
      sub_category: "some updated sub_category",
      train_no: "some updated train_no",
      update_date: ~D[2011-05-18],
      yard_siding: "some updated yard_siding"
    }
    @invalid_attrs %{
      allocated_to_customer: nil,
      arrival: nil,
      bound: nil,
      comment: nil,
      departure: nil,
      hire: nil,
      net_ton: nil,
      sub_category: nil,
      train_no: nil,
      update_date: nil,
      yard_siding: nil
    }

    def wagon_tracking_fixture(attrs \\ %{}) do
      {:ok, wagon_tracking} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Tracking.create_wagon_tracking()

      wagon_tracking
    end

    test "list_tbl_wagon_tracking/0 returns all tbl_wagon_tracking" do
      wagon_tracking = wagon_tracking_fixture()
      assert Tracking.list_tbl_wagon_tracking() == [wagon_tracking]
    end

    test "get_wagon_tracking!/1 returns the wagon_tracking with given id" do
      wagon_tracking = wagon_tracking_fixture()
      assert Tracking.get_wagon_tracking!(wagon_tracking.id) == wagon_tracking
    end

    test "create_wagon_tracking/1 with valid data creates a wagon_tracking" do
      assert {:ok, %WagonTracking{} = wagon_tracking} =
               Tracking.create_wagon_tracking(@valid_attrs)

      assert wagon_tracking.allocated_to_customer == "some allocated_to_customer"
      assert wagon_tracking.arrival == "some arrival"
      assert wagon_tracking.bound == "some bound"
      assert wagon_tracking.comment == "some comment"
      assert wagon_tracking.departure == "some departure"
      assert wagon_tracking.hire == "some hire"
      assert wagon_tracking.net_ton == Decimal.new("120.5")
      assert wagon_tracking.sub_category == "some sub_category"
      assert wagon_tracking.train_no == "some train_no"
      assert wagon_tracking.update_date == ~D[2010-04-17]
      assert wagon_tracking.yard_siding == "some yard_siding"
    end

    test "create_wagon_tracking/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Tracking.create_wagon_tracking(@invalid_attrs)
    end

    test "update_wagon_tracking/2 with valid data updates the wagon_tracking" do
      wagon_tracking = wagon_tracking_fixture()

      assert {:ok, %WagonTracking{} = wagon_tracking} =
               Tracking.update_wagon_tracking(wagon_tracking, @update_attrs)

      assert wagon_tracking.allocated_to_customer == "some updated allocated_to_customer"
      assert wagon_tracking.arrival == "some updated arrival"
      assert wagon_tracking.bound == "some updated bound"
      assert wagon_tracking.comment == "some updated comment"
      assert wagon_tracking.departure == "some updated departure"
      assert wagon_tracking.hire == "some updated hire"
      assert wagon_tracking.net_ton == Decimal.new("456.7")
      assert wagon_tracking.sub_category == "some updated sub_category"
      assert wagon_tracking.train_no == "some updated train_no"
      assert wagon_tracking.update_date == ~D[2011-05-18]
      assert wagon_tracking.yard_siding == "some updated yard_siding"
    end

    test "update_wagon_tracking/2 with invalid data returns error changeset" do
      wagon_tracking = wagon_tracking_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Tracking.update_wagon_tracking(wagon_tracking, @invalid_attrs)

      assert wagon_tracking == Tracking.get_wagon_tracking!(wagon_tracking.id)
    end

    test "delete_wagon_tracking/1 deletes the wagon_tracking" do
      wagon_tracking = wagon_tracking_fixture()
      assert {:ok, %WagonTracking{}} = Tracking.delete_wagon_tracking(wagon_tracking)
      assert_raise Ecto.NoResultsError, fn -> Tracking.get_wagon_tracking!(wagon_tracking.id) end
    end

    test "change_wagon_tracking/1 returns a wagon_tracking changeset" do
      wagon_tracking = wagon_tracking_fixture()
      assert %Ecto.Changeset{} = Tracking.change_wagon_tracking(wagon_tracking)
    end
  end

  describe "tbl_interchange" do
    alias Rms.Tracking.Interchange

    @valid_attrs %{
      accumulative_ammount: "120.5",
      accumulative_days: "some accumulative_days",
      comment: "some comment",
      direction: "some direction",
      entry_date: ~D[2010-04-17],
      exit_date: ~D[2010-04-17],
      interchange_fee: "120.5"
    }
    @update_attrs %{
      accumulative_ammount: "456.7",
      accumulative_days: "some updated accumulative_days",
      comment: "some updated comment",
      direction: "some updated direction",
      entry_date: ~D[2011-05-18],
      exit_date: ~D[2011-05-18],
      interchange_fee: "456.7"
    }
    @invalid_attrs %{
      accumulative_ammount: nil,
      accumulative_days: nil,
      comment: nil,
      direction: nil,
      entry_date: nil,
      exit_date: nil,
      interchange_fee: nil
    }

    def interchange_fixture(attrs \\ %{}) do
      {:ok, interchange} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Tracking.create_interchange()

      interchange
    end

    test "list_tbl_interchange/0 returns all tbl_interchange" do
      interchange = interchange_fixture()
      assert Tracking.list_tbl_interchange() == [interchange]
    end

    test "get_interchange!/1 returns the interchange with given id" do
      interchange = interchange_fixture()
      assert Tracking.get_interchange!(interchange.id) == interchange
    end

    test "create_interchange/1 with valid data creates a interchange" do
      assert {:ok, %Interchange{} = interchange} = Tracking.create_interchange(@valid_attrs)
      assert interchange.accumulative_ammount == Decimal.new("120.5")
      assert interchange.accumulative_days == "some accumulative_days"
      assert interchange.comment == "some comment"
      assert interchange.direction == "some direction"
      assert interchange.entry_date == ~D[2010-04-17]
      assert interchange.exit_date == ~D[2010-04-17]
      assert interchange.interchange_fee == Decimal.new("120.5")
    end

    test "create_interchange/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Tracking.create_interchange(@invalid_attrs)
    end

    test "update_interchange/2 with valid data updates the interchange" do
      interchange = interchange_fixture()

      assert {:ok, %Interchange{} = interchange} =
               Tracking.update_interchange(interchange, @update_attrs)

      assert interchange.accumulative_ammount == Decimal.new("456.7")
      assert interchange.accumulative_days == "some updated accumulative_days"
      assert interchange.comment == "some updated comment"
      assert interchange.direction == "some updated direction"
      assert interchange.entry_date == ~D[2011-05-18]
      assert interchange.exit_date == ~D[2011-05-18]
      assert interchange.interchange_fee == Decimal.new("456.7")
    end

    test "update_interchange/2 with invalid data returns error changeset" do
      interchange = interchange_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Tracking.update_interchange(interchange, @invalid_attrs)

      assert interchange == Tracking.get_interchange!(interchange.id)
    end

    test "delete_interchange/1 deletes the interchange" do
      interchange = interchange_fixture()
      assert {:ok, %Interchange{}} = Tracking.delete_interchange(interchange)
      assert_raise Ecto.NoResultsError, fn -> Tracking.get_interchange!(interchange.id) end
    end

    test "change_interchange/1 returns a interchange changeset" do
      interchange = interchange_fixture()
      assert %Ecto.Changeset{} = Tracking.change_interchange(interchange)
    end
  end

  describe "tbl_interchange_defects" do
    alias Rms.Tracking.InterchangeDefect

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def interchange_defect_fixture(attrs \\ %{}) do
      {:ok, interchange_defect} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Tracking.create_interchange_defect()

      interchange_defect
    end

    test "list_tbl_interchange_defects/0 returns all tbl_interchange_defects" do
      interchange_defect = interchange_defect_fixture()
      assert Tracking.list_tbl_interchange_defects() == [interchange_defect]
    end

    test "get_interchange_defect!/1 returns the interchange_defect with given id" do
      interchange_defect = interchange_defect_fixture()
      assert Tracking.get_interchange_defect!(interchange_defect.id) == interchange_defect
    end

    test "create_interchange_defect/1 with valid data creates a interchange_defect" do
      assert {:ok, %InterchangeDefect{} = interchange_defect} =
               Tracking.create_interchange_defect(@valid_attrs)
    end

    test "create_interchange_defect/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Tracking.create_interchange_defect(@invalid_attrs)
    end

    test "update_interchange_defect/2 with valid data updates the interchange_defect" do
      interchange_defect = interchange_defect_fixture()

      assert {:ok, %InterchangeDefect{} = interchange_defect} =
               Tracking.update_interchange_defect(interchange_defect, @update_attrs)
    end

    test "update_interchange_defect/2 with invalid data returns error changeset" do
      interchange_defect = interchange_defect_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Tracking.update_interchange_defect(interchange_defect, @invalid_attrs)

      assert interchange_defect == Tracking.get_interchange_defect!(interchange_defect.id)
    end

    test "delete_interchange_defect/1 deletes the interchange_defect" do
      interchange_defect = interchange_defect_fixture()
      assert {:ok, %InterchangeDefect{}} = Tracking.delete_interchange_defect(interchange_defect)

      assert_raise Ecto.NoResultsError, fn ->
        Tracking.get_interchange_defect!(interchange_defect.id)
      end
    end

    test "change_interchange_defect/1 returns a interchange_defect changeset" do
      interchange_defect = interchange_defect_fixture()
      assert %Ecto.Changeset{} = Tracking.change_interchange_defect(interchange_defect)
    end
  end

  describe "tbl_wagon_status_daily_log" do
    alias Rms.Tracking.WagonLog

    @valid_attrs %{
      commulative_loaded: "120.5",
      count_active: "120.5",
      curr_loaded: "120.5",
      date: "some date",
      non_act_count: "120.5",
      total_wagons: "120.5"
    }
    @update_attrs %{
      commulative_loaded: "456.7",
      count_active: "456.7",
      curr_loaded: "456.7",
      date: "some updated date",
      non_act_count: "456.7",
      total_wagons: "456.7"
    }
    @invalid_attrs %{
      commulative_loaded: nil,
      count_active: nil,
      curr_loaded: nil,
      date: nil,
      non_act_count: nil,
      total_wagons: nil
    }

    def wagon_log_fixture(attrs \\ %{}) do
      {:ok, wagon_log} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Tracking.create_wagon_log()

      wagon_log
    end

    test "list_tbl_wagon_status_daily_log/0 returns all tbl_wagon_status_daily_log" do
      wagon_log = wagon_log_fixture()
      assert Tracking.list_tbl_wagon_status_daily_log() == [wagon_log]
    end

    test "get_wagon_log!/1 returns the wagon_log with given id" do
      wagon_log = wagon_log_fixture()
      assert Tracking.get_wagon_log!(wagon_log.id) == wagon_log
    end

    test "create_wagon_log/1 with valid data creates a wagon_log" do
      assert {:ok, %WagonLog{} = wagon_log} = Tracking.create_wagon_log(@valid_attrs)
      assert wagon_log.commulative_loaded == Decimal.new("120.5")
      assert wagon_log.count_active == Decimal.new("120.5")
      assert wagon_log.curr_loaded == Decimal.new("120.5")
      assert wagon_log.date == "some date"
      assert wagon_log.non_act_count == Decimal.new("120.5")
      assert wagon_log.total_wagons == Decimal.new("120.5")
    end

    test "create_wagon_log/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Tracking.create_wagon_log(@invalid_attrs)
    end

    test "update_wagon_log/2 with valid data updates the wagon_log" do
      wagon_log = wagon_log_fixture()
      assert {:ok, %WagonLog{} = wagon_log} = Tracking.update_wagon_log(wagon_log, @update_attrs)
      assert wagon_log.commulative_loaded == Decimal.new("456.7")
      assert wagon_log.count_active == Decimal.new("456.7")
      assert wagon_log.curr_loaded == Decimal.new("456.7")
      assert wagon_log.date == "some updated date"
      assert wagon_log.non_act_count == Decimal.new("456.7")
      assert wagon_log.total_wagons == Decimal.new("456.7")
    end

    test "update_wagon_log/2 with invalid data returns error changeset" do
      wagon_log = wagon_log_fixture()
      assert {:error, %Ecto.Changeset{}} = Tracking.update_wagon_log(wagon_log, @invalid_attrs)
      assert wagon_log == Tracking.get_wagon_log!(wagon_log.id)
    end

    test "delete_wagon_log/1 deletes the wagon_log" do
      wagon_log = wagon_log_fixture()
      assert {:ok, %WagonLog{}} = Tracking.delete_wagon_log(wagon_log)
      assert_raise Ecto.NoResultsError, fn -> Tracking.get_wagon_log!(wagon_log.id) end
    end

    test "change_wagon_log/1 returns a wagon_log changeset" do
      wagon_log = wagon_log_fixture()
      assert %Ecto.Changeset{} = Tracking.change_wagon_log(wagon_log)
    end
  end

  describe "tbl_interchange_material" do
    alias Rms.Tracking.Material

    @valid_attrs %{
      date_received: ~D[2010-04-17],
      date_sent: ~D[2010-04-17],
      direction: "some direction",
      status: "some status"
    }
    @update_attrs %{
      date_received: ~D[2011-05-18],
      date_sent: ~D[2011-05-18],
      direction: "some updated direction",
      status: "some updated status"
    }
    @invalid_attrs %{date_received: nil, date_sent: nil, direction: nil, status: nil}

    def material_fixture(attrs \\ %{}) do
      {:ok, material} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Tracking.create_material()

      material
    end

    test "list_tbl_interchange_material/0 returns all tbl_interchange_material" do
      material = material_fixture()
      assert Tracking.list_tbl_interchange_material() == [material]
    end

    test "get_material!/1 returns the material with given id" do
      material = material_fixture()
      assert Tracking.get_material!(material.id) == material
    end

    test "create_material/1 with valid data creates a material" do
      assert {:ok, %Material{} = material} = Tracking.create_material(@valid_attrs)
      assert material.date_received == ~D[2010-04-17]
      assert material.date_sent == ~D[2010-04-17]
      assert material.direction == "some direction"
      assert material.status == "some status"
    end

    test "create_material/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Tracking.create_material(@invalid_attrs)
    end

    test "update_material/2 with valid data updates the material" do
      material = material_fixture()
      assert {:ok, %Material{} = material} = Tracking.update_material(material, @update_attrs)
      assert material.date_received == ~D[2011-05-18]
      assert material.date_sent == ~D[2011-05-18]
      assert material.direction == "some updated direction"
      assert material.status == "some updated status"
    end

    test "update_material/2 with invalid data returns error changeset" do
      material = material_fixture()
      assert {:error, %Ecto.Changeset{}} = Tracking.update_material(material, @invalid_attrs)
      assert material == Tracking.get_material!(material.id)
    end

    test "delete_material/1 deletes the material" do
      material = material_fixture()
      assert {:ok, %Material{}} = Tracking.delete_material(material)
      assert_raise Ecto.NoResultsError, fn -> Tracking.get_material!(material.id) end
    end

    test "change_material/1 returns a material changeset" do
      material = material_fixture()
      assert %Ecto.Changeset{} = Tracking.change_material(material)
    end
  end

  describe "tbl_interchange_auxiliary" do
    alias Rms.Tracking.Auxiliary

    @valid_attrs %{
      accumlative_days: 42,
      amount: "120.5",
      dirction: "some dirction",
      off_hire_date: ~D[2010-04-17],
      received_date: ~D[2010-04-17],
      sent_date: ~D[2010-04-17],
      status: "some status"
    }
    @update_attrs %{
      accumlative_days: 43,
      amount: "456.7",
      dirction: "some updated dirction",
      off_hire_date: ~D[2011-05-18],
      received_date: ~D[2011-05-18],
      sent_date: ~D[2011-05-18],
      status: "some updated status"
    }
    @invalid_attrs %{
      accumlative_days: nil,
      amount: nil,
      dirction: nil,
      off_hire_date: nil,
      received_date: nil,
      sent_date: nil,
      status: nil
    }

    def auxiliary_fixture(attrs \\ %{}) do
      {:ok, auxiliary} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Tracking.create_auxiliary()

      auxiliary
    end

    test "list_tbl_interchange_auxiliary/0 returns all tbl_interchange_auxiliary" do
      auxiliary = auxiliary_fixture()
      assert Tracking.list_tbl_interchange_auxiliary() == [auxiliary]
    end

    test "get_auxiliary!/1 returns the auxiliary with given id" do
      auxiliary = auxiliary_fixture()
      assert Tracking.get_auxiliary!(auxiliary.id) == auxiliary
    end

    test "create_auxiliary/1 with valid data creates a auxiliary" do
      assert {:ok, %Auxiliary{} = auxiliary} = Tracking.create_auxiliary(@valid_attrs)
      assert auxiliary.accumlative_days == 42
      assert auxiliary.amount == Decimal.new("120.5")
      assert auxiliary.dirction == "some dirction"
      assert auxiliary.off_hire_date == ~D[2010-04-17]
      assert auxiliary.received_date == ~D[2010-04-17]
      assert auxiliary.sent_date == ~D[2010-04-17]
      assert auxiliary.status == "some status"
    end

    test "create_auxiliary/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Tracking.create_auxiliary(@invalid_attrs)
    end

    test "update_auxiliary/2 with valid data updates the auxiliary" do
      auxiliary = auxiliary_fixture()
      assert {:ok, %Auxiliary{} = auxiliary} = Tracking.update_auxiliary(auxiliary, @update_attrs)
      assert auxiliary.accumlative_days == 43
      assert auxiliary.amount == Decimal.new("456.7")
      assert auxiliary.dirction == "some updated dirction"
      assert auxiliary.off_hire_date == ~D[2011-05-18]
      assert auxiliary.received_date == ~D[2011-05-18]
      assert auxiliary.sent_date == ~D[2011-05-18]
      assert auxiliary.status == "some updated status"
    end

    test "update_auxiliary/2 with invalid data returns error changeset" do
      auxiliary = auxiliary_fixture()
      assert {:error, %Ecto.Changeset{}} = Tracking.update_auxiliary(auxiliary, @invalid_attrs)
      assert auxiliary == Tracking.get_auxiliary!(auxiliary.id)
    end

    test "delete_auxiliary/1 deletes the auxiliary" do
      auxiliary = auxiliary_fixture()
      assert {:ok, %Auxiliary{}} = Tracking.delete_auxiliary(auxiliary)
      assert_raise Ecto.NoResultsError, fn -> Tracking.get_auxiliary!(auxiliary.id) end
    end

    test "change_auxiliary/1 returns a auxiliary changeset" do
      auxiliary = auxiliary_fixture()
      assert %Ecto.Changeset{} = Tracking.change_auxiliary(auxiliary)
    end
  end

  describe "tbl_loco_detention" do
    alias Rms.Tracking.LocoDetention

    @valid_attrs %{
      actual_delay: "120.5",
      amount: "120.5",
      arrival_date: ~D[2010-04-17],
      arrival_time: "some arrival_time",
      chargeable_delay: "120.5",
      comment: "some comment",
      departure_date: ~D[2010-04-17],
      departure_time: "some departure_time",
      direction: "some direction",
      grace_period: "120.5",
      interchange_date: ~D[2010-04-17],
      status: "some status",
      train_no: "some train_no"
    }
    @update_attrs %{
      actual_delay: "456.7",
      amount: "456.7",
      arrival_date: ~D[2011-05-18],
      arrival_time: "some updated arrival_time",
      chargeable_delay: "456.7",
      comment: "some updated comment",
      departure_date: ~D[2011-05-18],
      departure_time: "some updated departure_time",
      direction: "some updated direction",
      grace_period: "456.7",
      interchange_date: ~D[2011-05-18],
      status: "some updated status",
      train_no: "some updated train_no"
    }
    @invalid_attrs %{
      actual_delay: nil,
      amount: nil,
      arrival_date: nil,
      arrival_time: nil,
      chargeable_delay: nil,
      comment: nil,
      departure_date: nil,
      departure_time: nil,
      direction: nil,
      grace_period: nil,
      interchange_date: nil,
      status: nil,
      train_no: nil
    }

    def loco_detention_fixture(attrs \\ %{}) do
      {:ok, loco_detention} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Tracking.create_loco_detention()

      loco_detention
    end

    test "list_tbl_loco_detention/0 returns all tbl_loco_detention" do
      loco_detention = loco_detention_fixture()
      assert Tracking.list_tbl_loco_detention() == [loco_detention]
    end

    test "get_loco_detention!/1 returns the loco_detention with given id" do
      loco_detention = loco_detention_fixture()
      assert Tracking.get_loco_detention!(loco_detention.id) == loco_detention
    end

    test "create_loco_detention/1 with valid data creates a loco_detention" do
      assert {:ok, %LocoDetention{} = loco_detention} =
               Tracking.create_loco_detention(@valid_attrs)

      assert loco_detention.actual_delay == Decimal.new("120.5")
      assert loco_detention.amount == Decimal.new("120.5")
      assert loco_detention.arrival_date == ~D[2010-04-17]
      assert loco_detention.arrival_time == "some arrival_time"
      assert loco_detention.chargeable_delay == Decimal.new("120.5")
      assert loco_detention.comment == "some comment"
      assert loco_detention.departure_date == ~D[2010-04-17]
      assert loco_detention.departure_time == "some departure_time"
      assert loco_detention.direction == "some direction"
      assert loco_detention.grace_period == Decimal.new("120.5")
      assert loco_detention.interchange_date == ~D[2010-04-17]
      assert loco_detention.status == "some status"
      assert loco_detention.train_no == "some train_no"
    end

    test "create_loco_detention/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Tracking.create_loco_detention(@invalid_attrs)
    end

    test "update_loco_detention/2 with valid data updates the loco_detention" do
      loco_detention = loco_detention_fixture()

      assert {:ok, %LocoDetention{} = loco_detention} =
               Tracking.update_loco_detention(loco_detention, @update_attrs)

      assert loco_detention.actual_delay == Decimal.new("456.7")
      assert loco_detention.amount == Decimal.new("456.7")
      assert loco_detention.arrival_date == ~D[2011-05-18]
      assert loco_detention.arrival_time == "some updated arrival_time"
      assert loco_detention.chargeable_delay == Decimal.new("456.7")
      assert loco_detention.comment == "some updated comment"
      assert loco_detention.departure_date == ~D[2011-05-18]
      assert loco_detention.departure_time == "some updated departure_time"
      assert loco_detention.direction == "some updated direction"
      assert loco_detention.grace_period == Decimal.new("456.7")
      assert loco_detention.interchange_date == ~D[2011-05-18]
      assert loco_detention.status == "some updated status"
      assert loco_detention.train_no == "some updated train_no"
    end

    test "update_loco_detention/2 with invalid data returns error changeset" do
      loco_detention = loco_detention_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Tracking.update_loco_detention(loco_detention, @invalid_attrs)

      assert loco_detention == Tracking.get_loco_detention!(loco_detention.id)
    end

    test "delete_loco_detention/1 deletes the loco_detention" do
      loco_detention = loco_detention_fixture()
      assert {:ok, %LocoDetention{}} = Tracking.delete_loco_detention(loco_detention)
      assert_raise Ecto.NoResultsError, fn -> Tracking.get_loco_detention!(loco_detention.id) end
    end

    test "change_loco_detention/1 returns a loco_detention changeset" do
      loco_detention = loco_detention_fixture()
      assert %Ecto.Changeset{} = Tracking.change_loco_detention(loco_detention)
    end
  end

  describe "tbl_haulage" do
    alias Rms.Tracking.Haulage

    @valid_attrs %{
      amount: "120.5",
      date: ~D[2010-04-17],
      loco_no: "some loco_no",
      rate: "120.5",
      total_wagons: 42,
      train_no: "some train_no",
      wagon_grand_total: 42
    }
    @update_attrs %{
      amount: "456.7",
      date: ~D[2011-05-18],
      loco_no: "some updated loco_no",
      rate: "456.7",
      total_wagons: 43,
      train_no: "some updated train_no",
      wagon_grand_total: 43
    }
    @invalid_attrs %{
      amount: nil,
      date: nil,
      loco_no: nil,
      rate: nil,
      total_wagons: nil,
      train_no: nil,
      wagon_grand_total: nil
    }

    def haulage_fixture(attrs \\ %{}) do
      {:ok, haulage} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Tracking.create_haulage()

      haulage
    end

    test "list_tbl_haulage/0 returns all tbl_haulage" do
      haulage = haulage_fixture()
      assert Tracking.list_tbl_haulage() == [haulage]
    end

    test "get_haulage!/1 returns the haulage with given id" do
      haulage = haulage_fixture()
      assert Tracking.get_haulage!(haulage.id) == haulage
    end

    test "create_haulage/1 with valid data creates a haulage" do
      assert {:ok, %Haulage{} = haulage} = Tracking.create_haulage(@valid_attrs)
      assert haulage.amount == Decimal.new("120.5")
      assert haulage.date == ~D[2010-04-17]
      assert haulage.loco_no == "some loco_no"
      assert haulage.rate == Decimal.new("120.5")
      assert haulage.total_wagons == 42
      assert haulage.train_no == "some train_no"
      assert haulage.wagon_grand_total == 42
    end

    test "create_haulage/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Tracking.create_haulage(@invalid_attrs)
    end

    test "update_haulage/2 with valid data updates the haulage" do
      haulage = haulage_fixture()
      assert {:ok, %Haulage{} = haulage} = Tracking.update_haulage(haulage, @update_attrs)
      assert haulage.amount == Decimal.new("456.7")
      assert haulage.date == ~D[2011-05-18]
      assert haulage.loco_no == "some updated loco_no"
      assert haulage.rate == Decimal.new("456.7")
      assert haulage.total_wagons == 43
      assert haulage.train_no == "some updated train_no"
      assert haulage.wagon_grand_total == 43
    end

    test "update_haulage/2 with invalid data returns error changeset" do
      haulage = haulage_fixture()
      assert {:error, %Ecto.Changeset{}} = Tracking.update_haulage(haulage, @invalid_attrs)
      assert haulage == Tracking.get_haulage!(haulage.id)
    end

    test "delete_haulage/1 deletes the haulage" do
      haulage = haulage_fixture()
      assert {:ok, %Haulage{}} = Tracking.delete_haulage(haulage)
      assert_raise Ecto.NoResultsError, fn -> Tracking.get_haulage!(haulage.id) end
    end

    test "change_haulage/1 returns a haulage changeset" do
      haulage = haulage_fixture()
      assert %Ecto.Changeset{} = Tracking.change_haulage(haulage)
    end
  end

  describe "tbl_demurrage_master" do
    alias Rms.Tracking.Demurrage

    @valid_attrs %{
      arrival_dt: ~D[2010-04-17],
      charge: "120.5",
      comment: "some comment",
      date_cleared: ~D[2010-04-17],
      date_loaded: ~D[2010-04-17],
      date_offloaded: ~D[2010-04-17],
      date_placed: ~D[2010-04-17],
      dt_placed_over_weekend: ~D[2010-04-17],
      sidings: 42,
      total: 42,
      yard: 42
    }
    @update_attrs %{
      arrival_dt: ~D[2011-05-18],
      charge: "456.7",
      comment: "some updated comment",
      date_cleared: ~D[2011-05-18],
      date_loaded: ~D[2011-05-18],
      date_offloaded: ~D[2011-05-18],
      date_placed: ~D[2011-05-18],
      dt_placed_over_weekend: ~D[2011-05-18],
      sidings: 43,
      total: 43,
      yard: 43
    }
    @invalid_attrs %{
      arrival_dt: nil,
      charge: nil,
      comment: nil,
      date_cleared: nil,
      date_loaded: nil,
      date_offloaded: nil,
      date_placed: nil,
      dt_placed_over_weekend: nil,
      sidings: nil,
      total: nil,
      yard: nil
    }

    def demurrage_fixture(attrs \\ %{}) do
      {:ok, demurrage} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Tracking.create_demurrage()

      demurrage
    end

    test "list_tbl_demurrage_master/0 returns all tbl_demurrage_master" do
      demurrage = demurrage_fixture()
      assert Tracking.list_tbl_demurrage_master() == [demurrage]
    end

    test "get_demurrage!/1 returns the demurrage with given id" do
      demurrage = demurrage_fixture()
      assert Tracking.get_demurrage!(demurrage.id) == demurrage
    end

    test "create_demurrage/1 with valid data creates a demurrage" do
      assert {:ok, %Demurrage{} = demurrage} = Tracking.create_demurrage(@valid_attrs)
      assert demurrage.arrival_dt == ~D[2010-04-17]
      assert demurrage.charge == Decimal.new("120.5")
      assert demurrage.comment == "some comment"
      assert demurrage.date_cleared == ~D[2010-04-17]
      assert demurrage.date_loaded == ~D[2010-04-17]
      assert demurrage.date_offloaded == ~D[2010-04-17]
      assert demurrage.date_placed == ~D[2010-04-17]
      assert demurrage.dt_placed_over_weekend == ~D[2010-04-17]
      assert demurrage.sidings == 42
      assert demurrage.total == 42
      assert demurrage.yard == 42
    end

    test "create_demurrage/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Tracking.create_demurrage(@invalid_attrs)
    end

    test "update_demurrage/2 with valid data updates the demurrage" do
      demurrage = demurrage_fixture()
      assert {:ok, %Demurrage{} = demurrage} = Tracking.update_demurrage(demurrage, @update_attrs)
      assert demurrage.arrival_dt == ~D[2011-05-18]
      assert demurrage.charge == Decimal.new("456.7")
      assert demurrage.comment == "some updated comment"
      assert demurrage.date_cleared == ~D[2011-05-18]
      assert demurrage.date_loaded == ~D[2011-05-18]
      assert demurrage.date_offloaded == ~D[2011-05-18]
      assert demurrage.date_placed == ~D[2011-05-18]
      assert demurrage.dt_placed_over_weekend == ~D[2011-05-18]
      assert demurrage.sidings == 43
      assert demurrage.total == 43
      assert demurrage.yard == 43
    end

    test "update_demurrage/2 with invalid data returns error changeset" do
      demurrage = demurrage_fixture()
      assert {:error, %Ecto.Changeset{}} = Tracking.update_demurrage(demurrage, @invalid_attrs)
      assert demurrage == Tracking.get_demurrage!(demurrage.id)
    end

    test "delete_demurrage/1 deletes the demurrage" do
      demurrage = demurrage_fixture()
      assert {:ok, %Demurrage{}} = Tracking.delete_demurrage(demurrage)
      assert_raise Ecto.NoResultsError, fn -> Tracking.get_demurrage!(demurrage.id) end
    end

    test "change_demurrage/1 returns a demurrage changeset" do
      demurrage = demurrage_fixture()
      assert %Ecto.Changeset{} = Tracking.change_demurrage(demurrage)
    end
  end
end
