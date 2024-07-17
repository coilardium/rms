defmodule RmsWeb.InterchangeController do
  use RmsWeb, :controller

  require Logger
  alias Rms.{Repo, Activity.UserLog, Accounts, SystemUtilities, Tracking, Locomotives}

  alias Rms.Tracking.{
    Haulage,
    Demurrage,
    LocoDetention,
    Auxiliary,
    Material,
    InterchangeDefect,
    Interchange
  }

  alias Rms.SystemUtilities.{FileUploadError, Commodity, Wagon, Station}

  @headers ~w/wagon_code station_sn commodity_sn train_no/a

  plug(
    RmsWeb.Plugs.RequireAuth
    when action not in [:unknown]
  )

  plug(
    RmsWeb.Plugs.EnforcePasswordPolicy
    when action not in [:unknown]
  )

  plug RmsWeb.Plugs.Authenticate,
       [module_callback: &RmsWeb.InterchangeController.authorize/1]
       when action not in [
        :unknown,
        :interchange_on_hire_batch_entries,
        :train_no_lookup,
        :interchange_report_lookup,
        :auxiliary_lookup,
        :archive_hire_auxiliary,
        :off_hire_auxiliary,
        :archive_loco_detention,
        :loco_item_lookup,
        :interchange_excel_exp,
        :demurrage_lookup
      ]

  @current "tbl_interchange"

  def index(conn, _params) do
    stations =
      SystemUtilities.list_tbl_station()
      |> Enum.reject(&(&1.status != "A"))
      |> Enum.reject(&(&1.interchange_point != "YES"))

    spares = SystemUtilities.list_tbl_spares() |> Enum.reject(&(&1.status != "A"))
    admins = Accounts.list_tbl_railway_administrator() |> Enum.reject(&(&1.status != "A"))
    defects = SystemUtilities.list_tbl_defects("INTL") |> Enum.reject(&(&1.status != "A"))
    condition = SystemUtilities.list_tbl_condition() |> Enum.reject(&(&1.status != "A"))
    wagon_status = SystemUtilities.list_tbl_status() |> Enum.reject(&(&1.rec_status != "A"))

    render(conn, "index.html",
      admins: admins,
      spares: spares,
      stations: stations,
      defects: defects,
      condition: condition,
      wagon_status: wagon_status
    )
  end

  def create(conn, %{"entries" => params, "wagon_status_id" => wagon_status_id}) do
    conn.assigns.user
    |> handle_create(params, wagon_status_id)
    |> Repo.transaction()
    |> case do
      {:ok, _} ->
        json(conn, %{"info" => "sucesss"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        json(conn, %{"error" => "#{reason}"})
    end
  end

  defp handle_create(user, params, wagon_status_id) do
    uuid = Ecto.UUID.generate()

    params
    |> Enum.map(fn {index, item} ->
      check_defects(item, user, index, uuid, wagon_status_id)
    end)
    |> Enum.reduce(Ecto.Multi.new(), &Ecto.Multi.append/2)
  end

  defp check_defects(%{"defects" => _defects} = item, user, index, uuid, wagon_status_id) do
    wag = Rms.SystemUtilities.get_wagon!(item["wagon_id"])
    current_station = SystemUtilities.get_station!(item["interchange_point"])
    commodity = SystemUtilities.get_commodity!(item["commodity_id"])
    condition_id = item["wagon_condition_id"] || wag.condition_id

    Ecto.Multi.new()
    |> Ecto.Multi.insert(
      {:interchange, index},
      Interchange.changeset(
        %Interchange{
          maker_id: user.id,
          uuid: uuid,
          checker_id: user.id,
          auth_status: "APPROVED"
        },
        Map.merge(item, %{
          "wagon_status_id" => wagon_status_id,
          "current_station_id" => current_station.id,
          "status" => "ON_HIRE",
          "wagon_condition_id" => condition_id,
          "domain_id" => current_station.domain_id,
          "region_id" => current_station.region_id
        })
      )
    )
    |> Ecto.Multi.update(
      {:update_wagon, index},
      Wagon.changeset(wag, %{
        mvt_status: "A",
        station_id: current_station,
        wagon_status_id: wagon_status_id,
        domain_id: current_station.domain_id,
        load_status: commodity.load_status,
        commodity_id: commodity.id,
        condition_id: condition_id
      })
    )
    |> handle_defects(item, index)
    |> Ecto.Multi.insert(
      {:user_log, index},
      UserLog.changeset(%UserLog{}, %{
        user_id: user.id,
        activity:
          "created Interchange with wagon_id \"#{item["wagon_id"]}\" and train numner  \"#{item["train_no"]}\""
      })
    )
  end

  defp check_defects(item, user, index, uuid, wagon_status_id) do
    wag = Rms.SystemUtilities.get_wagon!(item["wagon_id"])
    current_station = SystemUtilities.get_station!(item["interchange_point"])
    commodity = SystemUtilities.get_commodity!(item["commodity_id"])
    condition_id = item["wagon_condition_id"] || wag.condition_id

    Ecto.Multi.new()
    |> Ecto.Multi.insert(
      {:interchange, index},
      Interchange.changeset(
        %Interchange{
          maker_id: user.id,
          uuid: uuid,
          checker_id: user.id,
          auth_status: "APPROVED"
        },
        Map.merge(item, %{
          "wagon_status_id" => wagon_status_id,
          "current_station_id" => current_station.id,
          "status" => "ON_HIRE",
          "domain_id" => current_station.domain_id,
          "region_id" => current_station.region_id,
          "wagon_condition_id" => condition_id
        })
      )
    )
    |> Ecto.Multi.update(
      {:update_wagon, index},
      Wagon.changeset(wag, %{
        mvt_status: "A",
        station_id: current_station.id,
        wagon_status_id: wagon_status_id,
        domain_id: current_station.domain_id,
        load_status: commodity.load_status,
        commodity_id: commodity.id,
        condition_id: condition_id
      })
    )
    |> Ecto.Multi.insert(
      {:user_log, index},
      UserLog.changeset(%UserLog{}, %{
        user_id: user.id,
        activity:
          "created Interchange with wagon_id \"#{item["wagon_id"]}\" and train numner  \"#{item["train_no"]}\""
      })
    )
  end

  defp handle_defects(multi, %{"defects" => defects}, item_index) do
    item_key = {:interchange, item_index}

    Ecto.Multi.merge(multi, fn %{^item_key => %{id: interchange_id, wagon_id: wagon_id}} =
                                 _changes ->
      Enum.reduce(defects, Ecto.Multi.new(), fn {index, defect}, multi ->
        params = %{
          interchange_id: interchange_id,
          defect_id: defect["defect_id"],
          wagon_id: wagon_id
        }

        Ecto.Multi.insert(
          multi,
          {:defect, index, item_index},
          InterchangeDefect.changeset(%InterchangeDefect{}, params)
        )
      end)
    end)
  end

  def interchange_approval(conn, _params) do
    interchange = []
    render(conn, "interchange_batch.html", interchange: interchange)
  end

  def interchange_batch_entries(conn, params) do
    interchange =
      Rms.Tracking.interchange_entry_lookup(params["id"], "PENDING_APPROVAL", "OFF_HIRE")

    render(conn, "interchange_approval_entries.html", interchange: interchange)
  end

  def interchange_batch_entries_lookup(conn, params) do
    interchange = Rms.Tracking.get_interchange_batch_by_uuid(params["id"], params["status"])
    json(conn, %{"data" => interchange})
  end

  def interchange_defect_lookup(conn, %{"id" => id, "admin" => admin_id}) do
    defect =
      Rms.SystemUtilities.interchange_defect_spare_lookup(id, admin_id)
      |> Enum.reject(&(&1.amount == nil))

    wagon = Rms.Tracking.interchange_hired_report_list_lookup(id)

    json(conn, %{"data" => defect, "wagon" => wagon})
  end

  def interchange_defect_spare_lookup(conn, %{"id" => id, "admin_id" => admin_id}) do
    defect = Rms.SystemUtilities.interchange_defect_spares_lookup(id, admin_id)
    json(conn, %{"data" => defect})
  end

  def close_interchange(conn, %{"entries" => items}) do
    conn.assigns.user
    |> handle_close_interchange(items)
    |> Repo.transaction()
    |> case do
      {:ok, _} ->
        json(conn, %{"info" => "sucesss"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        json(conn, %{"error" => "#{reason}"})
    end
  end

  defp handle_close_interchange(user, items) do
    items
    |> Enum.map(fn {index, item} ->
      entry = Rms.Tracking.get_interchange!(item["id"])

      Ecto.Multi.new()
      |> Ecto.Multi.update(
        {:interchange, index},
        Interchange.changeset(entry, %{
          "auth_status" => "COMPLETE"
        })
      )
      |> Ecto.Multi.insert(
        {:user_log, index},
        UserLog.changeset(%UserLog{}, %{
          user_id: user.id,
          activity:
            "Closed interchange with wagon_id  \" #{entry.wagon_id}\" and Train number \" #{entry.train_no}\" "
        })
      )
    end)
    |> Enum.reduce(Ecto.Multi.new(), &Ecto.Multi.append/2)
  end

  def set_interchange_batch_off_hire(conn, params) do
    conn.assigns.user
    |> handle_interchange_batch_off_hire(params)
    |> Repo.transaction()
    |> case do
      {:ok, _} ->
        json(conn, %{"info" => "sucesss"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        json(conn, %{"error" => "#{reason}"})
    end
  end

  defp handle_interchange_batch_off_hire(user, params) do
    params["entries"]
    |> Enum.map(fn {index, item} ->
      entry = Rms.Tracking.get_interchange!(item["id"])
      new_entry = Rms.Tracking.interchange_hired_report_list_lookup(item["id"])

      on_hire_dt = params["on_hire_date"]
      on_hire_dt = if(on_hire_dt == "", do: new_entry.on_hire_date, else: on_hire_dt)
      off_hire_dt = params["off_hire_date"]
      off_hire_dt = if(off_hire_dt == "", do: new_entry.off_hire_date, else: off_hire_dt)

      updated_entry = %{
        new_entry
        | off_hire_date: off_hire_dt,
          on_hire_date: on_hire_dt,
          checker_id: user.id,
          comment: params["comment"] || "",
          accumulative_days: 0,
          accumulative_amount: 0.0
      }

      Ecto.Multi.new()
      |> Ecto.Multi.update(
        {:interchange, index},
        Interchange.changeset(entry, %{auth_status: "COMPLETE"})
      )
      |> Ecto.Multi.insert(
        {:new_hire, index},
        Interchange.changeset(
          %Interchange{maker_id: user.id, auth_status: "APPROVED", status: params["status"]},
          updated_entry
        )
      )
      |> Ecto.Multi.insert(
        {:user_log, index},
        UserLog.changeset(%UserLog{}, %{
          user_id: user.id,
          activity:
            "wagon_id  \"#{entry.wagon_id}\" and train number \"#{entry.train_no}\"  set to \"#{params["status"]}\" "
        })
      )
    end)
    |> Enum.reduce(Ecto.Multi.new(), &Ecto.Multi.append/2)
  end

  def prepare_accumulative_amount(item, lease_period) do
    case Decimal.cmp(item.accumulative_days, lease_period) do
      result when result in [:lt, :eq] ->
        0
      _ ->
        days = Decimal.sub(item.accumulative_days, lease_period)
        Decimal.mult(days, item.interchange_fee)
    end
  end

  def set_single_interchange_off_hire(conn, %{"new_defects" => new_defects} = params) do
    conn.assigns.user
    |> handle_single_interchange(params, new_defects)
    |> Repo.transaction()
    |> case do
      {:ok, _} ->
        json(conn, %{"info" => "sucesss"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        json(conn, %{"error" => "#{reason}"})
    end
  end

  def set_single_interchange_off_hire(conn, params) do
    conn.assigns.user
    |> handle_single_interchange_no_defects(params)
    |> Repo.transaction()
    |> case do
      {:ok, _} ->
        json(conn, %{"info" => "sucesss"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        json(conn, %{"error" => "#{reason}"})
    end
  end

  defp handle_single_interchange(user, params, new_defects) do
    entry = Rms.Tracking.get_interchange!(params["id"])
    item = Rms.Tracking.interchange_hired_report_list_lookup(params["id"])
    wag = Rms.SystemUtilities.get_wagon!(item.wagon_id)

    new_entry = prepare_entry(user, item, params)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:update, Interchange.changeset(entry, %{auth_status: "COMPLETE"}))
    |> Ecto.Multi.insert(
      :new_hire,
      Interchange.changeset(
        %Interchange{maker_id: user.id, auth_status: "APPROVED", status: params["status"]},
        new_entry
      )
    )
    |> handle_single_hire_defects(new_defects)
    |> Ecto.Multi.update(
      :update_wagon,
      Wagon.changeset(wag, %{
        mvt_status: "A",
        condition_id: params["wagon_condition_id"]
      })
    )
    |> Ecto.Multi.run(:insert, fn repo, %{update: update} ->
      activity =
        "wagon_id  \"#{update.wagon_id}\" and train number \"#{update.train_no}\"  set to \"#{params["status"]}\" "

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  defp handle_single_hire_defects(multi, defects) do
    Ecto.Multi.merge(multi, fn %{:new_hire => %{id: interchange_id, wagon_id: wagon_id}} =
                                 _changes ->
      Enum.reduce(defects, Ecto.Multi.new(), fn {index, defect}, multi ->
        params = %{
          interchange_id: interchange_id,
          defect_id: defect["defect_id"],
          wagon_id: wagon_id
        }

        Ecto.Multi.insert(
          multi,
          {:defect, index},
          InterchangeDefect.changeset(%InterchangeDefect{}, params)
        )
      end)
    end)
  end

  defp handle_single_interchange_no_defects(user, params) do
    entry = Rms.Tracking.get_interchange!(params["id"])
    item = Rms.Tracking.interchange_hired_report_list_lookup(params["id"])
    wag = Rms.SystemUtilities.get_wagon!(item.wagon_id)
    new_entry = prepare_entry(user, item, params)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:update, Interchange.changeset(entry, %{auth_status: "COMPLETE"}))
    |> Ecto.Multi.insert(
      :new_hire,
      Interchange.changeset(
        %Interchange{maker_id: user.id, auth_status: "APPROVED", status: params["status"]},
        new_entry
      )
    )
    |> Ecto.Multi.update(
      :update_wagon,
      Wagon.changeset(wag, %{
        mvt_status: "A",
        condition_id: params["wagon_condition_id"]
      })
    )
    |> Ecto.Multi.run(:insert, fn repo, %{update: update} ->
      activity =
        "wagon_id  \"#{update.wagon_id}\" and train number \"#{update.train_no}\"  set to \"#{params["status"]}\"  "

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  defp prepare_entry(user, item, params) do
    on_hire_dt = params["on_hire_date"]
    on_hire_dt = if(on_hire_dt == "", do: item.on_hire_date, else: on_hire_dt)
    off_hire_dt = params["off_hire_date"]
    off_hire_dt = if(off_hire_dt == "", do: item.off_hire_date, else: off_hire_dt)

    %{
      item
      | on_hire_date: on_hire_dt,
        off_hire_date: off_hire_dt,
        checker_id: user.id,
        comment: params["comment"] || "",
        wagon_condition_id: params["wagon_condition_id"],
        accumulative_days: 0,
        accumulative_amount: 0.0
    }
  end

  def interchange_report(conn, %{"type" => type}) do
    admins = Accounts.list_tbl_railway_administrator()
    report_type = %{type: type}

    render(conn, "interchange_report_batch.html",
      type: type,
      admins: admins,
      report_type: report_type
    )
  end

  def interchange_list_report(conn, _params) do
    admins = Accounts.list_tbl_railway_administrator()
    region = SystemUtilities.list_tbl_region()

    render(conn, "interchange_list_report.html",
      admins: admins,
      region: region
    )
  end

  def interchange_report_lookup(conn, %{"type" => "HAULAGE"} = params) do
    {draw, start, length, search_params} = search_options(params)
    lookup = confirm_report_type(conn.request_path)

    results =
      lookup.(
        search_params,
        start,
        length,
        conn.assigns.user
      )

    total_entries = total_entries(results)

    entries =
      Enum.map(entries(results), fn item ->
        %{item | loco_no: RmsWeb.MovementView.locomotives_list(item)}
      end)

    results = %{
      draw: draw,
      recordsTotal: total_entries,
      recordsFiltered: total_entries,
      data: entries
    }

    json(conn, results)
  end

  def interchange_report_lookup(conn, %{"type" => "LOCO_DETENTATION"} = params) do
    {draw, start, length, search_params} = search_options(params)
    lookup = confirm_report_type(conn.request_path)

    results =
      lookup.(
        search_params,
        start,
        length,
        conn.assigns.user
      )

    total_entries = total_entries(results)

    entries =
      Enum.map(entries(results), fn item ->
        %{item | loco_no: RmsWeb.MovementView.locomotives_list(item)}
      end)

    results = %{
      draw: draw,
      recordsTotal: total_entries,
      recordsFiltered: total_entries,
      data: entries
    }

    json(conn, results)
  end

  def interchange_report_lookup(conn, params) do
    {draw, start, length, search_params} = search_options(params)
    lookup = confirm_report_type(conn.request_path)

    results =
      lookup.(
        search_params,
        start,
        length,
        conn.assigns.user
      )

    total_entries = total_entries(results)

    results = %{
      draw: draw,
      recordsTotal: total_entries,
      recordsFiltered: total_entries,
      data: entries(results)
    }

    json(conn, results)
  end

  defp confirm_report_type("/interchange/report/lookup"),
    do: &Rms.Tracking.interchange_off_hire_report_lookup/4

  defp confirm_report_type("/interchange/report/incoming/outgoing/lookup"),
    do: &Rms.Tracking.interchange_off_hire_report_list_lookup/4

  defp confirm_report_type("/interchange/report/hired/wagons/lookup"),
    do: &Rms.Tracking.interchange_hired_report_list_lookup/4

  defp confirm_report_type("/interchange/material/lookup"),
    do: &Rms.Tracking.material_report_lookup/4

  defp confirm_report_type("/auxiliary/lookup"),
    do: &Rms.Tracking.auxiliary_report_lookup/4

  defp confirm_report_type("/auxiliary/daily/summary/lookup"),
    do: &Rms.Tracking.auxiliary_daily_summary_report_lookup/4

  defp confirm_report_type("/locomotive/detention/lookup"),
    do: &Rms.Tracking.loco_detention_report_lookup/4

  defp confirm_report_type("/locomotive/detention/summary/lookup"),
    do: &Rms.Tracking.loco_detention_summary_report_lookup/4

  defp confirm_report_type("/haulage/report/lookup"),
    do: &Rms.Tracking.haulage_report_lookup/4

  defp confirm_report_type("/interchange/exceptions"),
    do: &Rms.SystemUtilities.exceptions_lookup/4

  defp confirm_report_type("/demurrage/report"),
    do: &Rms.Tracking.demurrage_report_lookup/4

  defp confirm_report_type("/works/order/report"),
    do: &Rms.Order.works_order_report_lookup/4

  def total_entries(%{total_entries: total_entries}), do: total_entries
  def total_entries(_), do: 0
  def entries(%{entries: entries}), do: entries
  def entries(_), do: []

  def search_options(params) do
    length = calculate_page_size(params["length"])
    page = calculate_page_num(params["start"], length)
    draw = String.to_integer(params["draw"])
    params = Map.put(params, "isearch", params["search"]["value"])

    new_params =
      Enum.reduce(~w(columns order search length draw start _csrf_token), params, fn key, acc ->
        Map.delete(acc, key)
      end)

    {draw, page, length, new_params}
  end

  def calculate_page_num(nil, _), do: 1

  def calculate_page_num(start, length) do
    start = String.to_integer(start)
    round(start / length + 1)
  end

  def calculate_page_size(nil), do: 10
  def calculate_page_size(length), do: String.to_integer(length)

  def interchange_batch_report_entries(conn, params) do
    interchange = Rms.Tracking.interchange_entry_lookup(params["id"], "COMPLETE", "OFF_HIRE")
    render(conn, "interchange_batch_report_entries.html", interchange: interchange)
  end

  def interchange_excel_exp(conn, %{"report_type" => report_type} = params) do
    entries = process_report(conn, @current, params)
    user = conn.assigns.user

    conn
    |> put_resp_content_type("text/xlsx")
    |> put_resp_header(
      "content-disposition",
      "attachment; filename=#{params["report_type"]}_#{Timex.today()}.xlsx"
    )
    |> render("report.xlsx", %{entries: entries, user: user, report_type: report_type})
  end

  defp process_report(conn, source, params) do
    params
    |> Map.delete("_csrf_token")
    |> report_generator(source, conn.assigns.user)
    |> Repo.all()
  end

  defp report_generator(
         %{"report_type" => "INTERCHANGE_LIST_REPORT"} = search_params,
         source,
         user
       ) do
    Rms.Tracking.interchange_off_hire_report_list_lookup(
      source,
      Map.put(search_params, "isearch", ""),
      user
    )
  end

  defp report_generator(
         %{"report_type" => "INCOMING_WAGONS_ON_HIRE_REPORT"} = search_params,
         source,
         user
       ) do
    Rms.Tracking.interchange_hired_report_list_lookup(
      source,
      Map.put(search_params, "isearch", ""),
      user
    )
  end

  defp report_generator(
         %{"report_type" => "INCOMING_WAGONS_OFF_HIRE_REPORT"} = search_params,
         source,
         user
       ) do
    Rms.Tracking.interchange_hired_report_list_lookup(
      source,
      Map.put(search_params, "isearch", ""),
      user
    )
  end

  defp report_generator(
         %{"report_type" => "OUTGOING_WAGONS_ON_HIRE_REPORT"} = search_params,
         source,
         user
       ) do
    Rms.Tracking.interchange_hired_report_list_lookup(
      source,
      Map.put(search_params, "isearch", ""),
      user
    )
  end

  defp report_generator(
         %{"report_type" => "OUTGOING_WAGONS_OFF_HIRE_REPORT"} = search_params,
         source,
         user
       ) do
    Rms.Tracking.interchange_hired_report_list_lookup(
      source,
      Map.put(search_params, "isearch", ""),
      user
    )
  end

  defp report_generator(
         %{"report_type" => "MATERIALS_REPORT"} = search_params,
         source,
         user
       ) do
    Rms.Tracking.material_report_lookup(
      source,
      Map.put(search_params, "isearch", ""),
      user
    )
  end

  defp report_generator(
         %{"report_type" => "INCOMING_AUXILIARY_REPORT"} = search_params,
         source,
         user
       ) do
    Rms.Tracking.auxiliary_report_lookup(
      source,
      Map.put(search_params, "isearch", ""),
      user
    )
  end

  defp report_generator(
         %{"report_type" => "OUTGOING_AUXILIARY_REPORT"} = search_params,
         source,
         user
       ) do
    Rms.Tracking.auxiliary_report_lookup(
      source,
      Map.put(search_params, "isearch", ""),
      user
    )
  end

  defp report_generator(
         %{"report_type" => "OUTGOING_AUXILIARY_ON_HIRE_REPORT"} = search_params,
         source,
         user
       ) do
    Rms.Tracking.auxiliary_report_lookup(
      source,
      Map.put(search_params, "isearch", ""),
      user
    )
  end

  defp report_generator(
         %{"report_type" => "INCOMING_AUXILIARY_ON_HIRE_REPORT"} = search_params,
         source,
         user
       ) do
    Rms.Tracking.auxiliary_report_lookup(
      source,
      Map.put(search_params, "isearch", ""),
      user
    )
  end

  defp report_generator(
         %{"report_type" => "AUXILIARY_DAILY_SUMMARY_REPORT"} = search_params,
         source,
         user
       ) do
    Rms.Tracking.auxiliary_daily_summary_report_lookup(
      source,
      Map.put(search_params, "isearch", ""),
      user
    )
  end

  defp report_generator(
         %{"report_type" => "INCOMING_LOCO_DETENTION_REPORT"} = search_params,
         source,
         user
       ) do
    Rms.Tracking.loco_detention_report_lookup(
      source,
      Map.put(search_params, "isearch", ""),
      user
    )
  end

  defp report_generator(
         %{"report_type" => "OUTGOING_LOCO_DETENTION_REPORT"} = search_params,
         source,
         user
       ) do
    Rms.Tracking.loco_detention_report_lookup(
      source,
      Map.put(search_params, "isearch", ""),
      user
    )
  end

  defp report_generator(
         %{"report_type" => "LOCO_DETENTION_SUMMARY_REPORT"} = search_params,
         source,
         user
       ) do
    Rms.Tracking.loco_detention_summary_report_lookup(
      source,
      Map.put(search_params, "isearch", ""),
      user
    )
  end

  defp report_generator(
         %{"report_type" => "INCOMING_HAULAGE_REPORT"} = search_params,
         source,
         user
       ) do
    Rms.Tracking.haulage_report_lookup(
      source,
      Map.put(search_params, "isearch", ""),
      user
    )
  end

  defp report_generator(
         %{"report_type" => "OUTGOING_HAULAGE_REPORT"} = search_params,
         source,
         user
       ) do
    Rms.Tracking.haulage_report_lookup(
      source,
      Map.put(search_params, "isearch", ""),
      user
    )
  end

  defp report_generator(
         %{"report_type" => "MECHANICAL_BILLS_REPORT"} = search_params,
         source,
         user
       ) do
    Rms.Tracking.mechanical_bills_report_lookup(
      source,
      Map.put(search_params, "isearch", ""),
      user
    )
  end

  defp report_generator(
         %{"report_type" => "DEMURRAGE_REPORT"} = search_params,
         source,
         user
       ) do
    Rms.Tracking.demurrage_report_lookup(
      source,
      Map.put(search_params, "isearch", ""),
      user
    )
  end

  defp report_generator(
        %{"report_type" => "WORKS_ORDER_REPORT"} = search_params,
        source,
        user
      ) do
    Rms.Order.works_order_report_lookup(
    source,
    Map.put(search_params, "isearch", ""),
    user
    )
  end

  defp report_generator(search_params, source, user) do
    Rms.Tracking.interchange_off_hire_report_lookup(
      source,
      Map.put(search_params, "isearch", ""),
      user
    )
  end

  def train_no_lookup(conn, %{"train_no" => train_no, "track" => "YES"}) do
    items = Tracking.interchange_train_no_lookup(String.trim(train_no))
    json(conn, %{"data" => List.wrap(items)})
  end

  def train_no_lookup(conn, %{"train_no" => train_no}) do
    items = Rms.Order.lookup_train_no(String.trim(train_no))
    json(conn, %{"data" => List.wrap(items)})
  end

  def set_hire(conn, %{"entries" => params}) do
    conn.assigns.user
    |> handle_set_hire(params)
    |> Repo.transaction()
    |> case do
      {:ok, _} ->
        json(conn, %{"info" => "sucesss"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        json(conn, %{"error" => "#{reason}"})
    end
  end

  defp handle_set_hire(user, params) do
    uuid = Ecto.UUID.generate()

    params
    |> Enum.map(fn {index, item} ->
      Ecto.Multi.new()
      |> Ecto.Multi.insert(
        {:interchange, index},
        Interchange.changeset(
          %Interchange{
            maker_id: user.id,
            uuid: uuid,
            checker_id: user.id,
            auth_status: "APPROVED",
            status: "ON_HIRE"
          },
          item
        )
      )
      |> Ecto.Multi.insert(
        {:user_log, index},
        UserLog.changeset(%UserLog{}, %{
          user_id: user.id,
          activity:
            " wagon_id \"#{item["wagon_id"]}\" on train numner  \"#{item["train_no"]}\" set "
        })
      )
    end)
    |> Enum.reduce(Ecto.Multi.new(), &Ecto.Multi.append/2)
  end

  def incoming_wagons_on_hire(conn, _params) do
    status = "ON_HIRE"
    condition = SystemUtilities.list_tbl_condition() |> Enum.reject(&(&1.status != "A"))
    stations = SystemUtilities.list_tbl_station()
    defects = SystemUtilities.list_tbl_defects("INTL") |> Enum.reject(&(&1.status != "A"))
    admins = Accounts.list_tbl_railway_administrator()
    commodity = SystemUtilities.list_tbl_commodity()

    render(conn, "incoming_wagons_on_hire.html",
      admins: admins,
      stations: stations,
      commodity: commodity,
      defects: defects,
      condition: condition,
      status: status
    )
  end

  def incoming_wagons_off_hire(conn, _params) do
    status = "OFF_HIRE"
    condition = SystemUtilities.list_tbl_condition() |> Enum.reject(&(&1.status != "A"))
    stations = SystemUtilities.list_tbl_station()
    defects = SystemUtilities.list_tbl_defects("INTL") |> Enum.reject(&(&1.status != "A"))
    admins = Accounts.list_tbl_railway_administrator()
    commodity = SystemUtilities.list_tbl_commodity()

    render(conn, "incoming_wagons_off_hire.html",
      admins: admins,
      stations: stations,
      commodity: commodity,
      defects: defects,
      condition: condition,
      status: status
    )
  end

  def outgoing_wagons_on_hire(conn, _params) do
    status = "ON_HIRE"
    stations = SystemUtilities.list_tbl_station()
    defects = SystemUtilities.list_tbl_defects("INTL") |> Enum.reject(&(&1.status != "A"))
    condition = SystemUtilities.list_tbl_condition() |> Enum.reject(&(&1.status != "A"))
    admins = Accounts.list_tbl_railway_administrator()
    commodity = SystemUtilities.list_tbl_commodity()

    render(conn, "outgoing_wagons_on_hire.html",
      admins: admins,
      stations: stations,
      commodity: commodity,
      defects: defects,
      condition: condition,
      status: status
    )
  end

  def outgoing_wagons_off_hire(conn, _params) do
    status = "OFF_HIRE"
    stations = SystemUtilities.list_tbl_station()
    defects = SystemUtilities.list_tbl_defects("INTL") |> Enum.reject(&(&1.status != "A"))
    condition = SystemUtilities.list_tbl_condition() |> Enum.reject(&(&1.status != "A"))
    admins = Accounts.list_tbl_railway_administrator()
    commodity = SystemUtilities.list_tbl_commodity()

    render(conn, "outgoing_wagons_off_hire.html",
      admins: admins,
      stations: stations,
      commodity: commodity,
      defects: defects,
      condition: condition,
      status: status
    )
  end

  def modify_wagon_hire(conn, params) do
    entry = Rms.Tracking.interchange_hired_report_list_lookup(params["id"])
    stations = SystemUtilities.list_tbl_station()
    defects = SystemUtilities.list_tbl_defects("INTL") |> Enum.reject(&(&1.status != "A"))
    condition = SystemUtilities.list_tbl_condition() |> Enum.reject(&(&1.status != "A"))
    admins = Accounts.list_tbl_railway_administrator()
    commodity = SystemUtilities.list_tbl_commodity()
    wagon_status = SystemUtilities.list_tbl_status() |> Enum.reject(&(&1.rec_status != "A"))

    render(conn, "modify_wagon_hire.html",
      admins: admins,
      stations: stations,
      commodity: commodity,
      defects: defects,
      condition: condition,
      wagon_status: wagon_status,
      entry: entry
    )
  end

  def materials(conn, _params) do
    admins = Accounts.list_tbl_railway_administrator() |> Enum.reject(&(&1.status != "A"))
    spares = SystemUtilities.list_tbl_spares() |> Enum.reject(&(&1.status != "A"))

    render(conn, "materials.html",
      admins: admins,
      spares: spares
    )
  end

  def modify_material(conn, params) do
    entry = Tracking.get_material!(params["id"])
    admins = Accounts.list_tbl_railway_administrator() |> Enum.reject(&(&1.status != "A"))
    spares = SystemUtilities.list_tbl_spares() |> Enum.reject(&(&1.status != "A"))

    render(conn, "modify_material.html",
      admins: admins,
      spares: spares,
      entry: entry
    )
  end

  def track_material(conn, params) do
    conn.assigns.user
    |> handle_track_material(params)
    |> Repo.transaction()
    |> case do
      {:ok, _} ->
        json(conn, %{"info" => "sucesss"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        json(conn, %{"error" => "#{reason}"})
    end
  end

  defp handle_track_material(user, params) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(:create, Material.changeset(%Material{maker_id: user.id}, params))
    |> Ecto.Multi.run(:user_log, fn repo, %{create: create} ->
      activity =
        "Equipment: \"#{create.spare_id}\" direction: \"#{create.direction}\" and admin: \"#{create.admin_id}\" "

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  def update_material(conn, params) do
    conn.assigns.user
    |> handle_update_material(params)
    |> Repo.transaction()
    |> case do
      {:ok, _} ->
        json(conn, %{"info" => "sucesss"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        json(conn, %{"error" => "#{reason}"})
    end
  end

  defp handle_update_material(user, params) do

    item = Tracking.get_material!(params["id"])

    Ecto.Multi.new()
    |> Ecto.Multi.update(:update, Material.changeset(item, params))
    |> Ecto.Multi.run(:user_log, fn repo, %{update: update} ->
      activity =
        "Modified Equipment: \"#{update.spare_id}\" direction: \"#{update.direction}\" and admin: \"#{update.admin_id}\" "

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  def outgoing_materials(conn, _params) do
    admins = Accounts.list_tbl_railway_administrator() |> Enum.reject(&(&1.status != "A"))
    spares = SystemUtilities.list_tbl_spares() |> Enum.reject(&(&1.status != "A"))

    render(conn, "outgoing_materials.html",
      admins: admins,
      spares: spares
    )
  end

  def incoming_materials(conn, _params) do
    admins = Accounts.list_tbl_railway_administrator() |> Enum.reject(&(&1.status != "A"))
    spares = SystemUtilities.list_tbl_spares() |> Enum.reject(&(&1.status != "A"))

    render(conn, "incoming_materials.html",
      admins: admins,
      spares: spares
    )
  end

  def auxiliary_hire(conn, _params) do
    admins = Accounts.list_tbl_railway_administrator() |> Enum.reject(&(&1.status != "A"))
    equipments = SystemUtilities.list_tbl_equipments() |> Enum.reject(&(&1.status != "A"))

    stations =
      SystemUtilities.list_tbl_station()
      |> Enum.reject(&(&1.status != "A"))
      |> Enum.reject(&(&1.interchange_point != "YES"))

    render(conn, "auxiliary_hire.html",
      admins: admins,
      equipments: equipments,
      stations: stations
    )
  end

  def modify_auxiliary_hire(conn, params) do
    admins = Accounts.list_tbl_railway_administrator() |> Enum.reject(&(&1.status != "A"))
    equipments = SystemUtilities.list_tbl_equipments() |> Enum.reject(&(&1.status != "A"))
    entry = Tracking.auxiliary_lookup(params["id"])
    interchange_points =
      SystemUtilities.list_tbl_station()
      |> Enum.reject(&(&1.status != "A"))
      |> Enum.reject(&(&1.interchange_point != "YES"))

    stations = SystemUtilities.list_tbl_station()|> Enum.reject(&(&1.status != "A"))

      render(conn, "modify_auxiliary_hire.html",
      admins: admins,
      equipments: equipments,
      interchange_points: interchange_points,
      stations: stations,
      entry: entry
    )
  end

  def incoming_auxiliary_hire(conn, _params) do
    admins = Accounts.list_tbl_railway_administrator() |> Enum.reject(&(&1.status != "A"))
    equipments = SystemUtilities.list_tbl_equipments() |> Enum.reject(&(&1.status != "A"))

    render(conn, "incoming_auxiliary_hire.html",
      admins: admins,
      equipments: equipments
    )
  end

  def outgoing_auxiliary_hire(conn, _params) do
    admins = Accounts.list_tbl_railway_administrator() |> Enum.reject(&(&1.status != "A"))
    equipments = SystemUtilities.list_tbl_equipments() |> Enum.reject(&(&1.status != "A"))

    render(conn, "outgoing_auxiliary_hire.html",
      admins: admins,
      equipments: equipments
    )
  end

  def create_auxiliary_hire(conn, params) do
    user = conn.assigns.user

    handle_auxiliary_hire(user, params)
    |> Repo.transaction()
    |> case do
      {:ok, _} ->
        json(conn, %{"info" => "sucesss"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        json(conn, %{"error" => "#{reason}"})
    end
  end

  defp handle_auxiliary_hire(user, params) do
    params["equipments"]
    |> Enum.map(fn {index, item} ->

        item = prepare_aux_params(item)

      Ecto.Multi.new()
      |> Ecto.Multi.insert({:create, index}, Auxiliary.changeset(%Auxiliary{maker_id: user.id}, item))
      |> Ecto.Multi.insert(
        {:user_log, index},
        UserLog.changeset(%UserLog{}, %{
          user_id: user.id,
          activity:
          "Equipment: \"#{item["equipment_id"]}\" direction: \"#{item["dirction"]}\" and admin: \"#{item["admin_id"]}\" "
        })
      )
    end)
    |> Enum.reduce(Ecto.Multi.new(), &Ecto.Multi.append/2)
  end

  defp prepare_aux_params(item) do
    Map.merge(
      item,
      %{
        "current_station_id" => item["interchange_point_id"],
        "update_date" => item["received_date"] || item["sent_date"],
        "on_hire_date" => item["received_date"] || item["sent_date"]
      }
    )
  end

  def off_hire_auxiliary(conn,  params) do
    user = conn.assigns.user

    handle_update(user, params)
    |> Repo.transaction()
    |> case do
      {:ok, _} ->
        json(conn, %{"info" => "Changes applied successfully!"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        json(conn, %{"error" => reason})
    end
  end

  defp handle_update(user, params) do

    params["entries"]
    |> Enum.map(fn {index, item} ->

        new_hire = prepare_auxiliary_hire_params(item, params)
        auxiliary = Tracking.get_auxiliary!(item["id"])

      Ecto.Multi.new()
      |> Ecto.Multi.update({:update, index}, Auxiliary.changeset(auxiliary, %{auth_status: "COMPLETE"}))
      |> Ecto.Multi.insert({:create, index},
        Auxiliary.changeset(%Auxiliary{hire_off_user_id: user.id}, new_hire)
      )
      |> Ecto.Multi.insert(
        {:user_log, index},
        UserLog.changeset(%UserLog{}, %{
          user_id: user.id,
          activity: "Set Auxiliary item to  \"#{auxiliary.status}\" hire: \"#{auxiliary.id}\""
        })
      )
    end)
    |> Enum.reduce(Ecto.Multi.new(), &Ecto.Multi.append/2)
  end

  defp prepare_auxiliary_hire_params(entry, params) do
    item = Tracking.auxiliary_lookup(entry["id"])

    case params["status"] do
      "ON_HIRE" ->
        %{
          item
          | comment: params["comment"] || "",
            on_hire_date: params["on_hire_date"],
            status: "ON_HIRE",
            accumlative_days: 0
        }

      "OFF_HIRE" ->
        %{
          item
          | comment: params["comment"] || "",
            off_hire_date: params["off_hire_date"],
            status: "OFF_HIRE",
            accumlative_days: 0
        }
    end
  end

  def archive_hire_auxiliary(conn, params) do

    conn.assigns.user
    |> handle_archive_hire(params)
    |> Repo.transaction()
    |> case do
      {:ok, _} ->
        json(conn, %{"info" => "Changes applied successfully!"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        json(conn, %{"error" => reason})
    end
  end

  defp handle_archive_hire(user, params) do
    params["entries"]
    |> Enum.map(fn {index, item} ->

        auxiliary = Tracking.get_auxiliary!(item["id"])

      Ecto.Multi.new()
      |> Ecto.Multi.update({:update, index}, Auxiliary.changeset(auxiliary,  Map.merge(
        params, %{
        "auth_status" => "COMPLETE",
        "archive_user_id" => user.id
      })))
      |> Ecto.Multi.insert(
        {:user_log, index},
        UserLog.changeset(%UserLog{}, %{
          user_id: user.id,
          activity: "Archived Auxiliary item: \"#{auxiliary.id}\""
        })
      )
    end)
    |> Enum.reduce(Ecto.Multi.new(), &Ecto.Multi.append/2)
  end

  def incoming_auxiliary_report(conn, _params) do
    admins = Accounts.list_tbl_railway_administrator() |> Enum.reject(&(&1.status != "A"))
    equipments = SystemUtilities.list_tbl_equipments() |> Enum.reject(&(&1.status != "A"))

    render(conn, "incoming_auxiliary_report.html",
      admins: admins,
      equipments: equipments
    )
  end

  def outgoing_auxiliary_report(conn, _params) do
    admins = Accounts.list_tbl_railway_administrator() |> Enum.reject(&(&1.status != "A"))
    equipments = SystemUtilities.list_tbl_equipments() |> Enum.reject(&(&1.status != "A"))

    render(conn, "outgoing_auxiliary_report.html",
      admins: admins,
      equipments: equipments
    )
  end

  def auxiliary_tracking(conn, _params) do
    equipments = SystemUtilities.list_tbl_equipments() |> Enum.reject(&(&1.status != "A"))

    stations =
      SystemUtilities.list_tbl_station()
      |> Enum.reject(&(&1.status != "A"))

    render(conn, "auxiliary_tracking.html", stations: stations, equipments: equipments)
  end

  def auxiliary_lookup(conn, %{"id" => id}) do
    item = Tracking.auxiliary_lookup(id)
    json(conn, %{"data" => item})
  end

  def bulk_auxiliary_tracking(conn, _params) do
    equipments = SystemUtilities.list_tbl_equipments() |> Enum.reject(&(&1.status != "A"))
    stations = SystemUtilities.list_tbl_station() |> Enum.reject(&(&1.status != "A"))

    render(conn, "bulk_auxiliary_tracking.html",
      equipments: equipments,
      stations: stations
    )
  end

  def auxiliary_bulk_tracker(conn, params) do
    conn.assigns.user
    |> handle_auxiliary_bulk_tracker(params)
    |> Repo.transaction()
    |> case do
      {:ok, _} ->
        json(conn, %{"info" => "sucesss"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        json(conn, %{"error" => "#{reason}"})
    end
  end

  defp handle_auxiliary_bulk_tracker(user, params) do
    params["entries"]
    |> Enum.map(fn {index, item} ->
      item = %{item | "accumlative_days" => "0"}

      auxiliary = Tracking.get_auxiliary!(item["id"])

      Ecto.Multi.new()
      |> Ecto.Multi.update(
        {:update, index},
        Auxiliary.changeset(auxiliary, %{auth_status: "COMPLETE"})
      )
      |> Ecto.Multi.insert(
        {:create, index},
        Auxiliary.changeset(%Auxiliary{hire_off_user_id: user.id}, item)
      )
      |> Ecto.Multi.insert(
        {:user_log, index},
        UserLog.changeset(%UserLog{}, %{
          user_id: user.id,
          activity:
            "Tracked Equipment \"#{item["equipment"]}\" current Location: \"#{item["current_station"]}\""
        })
      )
    end)
    |> Enum.reduce(Ecto.Multi.new(), &Ecto.Multi.append/2)
  end

  def auxiliary_tracking_lookup(conn, %{"direction" => direction, "equipment" => equipment}) do
    item = Tracking.auxiliary_bulk_tracking_lookup(direction, equipment)
    json(conn, %{"data" => item})
  end

  def auxiliary_tracking_lookup(conn, %{
        "wagon_code" => wagon_code,
        "equipment_code" => equipment_code
      }) do
    item = Tracking.auxiliary_tracking_lookup(String.trim(wagon_code), equipment_code)
    json(conn, %{"data" => item})
  end

  def track_auxiliary(conn, %{"id" => id} = params) do
    auxiliary = Tracking.get_auxiliary!(id)
    user = conn.assigns.user

    handle_track_auxiliary(user, auxiliary, params)
    |> Repo.transaction()
    |> case do
      {:ok, _} ->
        json(conn, %{"info" => "Changes applied successfully!"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        json(conn, %{"error" => reason})
    end
  end

  defp handle_track_auxiliary(user, auxiliary, params) do
    new_hire = prepare_auxiliary_tracking_params(params)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:update, Auxiliary.changeset(auxiliary, %{auth_status: "COMPLETE"}))
    |> Ecto.Multi.insert(:create, Auxiliary.changeset(%Auxiliary{}, new_hire))
    |> Ecto.Multi.run(:insert, fn repo, %{update: update, create: create} ->
      activity =
        "Tracked Auxiliary item with  \"#{create.equipment_code}\" and: \"#{update.wagon_id}\""

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  defp prepare_auxiliary_tracking_params(params) do
    item = Tracking.auxiliary_lookup(params["id"])

    %{
      item
      | current_station_id: params["current_location_id"] || item.current_station_id,
        current_wagon_id: params["wagon_id"] || "",
        update_date: Timex.today(),
        accumlative_days: 0
    }
  end

  def auxiliary_daily_summary_report(conn, _params) do
    admins = Accounts.list_tbl_railway_administrator() |> Enum.reject(&(&1.status != "A"))
    equipments = SystemUtilities.list_tbl_equipments() |> Enum.reject(&(&1.status != "A"))

    render(conn, "auxiliary_daily_summary_report.html",
      admins: admins,
      equipments: equipments
    )
  end

  def update_auxiliary(conn, %{"id" => id} = params) do
    auxiliary = Tracking.get_auxiliary!(id)
    user = conn.assigns.user

    handle_update_auxiliary(user, auxiliary, params)
    |> Repo.transaction()
    |> case do
      {:ok, _} ->
        json(conn, %{"info" => "Changes applied successfully!"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        json(conn, %{"error" => reason})
    end
  end

  defp handle_update_auxiliary(user, auxiliary, params) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:update, Auxiliary.changeset(auxiliary, params))
    |> Ecto.Multi.run(:insert, fn repo, %{update: update} ->
      activity = "Modified Auxiliary item \"#{update.id}\""

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  def wagon_tracking(conn, _params) do
    stations = SystemUtilities.list_tbl_station() |> Enum.reject(&(&1.status != "A"))
    spares = SystemUtilities.list_tbl_spares() |> Enum.reject(&(&1.status != "A"))
    condition = SystemUtilities.list_tbl_condition() |> Enum.reject(&(&1.status != "A"))
    wagon_status = SystemUtilities.list_tbl_status() |> Enum.reject(&(&1.rec_status != "A"))
    wagon_defects = SystemUtilities.list_tbl_defects("LOCAL") |> Enum.reject(&(&1.status != "A"))
    domain = SystemUtilities.list_tbl_domain() |> Enum.reject(&(&1.status != "A"))

    render(conn, "wagon_tracking.html",
      stations: stations,
      spares: spares,
      condition: condition,
      wagon_status: wagon_status,
      domain: domain,
      defects: wagon_defects
    )
  end

  def track_wagon(conn, params) do
    conn.assigns.user
    |> handle_wagon_tracker(params)
    |> Repo.transaction()
    |> case do
      {:ok, _} ->
        json(conn, %{"info" => "sucesss"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        json(conn, %{"error" => "#{reason}"})
    end
  end

  defp handle_wagon_tracker(user, params) do
    params["entries"]
    |> Enum.map(fn {index, item} ->
      entry = Rms.Tracking.get_interchange!(item["id"])
      new_entry = Rms.Tracking.get_int_wagon(item["id"])
      updated_entry = prepare_tracking_params(user, new_entry, item, entry)
      current_station = SystemUtilities.get_station!(updated_entry.current_station_id)
      wag = SystemUtilities.get_wagon!(item["wagon_id"])

      check_tracking_defects(item, index, entry, updated_entry, user, current_station)
      |> Ecto.Multi.update(
        {:update_wagon, index},
        Wagon.changeset(wag, %{
          mvt_status: "A",
          station_id: current_station.id,
          wagon_status_id: updated_entry.wagon_status_id,
          domain_id: current_station.domain_id,
          condition_id: updated_entry.wagon_condition_id
        })
      )
      |> Ecto.Multi.insert(
        {:user_log, index},
        UserLog.changeset(%UserLog{}, %{
          user_id: user.id,
          activity: "wagon_id  \"#{entry.wagon_id}\" and train number \"#{entry.train_no}\""
        })
      )
    end)
    |> Enum.reduce(Ecto.Multi.new(), &Ecto.Multi.append/2)
  end

  defp prepare_tracking_params(user, new_entry, item, entry) do
    Map.merge(new_entry, %{
      checker_id: user.id,
      current_station_id: item["new_current_station_id"] || entry.current_station_id,
      comment: item["new_comment"] || "",
      wagon_condition_id: item["new_condition_id"] || entry.wagon_condition_id,
      bound: item["bound"] || "",
      wagon_status_id: item["new_wagon_status_id"] || entry.wagon_status_id,
      update_date: item["update_date"],
      accumulative_days: 0,
      accumulative_amount: 0.0,
      on_hire_date: entry.on_hire_date
    })
  end

  defp check_tracking_defects(
         %{"defects" => defects},
         index,
         entry,
         updated_entry,
         user,
         current_station
       ) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(
      {:interchange, index},
      Interchange.changeset(entry, %{auth_status: "COMPLETE"})
    )
    |> Ecto.Multi.insert(
      {:new_hire, index},
      Interchange.changeset(
        %Interchange{
          maker_id: user.id,
          region_id: current_station.region_id,
          domain_id: current_station.domain_id
        },
        updated_entry
      )
    )
    |> handle_tracking_defects(defects, index)
  end

  defp check_tracking_defects(_item, index, entry, updated_entry, user, current_station) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(
      {:interchange, index},
      Interchange.changeset(entry, %{auth_status: "COMPLETE"})
    )
    |> Ecto.Multi.insert(
      {:new_hire, index},
      Interchange.changeset(
        %Interchange{
          maker_id: user.id,
          region_id: current_station.region_id,
          domain_id: current_station.domain_id
        },
        updated_entry
      )
    )
  end

  defp handle_tracking_defects(multi, defects, item_index) do
    item_key = {:new_hire, item_index}

    Ecto.Multi.merge(multi, fn %{^item_key => %{id: interchange_id, wagon_id: wagon_id}} =
                                 _changes ->
      Enum.reduce(defects, Ecto.Multi.new(), fn {index, defect}, multi ->
        params = %{
          interchange_id: interchange_id,
          defect_id: defect["defect_id"],
          wagon_id: wagon_id
        }

        Ecto.Multi.insert(
          multi,
          {:defect, index, item_index},
          InterchangeDefect.changeset(%InterchangeDefect{}, params)
        )
      end)
    end)
  end

  def loco_detention(conn, _params) do
    admins = Accounts.list_tbl_railway_administrator() |> Enum.reject(&(&1.status != "A"))
    locos = Locomotives.list_tbl_locomotive() |> Enum.reject(&(&1.status != "A"))
    render(conn, "loco_detention.html", admins: admins, locos: locos)
  end

  def create_loco_detention(conn, params) do
    user = conn.assigns.user

    handle_loco_detention(user, params)
    |> Repo.transaction()
    |> case do
      {:ok, _} ->
        json(conn, %{"info" => "Changes applied successfully!"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        json(conn, %{"error" => reason})
    end
  end

  defp handle_loco_detention(user, params) do
    loco_no = params["loco_no"]
    [locomotive_id  | _] = loco_no
    item = params["data"]
    item =
      Map.merge(
        item,
        %{"arrival_date" => item["interchange_date"], "status" => "PENDING", "loco_no" => Poison.encode!(loco_no), "locomotive_id" => locomotive_id}
      )

    Ecto.Multi.new()
    |> Ecto.Multi.insert(
      :create,
      LocoDetention.changeset(%LocoDetention{maker_id: user.id}, item)
    )
    |> Ecto.Multi.run(:insert, fn repo, %{create: create} ->
      activity =
        "Created New loco detention with Train No \"#{create.train_no}\", locomotive \"#{create.locomotive_id}\" and Arrival time\"#{create.arrival_time}\" "

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  def incoming_locomotive(conn, _params) do
    admins = Accounts.list_tbl_railway_administrator() |> Enum.reject(&(&1.status != "A"))
    locos = Locomotives.list_tbl_locomotive() |> Enum.reject(&(&1.status != "A"))
    render(conn, "incoming_locomotive.html", admins: admins, locos: locos)
  end

  def outgoing_locomotive(conn, _params) do
    admins = Accounts.list_tbl_railway_administrator() |> Enum.reject(&(&1.status != "A"))
    locos = Locomotives.list_tbl_locomotive() |> Enum.reject(&(&1.status != "A"))
    render(conn, "outgoing_locomotive.html", admins: admins, locos: locos)
  end

  def modify_locomotive(conn, %{"id" => id}) do
    admins = Accounts.list_tbl_railway_administrator() |> Enum.reject(&(&1.status != "A"))
    locos = Locomotives.list_tbl_locomotive() |> Enum.reject(&(&1.status != "A"))
    entry = Tracking.loco_item_lookup(id)
    render(conn, "modify_locomotive.html", admins: admins, locos: locos, entry: entry)
  end

  def archive_loco_detention(conn, %{"id" => id} = params) do
    entry = Tracking.get_loco_detention!(id)
    user = conn.assigns.user

    handle_archive_loco_detention(user, entry, params)
    |> Repo.transaction()
    |> case do
      {:ok, _} ->
        json(conn, %{"info" => "Changes applied successfully!"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        json(conn, %{"error" => reason})
    end
  end

  defp handle_archive_loco_detention(user, entry, params) do
    new_params = prepare_archive_loco_detention_params(entry, params, user)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:update, LocoDetention.changeset(entry, new_params))
    |> Ecto.Multi.run(:insert, fn repo, %{update: update} ->
      activity =
        "Archived Loco detention item with train No. \"#{update.train_no}\" and:  loco No. \"#{update.locomotive_id}\""

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  def update_loco_detention(conn, %{"id" => id} = params) do
    entry = Tracking.get_loco_detention!(id)
    user = conn.assigns.user

    handle_update_loco_detention(user, entry, params)
    |> Repo.transaction()
    |> case do
      {:ok, _} ->
        json(conn, %{"info" => "Changes applied successfully!"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        json(conn, %{"error" => reason})
    end
  end

  defp handle_update_loco_detention(user, entry, params) do
    new_params = prepare_archive_loco_detention_params(entry, params, user)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:update, LocoDetention.changeset(entry, new_params))
    |> Ecto.Multi.run(:insert, fn repo, %{update: update} ->
      activity =
        "Modified Loco detention item with train No. \"#{update.train_no}\" and:  loco No. \"#{update.locomotive_id}\""

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  defp prepare_archive_loco_detention_params(entry, params, user) do
    {:ok, arrival_datetime} =
      NaiveDateTime.from_iso8601("#{entry.arrival_date} #{entry.arrival_time}:00")

    {:ok, departure_datetime} =
      NaiveDateTime.from_iso8601("#{params["departure_date"]} #{params["departure_time"]}:00")

    actual_delay = Timex.diff(departure_datetime, arrival_datetime, :minutes)
    total_delay = actual_delay - entry.grace_period

    chargeable_delay =
      case actual_delay > entry.grace_period do
        true -> total_delay
        false -> 0
      end

    Map.merge(params, %{
      "chargeable_delay" => chargeable_delay,
      "actual_delay" => actual_delay,
      "amount" => Decimal.mult(chargeable_delay, entry.rate),
      "checker_id" => user.id,
      "status" => "COMPLETE"
    })
  end

  def incoming_locomotive_report(conn, _params) do
    admins = Accounts.list_tbl_railway_administrator() |> Enum.reject(&(&1.status != "A"))
    locos = Locomotives.list_tbl_locomotive() |> Enum.reject(&(&1.status != "A"))
    render(conn, "incoming_locomotive_report.html", admins: admins, locos: locos)
  end

  def outgoing_locomotive_report(conn, _params) do
    admins = Accounts.list_tbl_railway_administrator() |> Enum.reject(&(&1.status != "A"))
    locos = Locomotives.list_tbl_locomotive() |> Enum.reject(&(&1.status != "A"))
    render(conn, "outgoing_locomotive_report.html", admins: admins, locos: locos)
  end

  def locomotive_summary_report(conn, _params) do
    admins = Accounts.list_tbl_railway_administrator() |> Enum.reject(&(&1.status != "A"))
    render(conn, "locomotive_summary_report.html", admins: admins)
  end

  def loco_item_lookup(conn, %{"id" => id}) do
    item = Tracking.loco_item_lookup(id)
    json(conn, %{"data" => item})
  end

  def new_haulage(conn, _params) do
    admins = Accounts.list_tbl_railway_administrator() |> Enum.reject(&(&1.status != "A"))
    locos = Locomotives.list_tbl_locomotive() |> Enum.reject(&(&1.status != "A"))
    render(conn, "new_haulage.html", admins: admins, locos: locos)
  end

  def modify_haulage(conn, %{"id" => id}) do
    entry = Tracking.haulage_item_lookup(id)
    admins = Accounts.list_tbl_railway_administrator() |> Enum.reject(&(&1.status != "A"))
    locos = Locomotives.list_tbl_locomotive() |> Enum.reject(&(&1.status != "A"))
    render(conn, "modify_haulage.html", admins: admins, locos: locos, entry: entry)
  end

  def create_haulage(conn, params) do
    conn.assigns.user
    |> handle_create_haulage(params)
    |> Repo.transaction()
    |> case do
      {:ok, _} ->
        json(conn, %{"info" => "sucesss"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        json(conn, %{"error" => "#{reason}"})
    end
  end

  defp handle_create_haulage(user, params) do
    params["admins"]
    |> Enum.map(fn {index, item} ->
      item = %{item | "loco_no" => Poison.encode!(item["loco_no"])}

      Ecto.Multi.new()
      |> Ecto.Multi.insert(
        {:haulage, index},
        Haulage.changeset(%Haulage{maker_id: user.id}, item)
      )
      |> Ecto.Multi.insert(
        {:user_log, index},
        UserLog.changeset(%UserLog{}, %{
          user_id: user.id,
          activity: "New Create Haulage item train No. : \"#{item["train_no"]}\""
        })
      )
    end)
    |> Enum.reduce(Ecto.Multi.new(), &Ecto.Multi.append/2)
  end

  def update_haulage(conn, params) do
    conn.assigns.user
    |> handle_update_haulage(params)
    |> Repo.transaction()
    |> case do
      {:ok, _} ->
        json(conn, %{"info" => "sucesss"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        json(conn, %{"error" => "#{reason}"})
    end
  end

  defp handle_update_haulage(user, %{"entry" => params, "loco" => loco }) do
    entry = Tracking.get_haulage!(params["id"])
    params = Map.merge(params, %{"loco_no" => Poison.encode!(loco)})

    Ecto.Multi.new()
    |> Ecto.Multi.update(:update, Haulage.changeset(entry, params))
    |> Ecto.Multi.run(:insert, fn repo, %{update: update} ->
      activity =
        "Updated Haulage item : \"#{update.id}\""

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  def incoming_haulage_report(conn, _params) do
    admins = Accounts.list_tbl_railway_administrator() |> Enum.reject(&(&1.status != "A"))
    render(conn, "incoming_haulage_report.html", admins: admins)
  end

  def outgoing_haulage_report(conn, _params) do
    admins = Accounts.list_tbl_railway_administrator() |> Enum.reject(&(&1.status != "A"))
    render(conn, "outgoing_haulage_report.html", admins: admins)
  end

  def haulage_item_lookup(conn, %{"id" => id}) do
    entry = Tracking.haulage_item_lookup(id)
    item = %{entry | loco_no: RmsWeb.MovementView.locomotives_list(entry)}
    json(conn, %{"data" => item})
  end

  def foreign_wagon_tracking(conn, _params) do
    render(conn, "foreign_wagon_tracking.html")
  end

  def handle_bulk_upload(conn, params) do
    try do
      user = conn.assigns.user
      {key, msg, _count} = handle_file_upload(user, params)
      json(conn, %{to_string(key) => msg})
    catch
      _error, error ->
        Logger.error(IO.inspect(Exception.format(:error, error, __STACKTRACE__)))
        json(conn, %{"error" => "Something went wrong. try again"})
    end
  end

  defp handle_file_upload(user, params) do
    with {:ok, filename, destin_path, _rows} <- is_valide_file(params) do
      user
      |> process_bulk_upload(filename, destin_path, params)
      |> case do
        {:ok, {invalid, valid}} ->
          {:info,
           "#{Number.Delimit.number_to_delimited(valid / 2, precision: 0)} Successful entrie(s) and #{invalid} invalid entrie(s)",
           0}

        {:error, reason} ->
          {:error, reason, 0}
      end
    else
      {:error, reason} ->
        {:error, reason, 0}
    end
  end

  def process_bulk_upload(user, filename, path, params) do
    try do
      {:ok, items} = extract_xlsx(path)

      prepare_bulk_params(user, filename, items, params)
      |> Repo.transaction(timeout: 290_000)
      |> case do
        {:ok, multi_records} ->
          {invalid, valid} =
            multi_records
            |> Map.values()
            |> Enum.reduce({0, 0}, fn item, {invalid, valid} ->
              case item do
                %{wagon_status_id: _src} -> {invalid, valid + 1}
                %{col_index: _index} -> {invalid + 1, valid}
                _ -> {invalid, valid}
              end
            end)

          {:ok, {invalid, valid}}

        {:error, _, changeset, _} ->
          # prepare_error_log(changeset, filename)
          reason = traverse_errors(changeset.errors) |> Enum.join("\r\n")
          {:error, reason}
      end
    after
      _filename = Path.rootname(filename) |> Path.basename()
    end
  end

  defp prepare_bulk_params(user, filename, items, params) do
    items
    |> Stream.with_index(2)
    |> Stream.map(fn {item, index} ->
      # changeset = %Interchange{maker_id: user.id }
      #   |> Interchange.changeset(item)
      # Ecto.Multi.insert(Ecto.Multi.new(), Integer.to_string(index), changeset)

      with {old_entry, new_entry} when not is_nil(old_entry) <-
             foreign_wagon_look_up(item, params) do
        Ecto.Multi.new()
        |> Ecto.Multi.update(
          {:old_hire, index},
          Interchange.changeset(old_entry, %{auth_status: "COMPLETE"})
        )
        |> Ecto.Multi.insert(
          {:new_hire, index},
          Interchange.changeset(
            %Interchange{maker_id: user.id},
            new_entry
          )
        )
      else
        _ ->
          {:error,
           %{
             changes: {item, {:new_hire, index}},
             errors: [wagon_id: {" #{item.wagon_code} is invalid", []}]
           }}
      end
    end)
    |> Enum.to_list()
    |> filter_upload_errors(filename, user)
    |> Stream.reject(fn
      %{operations: [{_, {:run, _}}]} -> false
      %{operations: [{{_, _}, {_, changeset, _}} | _]} -> changeset.valid? == false
      %{operations: [{_, {_, changeset, _}} | _]} -> changeset.valid? == false
    end)
    |> Enum.reduce(Ecto.Multi.new(), &Ecto.Multi.append/2)
  end

  defp foreign_wagon_look_up(item, params) do
    commodity_id =
      case Commodity.find_by(commodity_code: item.commodity_sn) do
        nil -> nil
        commodity -> commodity.id
      end

    station_id =
      case Station.find_by(station_code: item.station_sn) do
        nil -> nil
        station -> station.id
      end

    old_entry =
      case Wagon.find_by(code: item.wagon_code) do
        nil -> nil
        wagon -> Interchange.find_by(wagon_id: wagon.id, auth_status: "APPROVED")
      end

    new_entry = prepare_current_tracking_params(old_entry, commodity_id, station_id, params, item)
    {old_entry, new_entry}
  end

  defp prepare_current_tracking_params(old_entry, commodity_id, station_id, params, item) do
    case old_entry do
      nil ->
        %{}

      _ ->
        %{
          Map.from_struct(old_entry)
          | update_date: params["update_date"],
            commodity_id: commodity_id,
            current_station_id: station_id,
            train_no: item.train_no
        }
    end
  end

  # ---------------------- file persistence --------------------------------------
  def is_valide_file(%{"filename" => params}) do
    if upload = params do
      case Path.extname(upload.filename) do
        ext when ext in ~w(.xlsx .XLSX .xls .XLS .csv .CSV) ->
          with {:ok, destin_path} <- persist(upload) do
            case ext not in ~w(.csv .CSV) do
              true ->
                case Xlsxir.multi_extract(destin_path, 0, false, extract_to: :memory) do
                  {:ok, table_id} ->
                    row_count = Xlsxir.get_info(table_id, :rows)
                    Xlsxir.close(table_id)
                    {:ok, upload.filename, destin_path, row_count - 1}

                  {:error, reason} ->
                    {:error, reason}
                end

              _ ->
                {:ok, upload.filename, destin_path, "N(count)"}
            end
          else
            {:error, reason} ->
              {:error, reason}
          end

        _ ->
          {:error, "Invalid File Format"}
      end
    else
      {:error, "No File Uploaded"}
    end
  end

  def persist(%Plug.Upload{filename: filename, path: path}) do
    destin_path = "D:/Development/ELIXIR/files/downloads"
    destin_path = Path.join(destin_path, filename)

    {_key, _resp} =
      with true <- File.exists?(destin_path) do
        {:error, "File with the same name aready exists"}
      else
        false ->
          File.cp(path, destin_path)
          {:ok, destin_path}
      end
  end

  def extract_xlsx(path) do
    case Xlsxir.multi_extract(path, 0, false, extract_to: :memory) do
      {:ok, id} ->
        items =
          Xlsxir.get_list(id)
          |> Enum.reject(&Enum.empty?/1)
          |> Enum.reject(&Enum.all?(&1, fn item -> is_nil(item) end))
          |> List.delete_at(0)
          |> Enum.map(
            &Enum.zip(
              Enum.map(@headers, fn h -> h end),
              Enum.map(&1, fn v -> strgfy_term(v) end)
            )
          )
          |> Enum.map(&Enum.into(&1, %{}))
          |> Enum.reject(&(Enum.join(Map.values(&1)) == ""))

        Xlsxir.close(id)
        {:ok, items}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp strgfy_term(term) when is_tuple(term), do: Enum.join(Tuple.to_list(term))
  defp strgfy_term(term) when not is_tuple(term), do: String.trim("#{term}")

  defp filter_upload_errors(changesets, filename, user) do
    error_changesets =
      changesets
      |> Stream.reject(fn
        %{operations: [{_, {:run, _}}]} -> true
        %{operations: [{{_, _}, {_, changeset, _}} | _]} -> changeset.valid? == true
        _ -> false
      end)
      |> Stream.map(fn
        {:error, %{changes: {entry, index}} = error_entry} ->
          {%{error_entry | changes: entry}, index}

        %{operations: [{index, {_, changeset, _}} | _]} ->
          {changeset, index}
      end)
      |> Enum.to_list()

    error_changesets != [] && prepare_error_excel(error_changesets, filename)

    Ecto.Multi.new()
    |> Ecto.Multi.run(:file_upload_errors, fn _repo, _changes ->
      cond do
        error_changesets == [] ->
          {:ok, %{}}

        true ->
          FileUploadError.create(%{
            filename: filename,
            user_id: user.id,
            type: "FOREIGN_TRACKING",
            new_filename: "#{filename}_#{Timex.today()}",
            upload_date: Timex.today()
          })
      end
    end)
    |> List.wrap()
    |> Stream.concat(changesets)
    |> Enum.reject(&is_tuple/1)
  end

  defp prepare_error_excel(error_changesets, filename) do
    content = RmsWeb.InterchangeView.gen_error_upload_excel(%{data: error_changesets})

    destin_path = "D:/Development/ELIXIR/files/processed"
    File.write!("#{destin_path}/#{filename}_#{Timex.today()}.xlsx", content, [:write])
  end

  def foreign_tracking_exceptions(conn, _params) do
    render(conn, "foreign_tracking_exceptions.html")
  end

  def download_exception_file(conn, %{"filename" => filename} = _params) do
    path = "D:/Development/ELIXIR/files/processed"

    file_content =
      try do
        Path.join(path, filename <> ".xlsx") |> File.read!()
      rescue
        _ ->
          conn
          |> redirect(to: Routes.interchange_path(conn, :foreign_tracking_exceptions))
      end

    conn
    |> put_resp_content_type("text/xlsx")
    |> put_resp_header("content-disposition", "attachment; filename=#{filename}.xlsx")
    |> send_resp(200, file_content)
  end

  def mechanical_bills_report(conn, _params) do
    admins = Accounts.list_tbl_railway_administrator()
    render(conn, "mechanical_bills_report.html", admins: admins)
  end

  def demurrage(conn, _params) do
    currency =
      SystemUtilities.list_tbl_currency()
      |> Enum.reject(&(&1.id != SystemUtilities.list_company_info().prefered_ccy_id))

    commodity = SystemUtilities.list_tbl_commodity() |> Enum.reject(&(&1.status != "A"))
    render(conn, "demurrage.html", commodity: commodity, currency: currency)
  end

  def create_demurrage(conn, %{"entries" => params}) do
    conn.assigns.user
    |> handle_create_demurrage(params)
    |> Repo.transaction()
    |> case do
      {:ok, _} ->
        json(conn, %{"info" => "sucesss"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        json(conn, %{"error" => "#{reason}"})
    end
  end

  defp handle_create_demurrage(user, params) do
    params
    |> Enum.map(fn {index, item} ->
      Ecto.Multi.new()
      |> Ecto.Multi.insert(
        {:demurrage, index},
        Demurrage.changeset(%Demurrage{maker_id: user.id}, item)
      )
      |> Ecto.Multi.insert(
        {:user_log, index},
        UserLog.changeset(%UserLog{}, %{
          user_id: user.id,
          activity:
            "Create Demurrage on Wagon: \"#{item["wagon_id"]}\" with total charge \"#{item["total_charge"]}\""
        })
      )
    end)
    |> Enum.reduce(Ecto.Multi.new(), &Ecto.Multi.append/2)
  end

  def demurrage_report(conn, _params) do
    admins = Accounts.list_tbl_railway_administrator() |> Enum.reject(&(&1.status != "A"))
    render(conn, "demurrage_report.html", admins: admins)
  end

  def demurrage_lookup(conn, %{"id" => id}) do
    item = Tracking.demurrage_lookup(id)
    json(conn, %{"data" => item})
  end

  def current_acc_report(conn, params) do
    admins = Accounts.list_tbl_railway_administrator() |> Enum.reject(&(&1.status != "A"))
    year = params["year"] || Timex.today().year |> to_string
    administrator = params["administrator"]  || 0

    incoming_accounts =
      Tracking.current_account_lookup(year, "INCCOMING", List.wrap(administrator), nil, nil)
      |> Enum.sort_by(& &1.month_No)

    outgoing_accounts =
      Tracking.current_account_lookup(year, "OUTGOING", List.wrap(administrator), nil, nil)
      |> Enum.sort_by(& &1.month_No)

    total_income =
      Enum.reduce(incoming_accounts, 0, fn result , acc ->
        acc +  Decimal.to_float(result.total_amount)
    end)

    total_cost =
      Enum.reduce(outgoing_accounts, 0, fn result , acc ->
        acc +  Decimal.to_float(result.total_amount)
    end)

    net_postion =  (total_income - total_cost)

    render(conn, "current_acc_report.html",
      admins: admins,
      incoming_accounts: incoming_accounts,
      outgoing_accounts: outgoing_accounts,
      year: year,
      administrator: administrator,
      total_cost: total_cost,
      total_income: total_income,
      net_postion: net_postion,
      administrator: administrator
    )
  end

  def account_summary_report(conn, params) do
    administrators =  params["adminstrators"] || []
    admin = Poison.encode!(administrators)
    start_dt = params["start_dt"]
    end_dt = params["end_dt"]
     year =  params["end_dt"]

    incoming_accounts =
      case is_nil(start_dt) or is_nil(end_dt) do
        true -> []
        _  -> Tracking.current_account_lookup(String.slice(year, 6..10), "INCOMING", administrators, start_dt, end_dt)
      end

    outgoing_accounts =
        case is_nil(start_dt) or is_nil(end_dt) do
          true -> []
          _  ->  Tracking.current_account_lookup(String.slice(year, 6..10), "OUTGOING", administrators, start_dt, end_dt)
        end

    admins = Accounts.list_tbl_railway_administrator() |> Enum.reject(&(&1.status != "A"))

    summary =
      Enum.map(incoming_accounts, fn item ->

        cost = Enum.find(outgoing_accounts, fn entry -> entry.admin_name == item.admin_name end)
        variance =  Decimal.to_float(item.total_amount) - Decimal.to_float(cost.total_amount)

        Map.merge(item, %{total_cost: cost.total_amount, variance: variance })
      end)
      |> Enum.reject(&(&1.admin_name == nil))

    render(conn, "current_acc_summary.html",
      admins: admins,
      administrators: admin,
      start_dt: start_dt,
      end_dt: end_dt,
      summary: summary
    )
  end

  def delete_defects(conn, %{"interchange_id" => interchange_id, "defect_id" => defect_id}) do
    entry = InterchangeDefect.find_by(interchange_id: interchange_id, defect_id: defect_id)
    user = conn.assigns.user

    handle_delete_defect(user, entry)
    |> Repo.transaction()
    |> case do
      {:ok, _} ->
        json(conn, %{"info" => "Changes applied successfully!"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        json(conn, %{"error" => reason})
    end
  end

  defp handle_delete_defect(user, entry) do
    Ecto.Multi.new()
    |> Ecto.Multi.delete(:del, entry)
    |> Ecto.Multi.run(:insert, fn repo, %{del: del} ->
      activity =
        "Deleted Defects on wagon \"#{del.wagon_id}\" and  \"#{del.interchange_id}\""

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  def update_wagon_hire(conn, %{"defects" => defects, "entry"=> params }) do
    conn.assigns.user
    |> handle_update_wagon_hire_defects(params, defects)
    |> Repo.transaction()
    |> case do
      {:ok, _} ->
        json(conn, %{"info" => "sucesss"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        json(conn, %{"error" => "#{reason}"})
    end
  end

  def update_wagon_hire(conn, %{"entry"=> params}) do
    conn.assigns.user
    |> handle_update_wagon_hire(params)
    |> Repo.transaction()
    |> case do
      {:ok, _} ->
        json(conn, %{"info" => "sucesss"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        json(conn, %{"error" => "#{reason}"})
    end
  end

  defp handle_update_wagon_hire_defects(user, params, defects) do
    entry = Rms.Tracking.get_interchange!(params["id"])
    wag = Rms.SystemUtilities.get_wagon!(params["wagon_id"])
    current_station = SystemUtilities.get_station!(params["current_station_id"])

    Ecto.Multi.new()
    |> Ecto.Multi.update(:new_hire, Interchange.changeset(entry, params))
    |> handle_single_hire_defects(defects)
    |> Ecto.Multi.update(
      :update_wagon,
      Wagon.changeset(wag, %{
        mvt_status: "A",
        condition_id: params["wagon_condition_id"],
        station_id: current_station.id,
        wagon_status_id: params["wagon_status_id"],
        domain_id: current_station.domain_id,
      })
    )
    |> Ecto.Multi.run(:insert, fn repo, %{new_hire: update} ->
      activity =
        "Modified wagon_id  \"#{update.wagon_id}\" and train number \"#{update.train_no}\""

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  defp handle_update_wagon_hire(user, params) do
    entry = Rms.Tracking.get_interchange!(params["id"])
    wag = Rms.SystemUtilities.get_wagon!(params["wagon_id"])
    current_station = SystemUtilities.get_station!(params["current_station_id"])

    Ecto.Multi.new()
    |> Ecto.Multi.update(:new_hire, Interchange.changeset(entry, params))
    |> Ecto.Multi.update(
      :update_wagon,
      Wagon.changeset(wag, %{
        mvt_status: "A",
        condition_id: params["wagon_condition_id"],
        station_id: current_station.id,
        wagon_status_id: params["wagon_status_id"],
        domain_id: current_station.domain_id,
      })
    )
    |> Ecto.Multi.run(:insert, fn repo, %{new_hire: update} ->
      activity =
        "Modified wagon_id  \"#{update.wagon_id}\" and Train number \"#{update.train_no}\""

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  def wagon_turn_around(conn, params) do
    direction = params["direction"]
    from = params["from"]
    to = params["to"]
    turn_around = Tracking.wagon_turn_around_lookup(direction, from, to)

    render(conn, "wagon_turn_around.html", turn_around: turn_around)
  end

  def traverse_errors(errors) do
    for {key, {msg, _opts}} <- errors, do: "#{key} #{msg}"
  end

  def authorize(conn) do
    case Phoenix.Controller.action_name(conn) do
      act when act in ~w(index create)a ->
        {:interchange, :index}

      act
      when act in ~w(close_interchange)a ->
        {:interchange, :close_interchange}

      act
      when act in ~w( incoming_wagons_off_hire interchange_defect_lookup)a ->
        {:interchange, :incoming_wagons_off_hire}

      act
      when act in ~w( incoming_wagons_on_hire interchange_defect_lookup)a ->
        {:interchange, :incoming_wagons_on_hire}

      act
      when act in ~w(interchange_report interchange_defect_lookup)a ->
        {:interchange, :incoming_wagons_report}

      act
      when act in ~w(outgoing_wagons_on_hire interchange_defect_lookup)a ->
        {:interchange, :outgoing_wagons_on_hire}

      act
      when act in ~w(interchange_report interchange_defect_lookup)a ->
        {:interchange, :outgoing_wagons_report}

      act when act in ~w(set_interchange_batch_off_hire set_single_interchange_off_hire)a ->
        {:interchange, :set_off_hire}

      act when act in ~w(set_interchange_batch_off_hire set_single_interchange_off_hire)a ->
        {:interchange, :set_on_hire}

      act
      when act in ~w(outgoing_wagons_off_hire interchange_defect_lookup)a ->
        {:interchange, :outgoing_wagons_off_hire}

      act
      when act in ~w(interchange_list_report interchange_defect_lookup)a ->
        {:interchange, :all_wagons_report}

      act
      when act in ~w(auxiliary_hire create_auxiliary_hire)a ->
        {:interchange, :auxiliary_hire}

      act
      when act in ~w(outgoing_auxiliary_hire)a ->
        {:interchange, :outgoing_auxiliary_hire}

      act
      when act in ~w(incoming_auxiliary_hire)a ->
        {:interchange, :incoming_auxiliary_hire}

      act
      when act in ~w(bulk_auxiliary_tracking auxiliary_bulk_tracker auxiliary_tracking auxiliary_tracking_lookup track_auxiliary)a ->
        {:interchange, :auxiliary_tracking}

      act
      when act in ~w(incoming_auxiliary_report)a ->
        {:interchange, :incoming_auxiliary_report}

      act
      when act in ~w(outgoing_auxiliary_report)a ->
        {:interchange, :outgoing_auxiliary_report}

      act
      when act in ~w(auxiliary_daily_summary_report)a ->
        {:interchange, :auxiliary_daily_summary_report}

      act
      when act in ~w(materials track_material)a ->
        {:interchange, :materials}

      act
      when act in ~w(outgoing_materials)a ->
        {:interchange, :outgoing_materials}

      act
      when act in ~w(incoming_materials)a ->
        {:interchange, :incoming_materials}

      act
      when act in ~w(wagon_tracking track_wagon)a ->
        {:interchange, :wagon_tracking}

      act
      when act in ~w(loco_detention create_loco_detention)a ->
        {:interchange, :loco_detention}

      act
      when act in ~w(outgoing_locomotive)a ->
        {:interchange, :outgoing_locomotive}

      act
      when act in ~w(incoming_locomotive)a ->
        {:interchange, :incoming_locomotive}

      act
      when act in ~w(locomotive_summary_report)a ->
        {:interchange, :locomotive_summary_report}

      act
      when act in ~w(outgoing_locomotive_report)a ->
        {:interchange, :outgoing_locomotive_report}

      act
      when act in ~w(incoming_locomotive_report)a ->
        {:interchange, :incoming_locomotive_report}

      act
      when act in ~w(incoming_haulage_report)a ->
        {:interchange, :incoming_haulage_report}

      act
      when act in ~w(outgoing_haulage_report)a ->
        {:interchange, :outgoing_haulage_report}

      act
      when act in ~w(new_haulage create_haulage)a ->
        {:interchange, :new_haulage}

      act
      when act in ~w(mechanical_bills_report)a ->
        {:interchange, :mechanical_bills_report}

      act
      when act in ~w(demurrage_report)a ->
        {:interchange, :demurrage_report}

      act
      when act in ~w(demurrage create_demurrage)a ->
        {:interchange, :demurrage}

      act
      when act in ~w(foreign_tracking_exceptions)a ->
        {:interchange, :foreign_tracking_exceptions}

      act
      when act in ~w(foreign_wagon_tracking handle_bulk_upload)a ->
        {:interchange, :foreign_wagon_tracking}

      act
      when act in ~w(current_acc_report account_summary_report)a ->
        {:interchange, :current_acc_report}

      act
      when act in ~w(modify_wagon_hire delete_defects update_wagon_hire)a ->
        {:interchange, :modify_wagon_hire}

      act
      when act in ~w(modify_auxiliary_hire update_auxiliary)a ->
        {:interchange, :modify_auxiliary_hire}

      act
      when act in ~w(modify_haulage update_haulage)a ->
        {:interchange, :modify_haulage}

      act
      when act in ~w(modify_locomotive update_loco_detention)a ->
        {:interchange, :modify_locomotive}

      act
      when act in ~w(modify_material update_material)a ->
        {:interchange, :modify_material}

      act
      when act in ~w(wagon_turn_around)a ->
        {:interchange, :wagon_turn_around}

      _ ->
        {:interchange, :unknown}
    end
  end

end
