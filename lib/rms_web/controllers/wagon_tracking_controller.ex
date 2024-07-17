defmodule RmsWeb.WagonTrackingController do
  use RmsWeb, :controller

  alias Rms.Tracking
  alias Rms.Accounts
  alias Rms.SystemUtilities
  alias Rms.Tracking.{WagonTracking, WagonTrkSpares}
  alias Rms.{Repo, Activity.UserLog}
  alias Rms.SystemUtilities
  alias Rms.SystemUtilities.{Wagon_defect, Wagon}
  alias Rms.Repo
  alias Rms.Tracking.WagonLog
  require Record

  plug(
    RmsWeb.Plugs.RequireAuth
    when action not in [:unknown]
  )

  plug(
    RmsWeb.Plugs.EnforcePasswordPolicy
    when action not in [:unknown]
  )

  plug RmsWeb.Plugs.Authenticate,
       [module_callback: &RmsWeb.WagonTrackingController.authorize/1]
       when action not in [:unknown]

  @current "tbl_wagon_tracking"
  @wagon_symbols ~w(I D K TP FC H TM SV NT L B BVK X HT HS NB TV TF TA TW XS NC NR)
  @wagon_domains ~w(DRC	RSA	BBR	TRZ)

  def index(conn, _params) do
    stations = SystemUtilities.list_tbl_station() |> Enum.reject(&(&1.status != "A"))
    spares = SystemUtilities.list_tbl_spares() |> Enum.reject(&(&1.status != "A"))
    condition = SystemUtilities.list_tbl_condition() |> Enum.reject(&(&1.status != "A"))
    wagon_status = SystemUtilities.list_tbl_status() |> Enum.reject(&(&1.rec_status != "A"))
    wagon_defect = SystemUtilities.list_tbl_defects("LOCAL") |> Enum.reject(&(&1.status != "A"))
    domain = SystemUtilities.list_tbl_domain() |> Enum.reject(&(&1.status != "A"))

    render(conn, "index.html",
      stations: stations,
      spares: spares,
      condition: condition,
      wagon_status: wagon_status,
      domain: domain,
      wagon_defect: wagon_defect
    )
  end

  def create(conn, params) do
    conn.assigns.user
    |> handle_create(params)
    |> Repo.transaction()
    |> case do
      {:ok, _} ->
        json(conn, %{"info" => "sucesss"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        json(conn, %{"error" => "#{reason}"})
    end
  end

  def month_name(params) do
    new_date = String.slice(params["update_date"], -5..-4) |> String.trim() |> String.to_integer()
    Timex.month_shortname(new_date)
  end

  def year(params) do
    String.slice(params["update_date"], -10..3)
  end

  defp handle_create(user, %{"defect_ids" => defect_id} = params) do
    params_defect_id = Poison.encode!(defect_id)
    wag = Rms.SystemUtilities.get_wagon!(params["wagon_id"])

    wagon_load_status = SystemUtilities.get_commodity!(params["commodity_id"]).load_status
    new_month = month_name(params)
    year_of_update = year(params)
    station = params["current_location_id"]
    cond_id = params["condition_id"]
    domain = params["domain_id"]
    commodity = params["commodity_id"]
    status = params["departure"]

    params =
      Map.merge(params, %{
        "status" => "D",
        "maker_id" => user.id,
        "month" => new_month,
        "year" => year_of_update
      })

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:create, WagonTracking.changeset(%WagonTracking{}, params))
    |> Ecto.Multi.update(
      :wag,
      Wagon.changeset(wag, %{
        load_status: wagon_load_status,
        mvt_status: "A",
        station_id: station,
        condition_id: cond_id,
        domain_id: domain,
        wagon_status_id: status,
        commodity_id: commodity
      })
    )
    |> Ecto.Multi.run(:user_log, fn repo, %{create: create} ->
      activity = "Wagon tracking created  \"#{create.id}\""

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)

      wagon_defect = %{
        wagon_id: params["wagon_id"],
        defect_ids: params_defect_id,
        maker_id: user.id,
        tracker_id: create.id
      }

      Wagon_defect.changeset(%Wagon_defect{}, wagon_defect)
      |> repo.insert()
    end)
    |> handle_spares(params)
  end

  defp handle_create(user, params) do
    wag = Rms.SystemUtilities.get_wagon!(params["wagon_id"])

    # wagon_load_status =
    #   case Rms.Order.search_for_train_list_entry(params["wagon_id"], params["train_no"]) do
    #     nil ->
    #       wag.load_status

    #     movement ->
    #       SystemUtilities.get_commodity!(movement.commodity_id).load_status
    #   end
    wagon_load_status = SystemUtilities.get_commodity!(params["commodity_id"]).load_status
    new_month = month_name(params)
    year_of_update = year(params)
    station = params["current_location_id"]
    cond_id = params["condition_id"] || wag.condition_id
    domain = params["domain_id"] || wag.domain_id
    commodity = params["commodity_id"]
    status = params["departure"]

    params =
      Map.merge(params, %{
        "status" => "D",
        "maker_id" => user.id,
        "month" => new_month,
        "year" => year_of_update
      })

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:create, WagonTracking.changeset(%WagonTracking{}, params))
    |> Ecto.Multi.update(
      :wag,
      Wagon.changeset(wag, %{
        load_status: wagon_load_status,
        station_id: station,
        mvt_status: "A",
        condition_id: cond_id,
        domain_id: domain,
        wagon_status_id: status,
        commodity_id: commodity
      })
    )
    |> Ecto.Multi.run(:user_log, fn repo, %{create: create} ->
      activity = "Wagon tracking created  \"#{create.id}\""

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  defp handle_spares(muilt, params) do
    items = params["spares"]

    Ecto.Multi.merge(muilt, fn %{:create => wagontracking} ->
      items
      |> Enum.map(fn {index, item} ->
        Ecto.Multi.new()
        |> Ecto.Multi.insert(
          {:spare, index},
          WagonTrkSpares.changeset(
            %WagonTrkSpares{},
            Map.merge(item, %{
              "tracker_id" => wagontracking.id,
              "wagon_id" => wagontracking.wagon_id
            })
          )
        )
      end)
      |> Enum.reduce(Ecto.Multi.new(), &Ecto.Multi.append/2)
    end)
  end

  def save_tracker(conn, %{"entries" => params}) do
    conn.assigns.user
    |> handle_tracker_create(params)
    |> Repo.transaction()
    |> case do
      {:ok, _} ->
        json(conn, %{"info" => "sucesss"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        json(conn, %{"error" => "#{reason}"})
    end
  end

  defp handle_tracker_create(user, params) do
    items = Map.values(params) |> Enum.reject(&(&1["wagon_id"] == nil))

    Enum.with_index(items, 1)
    |> Enum.reduce(Ecto.Multi.new(), fn {item, index}, multi ->
      handle_defect_tracker(user, item, index, multi)
    end)
    |> Ecto.Multi.run(:user_log, fn _repo, _changes ->
      [%{"train_no" => train_no} | _rest] = items
      activity = "Initiated Wagon tracking for train No. \"#{train_no}\""

      UserLog.create(%{
        user_id: user.id,
        activity: activity
      })
    end)
  end

  defp handle_defect_tracker(user, %{"defect_ids" => [""]} = item, index, multi) do
    wag = Rms.SystemUtilities.get_wagon!(item["wagon_id"])
    load_status = SystemUtilities.get_commodity!(item["commodity_id"]).load_status
    station = item["current_location_id"]
    cond_id = item["condition_id"]
    domain = item["domain_id"]
    status = item["departure"]
    commodity = item["commodity_id"]

    item =
      Map.merge(item, %{
        "status" => "D",
        "maker_id" => user.id,
        "month" => month_name(item),
        "year" => year(item)
      })

    _tracking_key = {:wagontracking, index}

    multi
    |> Ecto.Multi.insert({:wagontracking, index}, WagonTracking.changeset(%WagonTracking{}, item))
    |> Ecto.Multi.update(
      {:update_wagon, index},
      Wagon.changeset(wag, %{
        load_status: load_status,
        mvt_status: "A",
        station_id: station,
        condition_id: cond_id,
        domain_id: domain,
        commodity_id: commodity,
        wagon_status_id: status
      })
    )
  end

  defp handle_defect_tracker(user, %{"defect_ids" => defect_ids} = item, index, multi) do
    params_defect_id = Poison.encode!(defect_ids)
    station = item["current_location_id"]

    wag = Rms.SystemUtilities.get_wagon!(item["wagon_id"])
    domain = item["domain_id"]
    cond_id = item["condition_id"]
    load_status = SystemUtilities.get_commodity!(item["commodity_id"]).load_status
    status = item["departure"]
    commodity = item["commodity_id"]

    item =
      Map.merge(item, %{
        "status" => "D",
        "maker_id" => user.id,
        "month" => month_name(item),
        "year" => year(item)
      })

    tracking_key = {:wagontracking, index}

    multi
    |> Ecto.Multi.insert({:wagontracking, index}, WagonTracking.changeset(%WagonTracking{}, item))
    |> Ecto.Multi.update(
      {:update_wagon, index},
      Wagon.changeset(wag, %{
        load_status: load_status,
        mvt_status: "A",
        station_id: station,
        condition_id: cond_id,
        wagon_status_id: status,
        commodity_id: commodity,
        domain_id: domain
      })
    )
    |> Ecto.Multi.merge(fn %{^tracking_key => wagontracking} ->
      handle_defect_spares(wagontracking, item)
    end)
    |> Ecto.Multi.run({:wagon_defect, index}, fn repo, %{^tracking_key => wagontracking} ->
      wagon_defect = %{
        wagon_id: item["wagon_id"],
        defect_ids: params_defect_id,
        maker_id: user.id,
        tracker_id: wagontracking.id
      }

      Wagon_defect.changeset(%Wagon_defect{}, wagon_defect)
      |> repo.insert()
    end)
  end

  defp handle_defect_tracker(user, item, index, multi) do
    load_status = SystemUtilities.get_commodity!(item["commodity_id"]).load_status
    wag = Rms.SystemUtilities.get_wagon!(item["wagon_id"])

    station = item["current_location_id"]
    cond_id = item["condition_id"]
    domain = item["domain_id"]
    status = item["departure"]
    commodity = item["commodity_id"]

    item =
      Map.merge(item, %{
        "status" => "D",
        "maker_id" => user.id,
        "month" => month_name(item),
        "year" => year(item)
      })

    _tracking_key = {:wagontracking, index}

    multi
    |> Ecto.Multi.insert({:wagontracking, index}, WagonTracking.changeset(%WagonTracking{}, item))
    |> Ecto.Multi.update(
      {:update_wagon, index},
      Wagon.changeset(wag, %{
        load_status: load_status,
        mvt_status: "A",
        station_id: station,
        condition_id: cond_id,
        domain_id: domain,
        commodity_id: commodity,
        wagon_status_id: status
      })
    )
  end

  defp handle_defect_spares(wagontracking, item) do
    item["spares"]
    |> Enum.map(fn {index, item} ->
      Ecto.Multi.new()
      |> Ecto.Multi.insert(
        {:wagontrackingspares, index},
        WagonTrkSpares.changeset(
          %WagonTrkSpares{},
          Map.merge(item, %{
            "tracker_id" => wagontracking.id,
            "wagon_id" => wagontracking.wagon_id
          })
        )
      )
    end)
    |> Enum.reduce(Ecto.Multi.new(), &Ecto.Multi.append/2)
  end

  def view_wagon_tracker(conn, _params) do
    customer = Accounts.list_tbl_clients()
    stations = SystemUtilities.list_tbl_station()
    commodity = SystemUtilities.list_tbl_commodity()
    condition = SystemUtilities.list_tbl_condition()
    wagon_status = SystemUtilities.list_tbl_status()

    render(conn, "tracking_list_report.html",
      customer: customer,
      stations: stations,
      commodity: commodity,
      condition: condition,
      wagon_status: wagon_status
    )
  end

  def view_wagon_position_report(conn, _params) do
    train_num = Rms.SystemUtilities.list_tbl_train_routes()
    tbl_wagon_tracking = Tracking.list_tbl_wagon_tracking()
    wagon = SystemUtilities.list_tbl_wagon()
    customer = Accounts.list_tbl_clients()
    stations = SystemUtilities.list_tbl_station()
    commodity = SystemUtilities.list_tbl_commodity()
    condition = SystemUtilities.list_tbl_condition()
    wagon_status = SystemUtilities.list_tbl_status()
    wagon_defect = SystemUtilities.list_tbl_defects("LOCAL")
    wagon_tracker = Tracking.list_tbl_wagon_tracking()
    domain = SystemUtilities.list_tbl_domain()

    render(conn, "wagon_tracking_position_report.html",
      tbl_wagon_tracking: tbl_wagon_tracking,
      wagon: wagon,
      customer: customer,
      stations: stations,
      commodity: commodity,
      condition: condition,
      wagon_tracker: wagon_tracker,
      wagon_status: wagon_status,
      train_num: train_num,
      wagon_defect: wagon_defect,
      domain: domain
    )
  end

  def wagon_position(conn, _params) do
    tbl_wagon_tracking = Tracking.list_tbl_wagon_tracking()
    test = Tracking.ready()
    test_test = Tracking.get_wagon_tracker_grouped_by_wagon_symbol() |> Enum.group_by(& &1.domain)

    total =
      Enum.reduce(test_test, 0, fn {_key, results}, acc ->
        acc + Enum.reduce(results, 0, &(&1.count + &2))
      end)

    render(conn, "wagon_position_summary.html",
      tbl_wagon_tracking: tbl_wagon_tracking,
      test: test,
      test_test: test_test,
      total: total
    )
  end

  def list_wagon_delayed(conn, params) do
    start_dt = params["start_date"] || Timex.today() |> to_string()
    end_dt = params["end_date"] || Timex.today() |> to_string()

    delayed_wagons =
      Tracking.delayed_wagons_lookup(start_dt, end_dt)
      |> Enum.reject(&(&1.period == nil))
      |> Enum.group_by(& &1.period)

    grand_total =
      Enum.reduce(delayed_wagons, 0, fn {_key, results}, acc ->
        acc + Enum.reduce(results, 0, &(&1.count + &2))
      end)

    totals = Tracking.count_wagons(start_dt, end_dt)
    tot = Tracking.count_wagons(start_dt, end_dt) |> Enum.group_by(& &1.wagon_status)

    total =
      Enum.reduce(tot, 0, fn {_key, results}, acc ->
        acc + Enum.reduce(results, 0, &(&1.count_all + &2))
      end)

    company = SystemUtilities.list_company_info()

    render(conn, "wagon_delayed_summary.html",
      delayed_wagons: delayed_wagons,
      grand_total: grand_total,
      company: company,
      totals: totals,
      total: total,
      start_date: start_dt,
      end_date: end_dt
    )
  end

  def delayed_wagons_generate_pdf(conn, %{"start_dt" => start_dt, "end_dt" => end_dt}) do
    entries = Tracking.delayed_wagons_lookup(start_dt, end_dt)
    content = Rms.Workers.DelayedWagons.generate(entries, start_dt, end_dt)

    conn =
      conn
      |> put_resp_header(
        "content-disposition",
        "attachment; filename=Delayed_Wagons_#{Timex.today()}.pdf"
      )
      |> put_resp_content_type("text/pdf")

    send_resp(conn, 200, content)
  end

  def view_wagon_yard_position_report(conn, _params) do
    wagon = SystemUtilities.list_tbl_wagon()
    stations = SystemUtilities.list_tbl_station()
    commodity = SystemUtilities.list_tbl_commodity()
    wagon_owner = Accounts.list_tbl_railway_administrator()

    render(conn, "wagon_yard_position_report.html",
      wagon: wagon,
      stations: stations,
      commodity: commodity,
      wagon_owner: wagon_owner
    )
  end

  def traverse_errors(errors) do
    for {key, {msg, _opts}} <- errors, do: "#{key} #{msg}"
  end

  def view_wagon_tracker_entries(conn, params) do
    {draw, start, length, search_params} = search_options(params)

    results = Rms.Tracking.get_all_wagon_tracker(search_params, start, length, conn.assigns.user)

    total_entries = total_entries(results)

    results = %{
      draw: draw,
      recordsTotal: total_entries,
      recordsFiltered: total_entries,
      data: entries(results)
    }

    json(conn, results)
  end

  def wagon_tracking_exp(conn, %{"report_type" => report_type} = params) do
    entries = process_wagon_tracking_report(conn, @current, params)
    user = conn.assigns.user

    conn
    |> put_resp_content_type("text/xlsx")
    |> put_resp_header(
      "content-disposition",
      "attachment; filename=#{report_type}_REPORT_#{Timex.today()}.xlsx"
    )
    |> render("report.xlsx", %{entries: entries, user: user, report_type: report_type})
  end

  defp process_wagon_tracking_report(conn, source, %{"report_type" => "WAGON_POSITION"} = params) do
    user = conn.assigns.user
    params |> Map.delete("_csrf_token")

    Rms.Tracking.get_all_wagon_position(source, Map.put(params, "isearch", ""), user)
    |> Repo.all()
  end

  defp process_wagon_tracking_report(
         conn,
         source,
         %{"report_type" => "WAGON_ALLOCATION"} = params
       ) do
    user = conn.assigns.user
    params |> Map.delete("_csrf_token")

    Rms.Tracking.wagon_allocation_lookup(source, Map.put(params, "isearch", ""), user)
    |> Repo.all()
  end

  defp process_wagon_tracking_report(conn, source, %{"report_type" => "WAGON_CONDITION"} = params) do
    user = conn.assigns.user
    params |> Map.delete("_csrf_token")

    Rms.Tracking.get_all_wagons_by_condition(source, Map.put(params, "isearch", ""), user)
    |> Repo.all()
  end

  defp process_wagon_tracking_report(
         conn,
         source,
         %{"report_type" => "WAGON_YARD_POSITION"} = params
       ) do
    user = conn.assigns.user
    params |> Map.delete("_csrf_token")

    Rms.Tracking.get_all_wagon_yard_position(source, Map.put(params, "isearch", ""), user)
    |> Repo.all()
  end

  defp process_wagon_tracking_report(conn, source, params) do
    user = conn.assigns.user
    params |> Map.delete("_csrf_token")

    Rms.Tracking.get_all_wagon_tracker(source, Map.put(params, "isearch", ""), user)
    |> Repo.all()
  end

  def view_wagon_position_entries(conn, params) do
    {draw, start, length, search_params} = search_options(params)

    results = Rms.Tracking.get_all_wagon_position(search_params, start, length, conn.assigns.user)

    total_entries = total_entries(results)

    entries =
      results
      |> entries()
      |> Enum.group_by(& &1.domain)
      |> Enum.map(fn {_domain, values} ->
        grand_total = Enum.reduce(values, 0, fn record, acc -> record.count + acc end)
        Enum.map(values, &Map.put(&1, :grand_total, grand_total))
      end)
      |> List.flatten()

    results = %{
      draw: draw,
      recordsTotal: total_entries,
      recordsFiltered: total_entries,
      data: entries
    }

    json(conn, results)
  end

  def view_wagon_yard_position_entries(conn, params) do
    {draw, start, length, search_params} = search_options(params)

    results =
      Rms.Tracking.get_all_wagon_yard_position(search_params, start, length, conn.assigns.user)

    total_entries = total_entries(results)

    entries =
      results
      |> entries()
      |> Enum.group_by(& &1.current_location)
      |> Enum.map(fn {_current_location, values} ->
        grand_total = Enum.reduce(values, 0, fn record, acc -> record.count + acc end)
        Enum.map(values, &Map.put(&1, :grand_total, grand_total))
      end)
      |> List.flatten()

    results = %{
      draw: draw,
      recordsTotal: total_entries,
      recordsFiltered: total_entries,
      data: entries
    }

    json(conn, results)
  end

  def view_wagon_delayed_entries(conn, params) do
    {draw, start, length, search_params} = search_options(params)

    results = Rms.Tracking.get_all_wagons_delayed(search_params, start, length, conn.assigns.user)

    total_entries = total_entries(results)

    entries =
      results
      |> entries()
      |> Enum.group_by(& &1.count)
      |> Enum.map(fn {_count, values} ->
        grand_total = Enum.reduce(values, 0, fn record, acc -> record.count + acc end)
        Enum.map(values, &Map.put(&1, :grand_total, grand_total))
      end)
      |> List.flatten()

    results = %{
      draw: draw,
      recordsTotal: total_entries,
      recordsFiltered: total_entries,
      data: entries
    }

    json(conn, results)
  end

  def view_wagon_by_condition_entries(conn, params) do
    {draw, start, length, search_params} = search_options(params)

    results =
      Rms.Tracking.get_all_wagons_by_condition(search_params, start, length, conn.assigns.user)

    total_entries = total_entries(results)

    entries =
      results
      |> entries()
      |> Enum.group_by(& &1.count)
      |> Enum.map(fn {_count, values} ->
        grand_total = Enum.reduce(values, 0, fn record, acc -> record.count + acc end)
        Enum.map(values, &Map.put(&1, :grand_total, grand_total))
      end)
      |> List.flatten()

    results = %{
      draw: draw,
      recordsTotal: total_entries,
      recordsFiltered: total_entries,
      data: entries
    }

    json(conn, results)
  end

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

  def view_wagon_tracker_by_id(conn, %{"id" => id}) do
    tracker = Tracking.list_wagon_tracker_with_id(id)
    tracker
    |> IO.inspect(label: "heloooooooooooooooooooooooooo")
    render(conn, "view_wagon_details.html", tracker: tracker)
  end

  def wagon_allocation_report(conn, _params) do
    domain = SystemUtilities.list_tbl_domain()
    customer = Accounts.list_tbl_clients()

    render(conn, "wagon_allocation_report.html",
      customer: customer,
      region: domain
    )
  end

  def view_wagon_allocation_entries(conn, params) do
    {draw, start, length, search_params} = search_options(params)

    results =
      Rms.Tracking.wagon_allocation_lookup(search_params, start, length, conn.assigns.user)

    total_entries = total_entries(results)

    results = %{
      draw: draw,
      recordsTotal: total_entries,
      recordsFiltered: total_entries,
      data: entries(results)
    }

    json(conn, results)
  end

  def view_wagon_daily_position_report(conn, _params) do
    render(conn, "wagon_daily_position_report.html")
  end

  def view_wagon_delayed_report(conn, _params) do
    render(conn, "wagon_delayed_report.html")
  end

  def view_wagon_by_condition_report(conn, _params) do
    domain = SystemUtilities.list_tbl_domain() |> Enum.reject(&(&1.status != "A"))
    wagon_condition = SystemUtilities.list_tbl_condition()
    render(conn, "wagon_condition_report.html", wagon_condition: wagon_condition, domain: domain)
  end

  def bulk_tracking(conn, _params) do
    spares = SystemUtilities.list_tbl_spares() |> Enum.reject(&(&1.status != "A"))
    stations = SystemUtilities.list_tbl_station() |> Enum.reject(&(&1.status != "A"))
    customer = Accounts.list_tbl_clients() |> Enum.reject(&(&1.status != "A"))
    commodity = SystemUtilities.list_tbl_commodity() |> Enum.reject(&(&1.status != "A"))
    condition = SystemUtilities.list_tbl_condition() |> Enum.reject(&(&1.status != "A"))
    wagon_status = SystemUtilities.list_tbl_status() |> Enum.reject(&(&1.rec_status != "A"))
    wagon_defect = SystemUtilities.list_tbl_defects("LOCAL") |> Enum.reject(&(&1.status != "A"))
    domain = SystemUtilities.list_tbl_domain() |> Enum.reject(&(&1.status != "A"))

    render(conn, "bulk_tracking.html",
      stations: stations,
      spares: spares,
      customer: customer,
      commodity: commodity,
      condition: condition,
      wagon_status: wagon_status,
      domain: domain,
      wagon_defect: wagon_defect
    )
  end

  def create_wagon_log() do
    bo_wagon_log = Tracking.bad_order_lookup()

    Enum.each(bo_wagon_log, fn entry ->
      Ecto.Multi.new()
      |> Ecto.Multi.insert(:create, WagonLog.changeset(%WagonLog{}, entry))
      |> Repo.transaction()
    end)
  end

  def update_wagon_mvt_status() do
    items =
      Rms.Tracking.wagon_days_lookup(Rms.SystemUtilities.list_company_info().wagon_mvt_status)

    Enum.with_index(items, 1)
    |> Enum.map(fn {item, index} ->
      entry = Rms.SystemUtilities.get_wagon!(item)

      Ecto.Multi.new()
      |> Ecto.Multi.update(
        {:Wagon, index},
        Wagon.changeset(entry, %{"mvt_status" => "N"})
      )
    end)
    |> Enum.reduce(Ecto.Multi.new(), &Ecto.Multi.append/2)
    |> Repo.transaction()
    |> case do
      {:ok, _} ->
        IO.inspect("wagon updated successufully")

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        IO.inspect(reason, label: "Failed to update wagon tracking")
    end
  end

  def edit_wagon_tracker_by_id(conn, %{"id" => id}) do
    train_num = Rms.SystemUtilities.list_tbl_train_routes()
    tbl_wagon_tracking = Tracking.list_tbl_wagon_tracking()
    tracker = Tracking.list_wagon_tracker_with_id(id)

    wagon = SystemUtilities.list_tbl_wagon() |> Enum.reject(&(&1.status != "A"))
    customer = Accounts.list_tbl_clients() |> Enum.reject(&(&1.status != "A"))
    stations = SystemUtilities.list_tbl_station() |> Enum.reject(&(&1.status != "A"))
    commodity = SystemUtilities.list_tbl_commodity() |> Enum.reject(&(&1.status != "A"))
    condition = SystemUtilities.list_tbl_condition() |> Enum.reject(&(&1.status != "A"))
    wagon_status = SystemUtilities.list_tbl_status() |> Enum.reject(&(&1.rec_status != "A"))
    wagon_defect = SystemUtilities.list_tbl_defects("LOCAL") |> Enum.reject(&(&1.status != "A"))

    region_detail =
      Tracking.list_region_with_country_details() |> Enum.reject(&(&1.status != "A"))

    render(conn, "edit_tracker_record.html",
      tbl_wagon_tracking: tbl_wagon_tracking,
      wagon: wagon,
      customer: customer,
      stations: stations,
      commodity: commodity,
      condition: condition,
      wagon_status: wagon_status,
      train_num: train_num,
      tracker: tracker,
      region_detail: region_detail,
      wagon_defect: wagon_defect
    )
  end

  def bad_order_average_lookup(conn, _params) do
    condition = SystemUtilities.list_tbl_condition()
    render(conn, "wagon_bad_order_ave_report.html", condition: condition)
  end

  def bad_order_average_entries(conn, params) do
    {draw, start, length, search_params} = search_options(params)

    results = Rms.Tracking.get_bad_order_average(search_params, start, length, conn.assigns.user)

    total_entries = total_entries(results)

    results = %{
      draw: draw,
      recordsTotal: total_entries,
      recordsFiltered: total_entries,
      data: entries(results)
    }

    json(conn, results)
  end

  def mvt_train_lookup(conn, %{"train_no" => train_no}) do
    items =
      case WagonTracking.exists?(train_no: train_no) do
        false ->
          Rms.Order.mvt_lookup_train_no(train_no)

        true ->
          Tracking.list_wagon_tracker_lookup_by_train(train_no)
      end

    json(conn, %{"data" => List.wrap(items)})
  end

  def wagon_summary_report(conn, _params) do
    current_admin = SystemUtilities.list_company_info().current_railway_admin
    log_admin = SystemUtilities.list_company_info().log_admin_id
    all_rms_wagons = SystemUtilities.rms_wagon_lookup_by_symbol(current_admin)
    rms_total_wagons = SystemUtilities.all_rms_wagon_lookup_by_symbol(current_admin)

    rms_good_wagons =
      SystemUtilities.rms_go_wagon_lookup_by_symbol(current_admin)
      |> Enum.reject(&(&1.is_usable != "Y"))

    rms_og_by_domain =
      SystemUtilities.rms_wagon_lookup_by_domain(current_admin)
      |> Enum.reject(&(&1.is_usable != "Y"))

    log_og_by_domain = SystemUtilities.rms_wagon_lookup_by_domain(log_admin)
    rms_wagon_load_status = SystemUtilities.rms_lookup_by_load_status(current_admin)
    all_go_wagon_lookup = SystemUtilities.all_go_wagon_lookup()
    company = SystemUtilities.list_company_info()

    rms_wagons =
      Enum.reduce(@wagon_symbols, [], fn symbol, summary ->
        wagon_count =
          all_rms_wagons
          |> Enum.find(%{wagons: 0}, fn map -> map.symbol == symbol end)
          |> Map.get(:wagons)

        summary ++ [{symbol, wagon_count}]
      end)

    rms_loaded_wagons =
      Enum.reduce(@wagon_symbols, [], fn symbol, summary ->
        wagon_count =
          all_rms_wagons
          |> Enum.reject(&(&1.load_status != "L"))
          |> Enum.find(%{wagons: 0}, fn map -> map.symbol == symbol end)
          |> Map.get(:wagons)

        summary ++ [{symbol, wagon_count}]
      end)

    rms_empty_wagons =
      Enum.reduce(@wagon_symbols, [], fn symbol, summary ->
        wagon_count =
          all_rms_wagons
          |> Enum.reject(&(&1.load_status != "E"))
          |> Enum.find(%{wagons: 0}, fn map -> map.symbol == symbol end)
          |> Map.get(:wagons)

        summary ++ [{symbol, wagon_count}]
      end)

    rms_wagon_fleet =
      Enum.reduce(@wagon_symbols, [], fn symbol, summary ->
        wagon_count =
          rms_total_wagons
          |> Enum.find(%{wagons: 0}, fn map -> map.symbol == symbol end)
          |> Map.get(:wagons)

        summary ++ [{symbol, wagon_count}]
      end)

    rms_go_wagons =
      Enum.reduce(@wagon_symbols, [], fn symbol, summary ->
        wagon_count =
          rms_good_wagons
          |> Enum.find(%{wagons: 0}, fn map -> map.symbol == symbol end)
          |> Map.get(:wagons)

        summary ++ [{symbol, wagon_count}]
      end)

    rms_empty_wagons_by_domain =
      Enum.reduce(@wagon_domains, [], fn domain, summary ->
        wagon_count =
          rms_og_by_domain
          |> Enum.reject(&(&1.load_status != "E"))
          |> Enum.find(%{wagons: 0}, fn map -> map.domain == domain end)
          |> Map.get(:wagons)

        summary ++ [{domain, wagon_count}]
      end)

    rms_loaded_wagons_by_domain =
      Enum.reduce(@wagon_domains, [], fn domain, summary ->
        wagon_count =
          rms_og_by_domain
          |> Enum.reject(&(&1.load_status != "L"))
          |> Enum.find(%{wagons: 0}, fn map -> map.domain == domain end)
          |> Map.get(:wagons)

        summary ++ [{domain, wagon_count}]
      end)

    log_empty_wagons_by_domain =
      Enum.reduce(@wagon_domains, [], fn domain, summary ->
        wagon_count =
          log_og_by_domain
          |> Enum.reject(&(&1.load_status != "E"))
          |> Enum.find(%{wagons: 0}, fn map -> map.domain == domain end)
          |> Map.get(:wagons)

        summary ++ [{domain, wagon_count}]
      end)

    log_loaded_wagons_by_domain =
      Enum.reduce(@wagon_domains, [], fn domain, summary ->
        wagon_count =
          log_og_by_domain
          |> Enum.reject(&(&1.load_status != "L"))
          |> Enum.find(%{wagons: 0}, fn map -> map.domain == domain end)
          |> Map.get(:wagons)

        summary ++ [{domain, wagon_count}]
      end)

    all_admins_og_wagons =
      Enum.reduce(all_go_wagon_lookup |> Enum.reject(&(&1.is_usable != "Y")), 0, fn item, acc ->
        item.wagons + acc
      end)

    total_log_og_wagons_by_domain =
      Enum.reduce(log_og_by_domain |> Enum.reject(&(&1.is_usable != "Y")), 0, fn item, acc ->
        item.wagons + acc
      end)

    total_log_wagons_by_domain =
      Enum.reduce(log_og_by_domain, 0, fn item, acc -> item.wagons + acc end)

    total_rms_loaded_wagons_by_domain =
      Enum.reduce(rms_loaded_wagons_by_domain, 0, fn {_, count}, acc -> count + acc end)

    total_log_empty_wagons_by_domain =
      Enum.reduce(log_empty_wagons_by_domain, 0, fn {_, count}, acc -> count + acc end)

    total_log_loaded_wagons_by_domain =
      Enum.reduce(log_loaded_wagons_by_domain, 0, fn {_, count}, acc -> count + acc end)

    total_rms_empty_wagons_by_domain =
      Enum.reduce(rms_empty_wagons_by_domain, 0, fn {_, count}, acc -> count + acc end)

    rms_total_fleet = Enum.reduce(rms_total_wagons, 0, fn item, acc -> item.wagons + acc end)
    rms_total_go_fleet = Enum.reduce(rms_good_wagons, 0, fn item, acc -> item.wagons + acc end)

    rms_total_active =
      Enum.reduce(rms_wagon_load_status |> Enum.reject(&(&1.mvt_status != "A")), 0, fn item,
                                                                                       acc ->
        item.wagons + acc
      end)

    rms_total_non_active =
      Enum.reduce(rms_wagon_load_status |> Enum.reject(&(&1.mvt_status != "N")), 0, fn item,
                                                                                       acc ->
        item.wagons + acc
      end)

    render(conn, "wagon_summary_report.html",
      all_rms_wagons: rms_wagons,
      rms_loaded_wagons: rms_loaded_wagons,
      rms_empty_wagons: rms_empty_wagons,
      rms_wagon_fleet: rms_wagon_fleet,
      rms_go_wagons: rms_go_wagons,
      rms_total_fleet: rms_total_fleet,
      rms_total_go_fleet: rms_total_go_fleet,
      rms_empty_wagons_by_domain: rms_empty_wagons_by_domain,
      rms_loaded_wagons_by_domain: rms_loaded_wagons_by_domain,
      total_rms_loaded_wagons_by_domain: total_rms_loaded_wagons_by_domain,
      total_rms_empty_wagons_by_domain: total_rms_empty_wagons_by_domain,
      log_empty_wagons_by_domain: log_empty_wagons_by_domain,
      log_loaded_wagons_by_domain: log_loaded_wagons_by_domain,
      total_log_wagons_by_domain: total_log_wagons_by_domain,
      total_log_og_wagons_by_domain: total_log_og_wagons_by_domain,
      total_log_empty_wagons_by_domain: total_log_empty_wagons_by_domain,
      total_log_loaded_wagons_by_domain: total_log_loaded_wagons_by_domain,
      rms_total_non_active: rms_total_non_active,
      rms_total_active: rms_total_active,
      all_admins_og_wagons: all_admins_og_wagons,
      company: company
    )
  end

  def generate_wagon_summary_pdf(conn, _params) do
    content = Rms.Workers.WagonSummary.generate()

    conn =
      conn
      |> put_resp_header(
        "content-disposition",
        "attachment; filename=Wagon_summary_report_#{Timex.today()}.pdf"
      )
      |> put_resp_content_type("text/pdf")

    send_resp(conn, 200, content)
  end

  def wagon_stn_search(conn, %{"search" => search_term, "page" => start}) do
    results = SystemUtilities.search_station("%#{search_term}%", String.to_integer(start))
    total_count = if(length(results) > 0, do: List.first(results).total_count, else: 0)

    json(conn, %{
      results: Enum.map(results, &Map.delete(&1, :total_count)),
      total_count: total_count
    })
  end

  def wagon_spare_search(conn, %{"search" => search_term, "page" => start}) do
    results = SystemUtilities.search_spare("%#{search_term}%", String.to_integer(start))
    total_count = if(length(results) > 0, do: List.first(results).total_count, else: 0)

    json(conn, %{
      results: Enum.map(results, &Map.delete(&1, :total_count)),
      total_count: total_count
    })
  end

  def authorize(conn) do
    case Phoenix.Controller.action_name(conn) do
      act when act in ~w(index create wagon_stn_search wagon_spare_search )a ->
        {:wagon_tracking, :index}

      act when act in ~w(list_wagon_delayed delayed_wagons_generate_pdf)a ->
        {:wagon_tracking, :list_wagon_delayed}

      act when act in ~w(view_wagon_by_condition_report view_wagon_by_condition_entries)a ->
        {:wagon_tracking, :view_wagon_by_condition_report}

      act when act in ~w(view_wagon_daily_position_report  view_wagon_daily_position_entries)a ->
        {:wagon_tracking, :view_wagon_daily_position_report}

      act when act in ~w(view_wagon_position_report view_wagon_position_entries)a ->
        {:wagon_tracking, :view_wagon_position_report}

      act
      when act in ~w(view_wagon_tracker view_wagon_tracker_entries wagon_tracking_exp view_wagon_tracker_by_id edit_wagon_tracker_by_id)a ->
        {:wagon_tracking, :view_wagon_tracker}

      act when act in ~w(view_wagon_yard_position_report view_wagon_yard_position_entries)a ->
        {:wagon_tracking, :view_wagon_yard_position_report}

      act when act in ~w(wagon_position)a ->
        {:wagon_tracking, :wagon_position}

      act when act in ~w(wagon_allocation_report view_wagon_allocation_entries)a ->
        {:wagon_tracking, :wagon_allocation_report}

      act when act in ~w(handle_bulk_upload bulk_tracking mvt_train_lookup save_tracker)a ->
        {:wagon_tracking, :handle_bulk_upload}

      act when act in ~w(bad_order_average_entries bad_order_average_lookup)a ->
        {:wagon_tracking, :bad_order_average_entries}

      act when act in ~w(wagon_summary_report generate_wagon_summary_pdf)a ->
        {:wagon_tracking, :wagon_summary_report}

      _ ->
        {:wagon_tracking, :unknown}
    end
  end
end
