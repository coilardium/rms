defmodule RmsWeb.FuelMonitoringController do
  use RmsWeb, :controller
  use Timex

  alias Rms.Order.FuelMonitoring
  alias Rms.Activity.UserLog
  alias Rms.Repo
  alias Rms.SystemUtilities
  alias Rms.Accounts
  alias Rms.Locomotives
  alias Rms.Accounts
  alias Rms.Order
  alias RmsWeb.InterchangeController

  @current "tbl_fuel_monitoring"

  plug(
    RmsWeb.Plugs.RequireAuth
    when action not in [:unknown]
  )

  plug(
    RmsWeb.Plugs.EnforcePasswordPolicy
    when action not in [:unknown]
  )

  plug RmsWeb.Plugs.Authenticate,
       [module_callback: &RmsWeb.FuelMonitoringController.authorize/1]
       when action not in [:unknown, :lookup_fuel_rate, :lookup_loco_number, :loco_capacty_lookup, :search_station_name, :search_user_name, :pending_req_form, :rejected_requisite_details]

  def fuel_order(conn, _params) do
    params = prepare_fuel_batch(conn.assigns.user)

    case Rms.Order.create_batch(params) do
      {:ok, batch} ->
        batch = Rms.Order.get_by_uuid(batch.uuid)

        assigns = [
          batch: batch.batch_no,
          batch_id: batch.id
        ]

        redirect(conn, to: Routes.fuel_monitoring_path(conn, :fuel_monitoring, assigns))

      {:error, changeset} ->
        reason = RmsWeb.UserController.traverse_errors(changeset.errors)

        conn
        |> put_flash(:error, reason)
        |> redirect(to: Routes.user_path(conn, :dashboard))
    end
  end

  ################################# fuel requisite form initiator######################################
  def fuel_monitoring(conn, params) do
    refuel_type = SystemUtilities.list_tbl_refueling_type() |> Enum.reject(&(&1.status != "A"))
    loco_driver = Accounts.get_loco_drivers()
    fuel_rate = SystemUtilities.list_tbl_fuel_rates() |> Enum.reject(&(&1.status != "A"))
    clients = Accounts.list_tbl_clients() |> Enum.reject(&(&1.status != "A"))
    users = Accounts.list_tbl_users() |> Enum.reject(&(&1.status != "A"))
    stations = SystemUtilities.list_tbl_station() |> Enum.reject(&(&1.status != "A"))
    loco_type = Locomotives.list_tbl_locomotive_type() |> Enum.reject(&(&1.status != "A"))
    locomotive_type = Locomotives.list_tbl_locomotive_type() |> Enum.reject(&(&1.status != "A"))
    locomotive = Locomotives.list_tbl_locomotive() |> Enum.reject(&(&1.status != "A"))
    train_type = SystemUtilities.list_tbl_train_type() |> Enum.reject(&(&1.status != "A"))
    section = SystemUtilities.list_tbl_section() |> Enum.reject(&(&1.status != "A"))

    render(conn, "new_fuel_requisite_form.html",
      fuel_rate: fuel_rate,
      clients: clients,
      section: section,
      loco_type: loco_type,
      refuel_type: refuel_type,
      users: users,
      batch_no: params["batch"],
      batch_id: params["batch_id"],
      loco_driver: loco_driver,
      locomotive_type: locomotive_type,
      locomotive: locomotive,
      stations: stations,
      train_type: train_type
    )
  end

  def lookup_loco_number(conn, %{"search" => search_term, "page" => start}) do
    results = Locomotives.select_locomotive_no("%#{search_term}%", String.to_integer(start))
    total_count = if(length(results) > 0, do: List.first(results).total_count, else: 0)

    json(conn, %{
      results: Enum.map(results, &Map.delete(&1, :total_count)),
      total_count: total_count
    })
  end

  def search_station_name(conn, %{"search" => search_term, "page" => start}) do
    results = SystemUtilities.search_station("%#{search_term}%", String.to_integer(start))
    total_count = if(length(results) > 0, do: List.first(results).total_count, else: 0)

    json(conn, %{
      results: Enum.map(results, &Map.delete(&1, :total_count)),
      total_count: total_count
    })
  end

  def search_user_name(conn, %{"search" => search_term, "page" => start}) do
    results = Accounts.search_user("%#{search_term}%", String.to_integer(start))
    total_count = if(length(results) > 0, do: List.first(results).total_count, else: 0)

    json(conn, %{
      results: Enum.map(results, &Map.delete(&1, :total_count)),
      total_count: total_count
    })
  end

  def loco_capacty_lookup(conn, %{"locomotive_id" => locomotive_id}) do
    capacity = Locomotives.locomotive_capacty_lookup(locomotive_id)
    json(conn, %{"data" => List.wrap(capacity)})
  end

  ############################### control verification form###################################
  def control_fuel_verification(conn, params) do
    user = conn.assigns.user
    refuel_type = SystemUtilities.list_tbl_refueling_type()
    fuel_requisite = Rms.Order.pending_control_approvals(user)
    loco_driver = Accounts.get_loco_driver_data()
    fuel_rate = SystemUtilities.list_tbl_fuel_rates()
    wagons = SystemUtilities.list_tbl_wagon()
    clients = Accounts.list_tbl_clients()
    users = Accounts.list_tbl_users()
    tariff_line = SystemUtilities.list_tbl_tariff_line()
    stations = SystemUtilities.list_tbl_station()
    commodity = SystemUtilities.list_tbl_commodity()
    railway_administrator = Accounts.list_tbl_railway_administrator()
    locomotive_type = Locomotives.list_tbl_locomotive_type()
    locomotive = Locomotives.list_tbl_locomotive()
    train_type = SystemUtilities.list_tbl_train_type()
    section = SystemUtilities.list_tbl_section()

    render(conn, "fuel_control_verification_entries.html",
      fuel_rate: fuel_rate,
      clients: clients,
      fuel_requisite: fuel_requisite,
      users: users,
      section: section,
      refuel_type: refuel_type,
      batch_no: params["batch_no"],
      batch_id: params["batch_id"],
      loco_driver: loco_driver,
      locomotive_type: locomotive_type,
      locomotive: locomotive,
      stations: stations,
      commodity: commodity,
      stations: stations,
      tariff_line: tariff_line,
      wagons: wagons,
      train_type: train_type,
      railway_administrator: railway_administrator
    )
  end

  ####################### display table with entries for pending completion#######################
  def pending_completion_entries(conn, params) do
    refuel_type = SystemUtilities.list_tbl_refueling_type()
    view_fuel = Rms.Order.initiated_fuel_entries()
    loco_driver = Accounts.get_loco_driver_data()
    fuel_rate = SystemUtilities.list_tbl_fuel_rates()
    wagons = SystemUtilities.list_tbl_wagon()
    clients = Accounts.list_tbl_clients()
    users = Accounts.list_tbl_users()
    tariff_line = SystemUtilities.list_tbl_tariff_line()
    stations = SystemUtilities.list_tbl_station()
    commodity = SystemUtilities.list_tbl_commodity()
    railway_administrator = Accounts.list_tbl_railway_administrator()
    locomotive_type = Locomotives.list_tbl_locomotive_type()
    locomotive = Locomotives.list_tbl_locomotive()
    train_type = SystemUtilities.list_tbl_train_type()
    section = SystemUtilities.list_tbl_section()

    render(conn, "pending_completion_table.html",
      fuel_rate: fuel_rate,
      view_fuel: view_fuel,
      clients: clients,
      section: section,
      users: users,
      refuel_type: refuel_type,
      batch_no: params["batch_no"],
      batch_id: params["batch_id"],
      loco_driver: loco_driver,
      locomotive_type: locomotive_type,
      locomotive: locomotive,
      stations: stations,
      commodity: commodity,
      stations: stations,
      tariff_line: tariff_line,
      wagons: wagons,
      train_type: train_type,
      railway_administrator: railway_administrator
    )
  end

  ########################### form for intiator to complete entries ######################
  def view_completion_form(conn, params) do
    user = conn.assigns.user
    batch_items = Order.list_fuel_monitoring_batch_items(params["id"])
    view_fuel = Rms.Order.all_fuel_pending_monitoring(params["id"], "PENDING_COMPLETION", user)
    refuel_type = SystemUtilities.list_tbl_refueling_type()
    loco_driver = Accounts.get_loco_driver_data()
    fuel_rate = SystemUtilities.list_tbl_fuel_rates()
    wagons = SystemUtilities.list_tbl_wagon()
    clients = Accounts.list_tbl_clients()
    users = Accounts.list_tbl_users()
    tariff_line = SystemUtilities.list_tbl_tariff_line()
    stations = SystemUtilities.list_tbl_station()
    commodity = SystemUtilities.list_tbl_commodity()
    railway_administrator = Accounts.list_tbl_railway_administrator()
    locomotive_type = Locomotives.list_tbl_locomotive_type()
    locomotive = Locomotives.list_tbl_locomotive()
    train_type = SystemUtilities.list_tbl_train_type()
    section = SystemUtilities.list_tbl_section()

    render(conn, "fuel_completion_form.html",
      fuel_rate: fuel_rate,
      batch_items: batch_items,
      view_fuel: view_fuel,
      section: section,
      clients: clients,
      users: users,
      refuel_type: refuel_type,
      batch_no: params["batch_no"],
      batch_id: params["batch_id"],
      loco_driver: loco_driver,
      locomotive_type: locomotive_type,
      locomotive: locomotive,
      stations: stations,
      commodity: commodity,
      stations: stations,
      tariff_line: tariff_line,
      wagons: wagons,
      train_type: train_type,
      railway_administrator: railway_administrator
    )
  end

  ######################### table display for pending approval list #############################
  # def requisite_pending_approval_list(conn, params) do
  #   user = conn.assigns.user
  #   view_fuel = Rms.Order.all_fuel_pending_monitoring(user)

  #   render(conn, "requisite_pending_approval_list.html", view_fuel: view_fuel)
  # end

  # def view_fuel_details(conn, params) do
  #   view_fuel = Rms.Order.list_tbl_fuel_monitoring()
  #   loco_driver = Accounts.get_loco_driver_data()
  #   fuel_rate = SystemUtilities.list_tbl_fuel_rates()
  #   wagons = SystemUtilities.list_tbl_wagon()
  #   clients = Accounts.list_tbl_clients()
  #   users = Accounts.list_tbl_users()
  #   tariff_line = SystemUtilities.list_tbl_tariff_line()
  #   stations = SystemUtilities.list_tbl_station()
  #   commodity = SystemUtilities.list_tbl_commodity()
  #   railway_administrator = Accounts.list_tbl_railway_administrator()
  #   locomotive_type = Locomotives.list_tbl_locomotive_type()
  #   locomotive =Locomotives.list_tbl_locomotive()
  #   train_type = SystemUtilities.list_tbl_train_type()
  #   render(conn, "show.html", fuel_rate: fuel_rate,
  #   view_fuel: view_fuel,
  #   clients: clients,
  #   users: users,
  #   batch_no: params["batch_no"],
  #   batch_id: params["batch_id"],
  #   loco_driver: loco_driver,
  #   locomotive_type: locomotive_type,
  #   locomotive: locomotive,
  #   stations: stations,
  #   commodity: commodity,
  #   stations: stations,
  #   tariff_line: tariff_line,
  #   wagons: wagons,
  #   train_type: train_type,
  #   railway_administrator: railway_administrator)
  # end

  ######################### form for control to view entries from initiator ###########################################
  def approver_view_fuel_form(conn, params) do
    user = conn.assigns.user
    batch_items = Order.list_fuel_monitoring_batch_items(params["id"])
    fuel_requisite = Rms.Order.all_fuel_pending_monitoring(params["id"], "PENDING_CONTROL", user)
    loco_driver = Accounts.get_loco_driver_data()
    refuel_type = SystemUtilities.list_tbl_refueling_type()
    fuel_rate = SystemUtilities.list_tbl_fuel_rates()
    wagons = SystemUtilities.list_tbl_wagon()
    clients = Accounts.list_tbl_clients()
    users = Accounts.list_tbl_users()
    tariff_line = SystemUtilities.list_tbl_tariff_line()
    stations = SystemUtilities.list_tbl_station()
    commodity = SystemUtilities.list_tbl_commodity()
    railway_administrator = Accounts.list_tbl_railway_administrator()
    locomotive_type = Locomotives.list_tbl_locomotive_type()
    locomotive = Locomotives.list_tbl_locomotive()
    train_type = SystemUtilities.list_tbl_train_type()
    section = SystemUtilities.list_tbl_section()

    render(conn, "control_form_entries.html",
      fuel_requisite: fuel_requisite,
      batch_items: batch_items,
      clients: clients,
      users: users,
      section: section,
      refuel_type: refuel_type,
      loco_driver: loco_driver,
      locomotive_type: locomotive_type,
      locomotive: locomotive,
      batch_no: params["batch_no"],
      batch_id: params["batch_id"],
      stations: stations,
      commodity: commodity,
      stations: stations,
      tariff_line: tariff_line,
      fuel_rate: fuel_rate,
      wagons: wagons,
      train_type: train_type,
      railway_administrator: railway_administrator
    )
  end

  def display_requisiste_details(conn, %{"requisition_no" => requisition_no}) do
    user = conn.assigns.user
    batch_items = Rms.Order.all_fuel_monitoring_entries(requisition_no, user)
    json(conn, %{"data" => List.wrap(batch_items)})
  end

  # def fuel_verification_entries(conn, params) do
  #   batch_items = Order.list_fuel_monitoring_batch_items(params["batch_id"])
  #   loco_driver = Accounts.get_loco_driver_data()
  #   refuel_type = SystemUtilities.list_tbl_refueling_type()
  #   fuel_rate = SystemUtilities.list_tbl_fuel_rates()
  #   wagons = SystemUtilities.list_tbl_wagon()
  #   clients = Accounts.list_tbl_clients()
  #   users = Accounts.list_tbl_users()
  #   tariff_line = SystemUtilities.list_tbl_tariff_line()
  #   stations = SystemUtilities.list_tbl_station()
  #   section = SystemUtilities.list_tbl_section()
  #   commodity = SystemUtilities.list_tbl_commodity()
  #   railway_administrator = Accounts.list_tbl_railway_administrator()
  #   locomotive_type = Locomotives.list_tbl_locomotive_type()
  #   locomotive = Locomotives.list_tbl_locomotive()
  #   train_type = SystemUtilities.list_tbl_train_type()

  #   render(conn, "form.html",
  #     batch_items: batch_items,
  #     clients: clients,
  #     users: users,
  #     section: section,
  #     refuel_type: refuel_type,
  #     loco_driver: loco_driver,
  #     locomotive_type: locomotive_type,
  #     locomotive: locomotive,
  #     batch_no: params["batch_no"],
  #     batch_id: params["batch_id"],
  #     stations: stations,
  #     commodity: commodity,
  #     stations: stations,
  #     tariff_line: tariff_line,
  #     fuel_rate: fuel_rate,
  #     wagons: wagons,
  #     train_type: train_type,
  #     railway_administrator: railway_administrator
  #   )
  # end

  ######################### table display for back office#############################
  def back_office_fuel_approval(conn, params) do
    fuel_approval = Rms.Order.pending_backoffice_approvals()
    refuel_type = SystemUtilities.list_tbl_refueling_type()
    loco_driver = Accounts.get_loco_driver_data()
    fuel_rate = SystemUtilities.list_tbl_fuel_rates()
    wagons = SystemUtilities.list_tbl_wagon()
    clients = Accounts.list_tbl_clients()
    users = Accounts.list_tbl_users()
    tariff_line = SystemUtilities.list_tbl_tariff_line()
    stations = SystemUtilities.list_tbl_station()
    commodity = SystemUtilities.list_tbl_commodity()
    railway_administrator = Accounts.list_tbl_railway_administrator()
    locomotive_type = Locomotives.list_tbl_locomotive_type()
    locomotive = Locomotives.list_tbl_locomotive()
    train_type = SystemUtilities.list_tbl_train_type()

    render(conn, "backoffice_request_list.html",
      fuel_rate: fuel_rate,
      clients: clients,
      fuel_approval: fuel_approval,
      users: users,
      refuel_type: refuel_type,
      batch_no: params["batch_no"],
      batch_id: params["batch_id"],
      loco_driver: loco_driver,
      locomotive_type: locomotive_type,
      locomotive: locomotive,
      stations: stations,
      commodity: commodity,
      stations: stations,
      tariff_line: tariff_line,
      wagons: wagons,
      train_type: train_type,
      railway_administrator: railway_administrator
    )
  end

  ################################ back office form display #############################
  def back_office_form_details(conn, params) do
    user = conn.assigns.user
    batch_items = Order.list_fuel_monitoring_batch_items(params["id"])
    fuel_approval = Rms.Order.all_fuel_pending_monitoring(params["id"], "PENDING_APPROVAL", user)
    loco_driver = Accounts.get_loco_driver_data()
    refuel_type = SystemUtilities.list_tbl_refueling_type()
    fuel_rate = SystemUtilities.list_tbl_fuel_rates()
    wagons = SystemUtilities.list_tbl_wagon()
    clients = Accounts.list_tbl_clients()
    users = Accounts.list_tbl_users()
    tariff_line = SystemUtilities.list_tbl_tariff_line()
    stations = SystemUtilities.list_tbl_station()
    commodity = SystemUtilities.list_tbl_commodity()
    railway_administrator = Accounts.list_tbl_railway_administrator()
    locomotive_type = Locomotives.list_tbl_locomotive_type()
    locomotive = Locomotives.list_tbl_locomotive()
    section = SystemUtilities.list_tbl_section()
    train_type = SystemUtilities.list_tbl_train_type()
    user_name = Rms.Order.get_users_name()

    render(conn, "backoffice_form_display.html",
      fuel_rate: fuel_rate,
      clients: clients,
      user_name: user_name,
      section: section,
      batch_items: batch_items,
      fuel_approval: fuel_approval,
      users: users,
      refuel_type: refuel_type,
      batch_no: params["batch_no"],
      batch_id: params["batch_id"],
      loco_driver: loco_driver,
      locomotive_type: locomotive_type,
      locomotive: locomotive,
      stations: stations,
      commodity: commodity,
      stations: stations,
      tariff_line: tariff_line,
      wagons: wagons,
      train_type: train_type,
      railway_administrator: railway_administrator
    )
  end

  ################################ back office edit requisite form display #############################
  def backoffice_edit_requiste(conn, params) do
    user = conn.assigns.user
    batch_items = Order.list_fuel_monitoring_batch_items(params["id"])
    fuel_approval = Rms.Order.all_fuel_pending_monitoring(params["id"], "PENDING_APPROVAL", user)
    loco_driver = Accounts.get_loco_driver_data()
    refuel_type = SystemUtilities.list_tbl_refueling_type()
    fuel_rate = SystemUtilities.list_tbl_fuel_rates()
    wagons = SystemUtilities.list_tbl_wagon()
    clients = Accounts.list_tbl_clients()
    users = Accounts.list_tbl_users()
    tariff_line = SystemUtilities.list_tbl_tariff_line()
    stations = SystemUtilities.list_tbl_station()
    commodity = SystemUtilities.list_tbl_commodity()
    railway_administrator = Accounts.list_tbl_railway_administrator()
    locomotive_type = Locomotives.list_tbl_locomotive_type()
    locomotive = Locomotives.list_tbl_locomotive()
    section = SystemUtilities.list_tbl_section()
    train_type = SystemUtilities.list_tbl_train_type()
    user_name = Rms.Order.get_users_name()

    render(conn, "backoffice_edit_fuel_requisite_request.html",
      fuel_rate: fuel_rate,
      clients: clients,
      user_name: user_name,
      section: section,
      batch_items: batch_items,
      fuel_approval: fuel_approval,
      users: users,
      refuel_type: refuel_type,
      batch_no: params["batch_no"],
      batch_id: params["batch_id"],
      loco_driver: loco_driver,
      locomotive_type: locomotive_type,
      locomotive: locomotive,
      stations: stations,
      commodity: commodity,
      stations: stations,
      tariff_line: tariff_line,
      wagons: wagons,
      train_type: train_type,
      railway_administrator: railway_administrator
    )
  end

  def monthly_report(conn, params) do
    user = conn.assigns.user
    company = SystemUtilities.list_company_info()
    start_dt = params["start_date"] || Timex.today() |> to_string()
    end_dt = params["end_date"] || Timex.today() |> to_string()

    quarter =
      case params do
        %{"quarter" => _, "year" => _} -> String.to_integer(params["quarter"])
        _ -> Date.quarter_of_year(Timex.local())
      end

    year = params["year"] || Timex.local().year

    fuel_summary =
      quarter
      |> Rms.Order.get_fuel_monitor_by_date(year)
      |> format_summary()

    months = quarter_months(quarter, fuel_summary)
    month_names = Enum.sort_by(Map.keys(months), &Timex.month_to_num/1)
    total_consumed = handle_total_consumed(months, fuel_summary)
    fuel_rate = SystemUtilities.get_fuel_rate_by_date(quarter, year)
    distance = Rms.Order.get_fuel_monitor_by_date(quarter, year)
    tons = Rms.Order.lookup_tonnage(quarter, year)

    section_summary =
      SystemUtilities.get_by_section(start_dt, end_dt, user) |> Enum.group_by(& &1.section)

    _total_cost =
      Enum.reduce(section_summary, 0, fn {_key, results}, acc ->
        acc + Enum.reduce(results, 0, &(Decimal.to_float(&1.total_cost) + &2))
      end)

    currency =
      SystemUtilities.list_tbl_currency()
      |> Enum.reject(&(&1.status != "A"))
      |> Enum.reject(&(&1.type != "LOCAL"))

    depo_summary =
      SystemUtilities.get_depo_summary(start_dt, end_dt, user) |> Enum.group_by(& &1.depo)

    total_refuels =
      Enum.reduce(depo_summary, 0, fn {_key, results}, acc ->
        acc + Enum.reduce(results, 0, &(&1.count + &2))
      end)

    qty_refueled =
      Enum.reduce(depo_summary, 0, fn {_key, results}, acc ->
        acc + Enum.reduce(results, 0, &(Decimal.to_float(&1.qty_refueled) + &2))
      end)

    total_cost =
      Enum.reduce(depo_summary, 0, fn {_key, results}, acc ->
        acc + Enum.reduce(results, 0, &(Decimal.to_float(&1.total_cost) + &2))
      end)

    total_refuel =
      Enum.reduce(section_summary, 0, fn {_key, results}, acc ->
        acc + Enum.reduce(results, 0, &(Decimal.to_float(&1.qty_refueled) + &2))
      end)

    summary = handle_weekly_totals(section_summary)
    exco_summary = handle_summary_totals(fuel_summary)

    {main_costs, total_payments, total_efficiency, main_efficiency} =
      calcu_fuel_costs(fuel_summary, fuel_rate, total_consumed, tons, month_names)

    render(conn, "monthly_report.html",
      months: month_names,
      main_refuel_costs: main_costs,
      total_payments: total_payments,
      total_consumed: total_consumed,
      total_efficiency: total_efficiency,
      main_efficiency: main_efficiency,
      fuel_rate: fuel_rate,
      currency: currency,
      ton_lookup: tons,
      start_date: start_dt,
      end_date: end_dt,
      total_refuel: total_refuel,
      section_summary: summary,
      total_cost: total_cost,
      distance: distance,
      fuel_summary: exco_summary,
      year: year,
      total_cost: total_cost,
      qty_refueled: qty_refueled,
      depo_summary: depo_summary,
      total_refuels: total_refuels,
      quarter: quarter,
      company: company
    )
  end

  def pending_req_form(conn, params) do
    user = conn.assigns.user
    batch_items = Order.list_fuel_monitoring_batch_items(params["id"])
    fuel_approval = Rms.Order.all_fuel_pending_monitoring(params["id"], "PENDING_APPROVAL", user)
    loco_driver = Accounts.get_loco_driver_data()
    refuel_type = SystemUtilities.list_tbl_refueling_type()
    fuel_rate = SystemUtilities.list_tbl_fuel_rates()
    wagons = SystemUtilities.list_tbl_wagon()
    clients = Accounts.list_tbl_clients()
    users = Accounts.list_tbl_users()
    tariff_line = SystemUtilities.list_tbl_tariff_line()
    stations = SystemUtilities.list_tbl_station()
    commodity = SystemUtilities.list_tbl_commodity()
    railway_administrator = Accounts.list_tbl_railway_administrator()
    locomotive_type = Locomotives.list_tbl_locomotive_type()
    locomotive = Locomotives.list_tbl_locomotive()
    section = SystemUtilities.list_tbl_section()
    train_type = SystemUtilities.list_tbl_train_type()
    user_name = Rms.Order.get_users_name()

    render(conn, "pending_req_form.html",
      fuel_rate: fuel_rate,
      clients: clients,
      user_name: user_name,
      section: section,
      batch_items: batch_items,
      fuel_approval: fuel_approval,
      users: users,
      refuel_type: refuel_type,
      batch_no: params["batch_no"],
      batch_id: params["batch_id"],
      loco_driver: loco_driver,
      locomotive_type: locomotive_type,
      locomotive: locomotive,
      stations: stations,
      commodity: commodity,
      stations: stations,
      tariff_line: tariff_line,
      wagons: wagons,
      train_type: train_type,
      railway_administrator: railway_administrator
    )
  end

  def rejected_requisite_table(conn, params) do
    user = conn.assigns.user
    rejected_requisite = Rms.Order.get_rejected_requisite(user)
    loco_driver = Accounts.get_loco_driver_data()
    refuel_type = SystemUtilities.list_tbl_refueling_type()
    fuel_rate = SystemUtilities.list_tbl_fuel_rates()
    wagons = SystemUtilities.list_tbl_wagon()
    clients = Accounts.list_tbl_clients()
    users = Accounts.list_tbl_users()
    tariff_line = SystemUtilities.list_tbl_tariff_line()
    section = SystemUtilities.list_tbl_section()
    stations = SystemUtilities.list_tbl_station()
    commodity = SystemUtilities.list_tbl_commodity()
    railway_administrator = Accounts.list_tbl_railway_administrator()
    locomotive_type = Locomotives.list_tbl_locomotive_type()
    locomotive = Locomotives.list_tbl_locomotive()
    train_type = SystemUtilities.list_tbl_train_type()

    render(conn, "rejected_fuel_requisite.html",
      fuel_rate: fuel_rate,
      clients: clients,
      rejected_requisite: rejected_requisite,
      users: users,
      section: section,
      refuel_type: refuel_type,
      batch_no: params["batch_no"],
      batch_id: params["batch_id"],
      loco_driver: loco_driver,
      locomotive_type: locomotive_type,
      locomotive: locomotive,
      stations: stations,
      commodity: commodity,
      stations: stations,
      tariff_line: tariff_line,
      wagons: wagons,
      train_type: train_type,
      railway_administrator: railway_administrator
    )
  end

  def rejected_requisite_details(conn, params) do
    user = conn.assigns.user
    batch_items = Order.list_fuel_monitoring_batch_items(params["id"])
    rejected_requisite = Rms.Order.all_fuel_pending_monitoring(params["id"], "REJECTED", user)
    loco_driver = Accounts.get_loco_driver_data()
    refuel_type = SystemUtilities.list_tbl_refueling_type()
    fuel_rate = SystemUtilities.list_tbl_fuel_rates()
    wagons = SystemUtilities.list_tbl_wagon()
    clients = Accounts.list_tbl_clients()
    users = Accounts.list_tbl_users()
    section = SystemUtilities.list_tbl_section()
    tariff_line = SystemUtilities.list_tbl_tariff_line()
    stations = SystemUtilities.list_tbl_station()
    commodity = SystemUtilities.list_tbl_commodity()
    railway_administrator = Accounts.list_tbl_railway_administrator()
    locomotive_type = Locomotives.list_tbl_locomotive_type()
    locomotive = Locomotives.list_tbl_locomotive()
    train_type = SystemUtilities.list_tbl_train_type()

    render(conn, "rejected_fuel_requisite_form.html",
      fuel_rate: fuel_rate,
      clients: clients,
      batch_items: batch_items,
      section: section,
      rejected_requisite: rejected_requisite,
      users: users,
      refuel_type: refuel_type,
      batch_no: params["batch_no"],
      batch_id: params["batch_id"],
      loco_driver: loco_driver,
      locomotive_type: locomotive_type,
      locomotive: locomotive,
      stations: stations,
      commodity: commodity,
      stations: stations,
      tariff_line: tariff_line,
      wagons: wagons,
      train_type: train_type,
      railway_administrator: railway_administrator
    )
  end

  def fuel_requisite_table(conn, params) do
    fuel = Rms.Order.get_complete_fuel_requisite()
    loco_driver = Accounts.get_loco_driver_data()
    fuel_rate = SystemUtilities.list_tbl_fuel_rates()
    wagons = SystemUtilities.list_tbl_wagon()
    clients = Accounts.list_tbl_clients()
    users = Accounts.list_tbl_users()
    tariff_line = SystemUtilities.list_tbl_tariff_line()
    stations = SystemUtilities.list_tbl_station()
    commodity = SystemUtilities.list_tbl_commodity()
    railway_administrator = Accounts.list_tbl_railway_administrator()
    locomotive_type = Locomotives.list_tbl_locomotive_type()
    locomotive = Locomotives.list_tbl_locomotive()
    train_type = SystemUtilities.list_tbl_train_type()
    section = SystemUtilities.list_tbl_section()
    refuel_type = SystemUtilities.list_tbl_refueling_type()

    render(conn, "fuel_requisition_list.html",
      fuel_rate: fuel_rate,
      clients: clients,
      section: section,
      refuel_type: refuel_type,
      fuel: fuel,
      users: users,
      batch_no: params["batch_no"],
      batch_id: params["batch_id"],
      loco_driver: loco_driver,
      locomotive_type: locomotive_type,
      locomotive: locomotive,
      stations: stations,
      commodity: commodity,
      stations: stations,
      tariff_line: tariff_line,
      wagons: wagons,
      train_type: train_type,
      railway_administrator: railway_administrator
    )
  end

  def fuel_report_entries(conn, params) do
    user = conn.assigns.user
    batch_items = Order.list_fuel_monitoring_batch_items(params["id"])
    fuel = Rms.Order.all_fuel_pending_monitoring(params["id"], "COMPLETE", user)
    loco_driver = Accounts.get_loco_driver_data()
    refuel_type = SystemUtilities.list_tbl_refueling_type()
    fuel_rate = SystemUtilities.list_tbl_fuel_rates()
    wagons = SystemUtilities.list_tbl_wagon()
    clients = Accounts.list_tbl_clients()
    users = Accounts.list_tbl_users()
    tariff_line = SystemUtilities.list_tbl_tariff_line()
    stations = SystemUtilities.list_tbl_station()
    commodity = SystemUtilities.list_tbl_commodity()
    railway_administrator = Accounts.list_tbl_railway_administrator()
    locomotive_type = Locomotives.list_tbl_locomotive_type()
    locomotive = Locomotives.list_tbl_locomotive()
    train_type = SystemUtilities.list_tbl_train_type()
    section = SystemUtilities.list_tbl_section()

    render(conn, "fuel_monitoring_report_entries.html",
      fuel_rate: fuel_rate,
      clients: clients,
      batch_items: batch_items,
      section: section,
      fuel: fuel,
      refuel_type: refuel_type,
      users: users,
      batch_no: params["batch_no"],
      batch_id: params["batch_id"],
      loco_driver: loco_driver,
      locomotive_type: locomotive_type,
      locomotive: locomotive,
      stations: stations,
      commodity: commodity,
      stations: stations,
      tariff_line: tariff_line,
      wagons: wagons,
      train_type: train_type,
      railway_administrator: railway_administrator
    )
  end

  def fuel_exco_report(conn, params) do
    # fuel_category = Rms.Order.get_fuel_monitor_by_date() |> Enum.group_by(&(&1.category))
    company = SystemUtilities.list_company_info()

    quarter =
      case params do
        %{"quarter" => _, "year" => _} -> String.to_integer(params["quarter"])
        _ -> Date.quarter_of_year(Timex.local())
      end

    year = params["year"] || Timex.local().year

    fuel_summary =
      quarter
      |> Rms.Order.get_fuel_monitor_by_date(year)
      |> format_summary()

    months = quarter_months(quarter, fuel_summary)
    month_names = Enum.sort_by(Map.keys(months), &Timex.month_to_num/1)
    total_consumed = handle_total_consumed(months, fuel_summary)
    fuel_rate = SystemUtilities.get_fuel_rate_by_date(quarter, year)
    distance = Rms.Order.get_fuel_monitor_by_date(quarter, year)
    tons = Rms.Order.lookup_tonnage(quarter, year)
    summary = handle_summary_totals(fuel_summary)

    {main_costs, total_payments, total_efficiency, main_efficiency} =
      calcu_fuel_costs(fuel_summary, fuel_rate, total_consumed, tons, month_names)

    render(conn, "exco_summery_report.html",
      months: month_names,
      main_refuel_costs: main_costs,
      total_payments: total_payments,
      total_consumed: total_consumed,
      total_efficiency: total_efficiency,
      main_efficiency: main_efficiency,
      fuel_rate: fuel_rate,
      ton_lookup: tons,
      distance: distance,
      fuel_summary: summary,
      year: year,
      quarter: quarter,
      company: company
    )
  end

  defp format_summary(summary) do
    summary
    |> Enum.group_by(& &1.category)
    |> Map.new(fn {key, vals} -> {key, Enum.group_by(vals, & &1.date)} end)
    |> Enum.into(%{}, fn {category, cat_vals} ->
      cat_vals =
        Enum.into(cat_vals, %{}, fn {month, month_vals} ->
          month_vals =
            Enum.group_by(month_vals, & &1.refuel_type)
            |> Enum.map(fn {_type, refuels} ->
              Enum.reduce(refuels, %{}, fn refuel, acc ->
                Map.merge(acc, refuel, fn k, v1, v2 ->
                  (k == :total_consumed && Decimal.add(v1, v2)) || v2
                end)
              end)
            end)

          {month, month_vals}
        end)

      {category, cat_vals}
    end)
  end

  defp quarter_months(quarter, _summary) do
    Enum.chunk_every(1..12, 3)
    |> Enum.at(quarter - 1)
    |> Enum.map(fn month_num -> {Timex.month_name(month_num), [%{total_consumed: 0}]} end)
    |> Enum.into(%{})
  end

  defp handle_summary_totals(summary) do
    Enum.map(summary, fn {group, vals} ->
      group_summary =
        Map.new(vals, fn {key, results} ->
          total =
            Enum.reduce(results, %{total: 0}, fn result, acc ->
              %{
                acc
                | total: Decimal.add(acc.total, result.monthly_total)
              }
            end)

          results = Enum.map(results, &Map.merge(&1, total))
          {key, results}
        end)

      {group, group_summary}
    end)
    |> Enum.into(%{})
  end

  defp handle_total_consumed(_quarter_months, summary) when map_size(summary) < 1, do: []

  defp handle_total_consumed(quarter_months, summary) do
    Enum.map(summary, fn {_category, vals} ->
      quarter_months
      |> Enum.reduce(%{}, fn {date, result}, acc ->
        cond do
          is_map_key(vals, date) ->
            acc

          true ->
            Map.put(acc, date, result)
        end
      end)
      |> Map.merge(vals)
      |> Map.to_list()
      |> Enum.sort_by(fn {month, _val} -> Timex.month_to_num(month) end)
      |> Enum.map(fn {_date, results} ->
        Enum.reduce(results, 0, &Decimal.add(&1.total_consumed, &2))
      end)
    end)
    |> Stream.zip()
    |> Enum.reduce([], fn
      {main_total, other_total}, acc ->
        acc ++ [Decimal.add(main_total, other_total)]

      _, acc ->
        acc ++ [0]
    end)
  end

  defp calcu_fuel_costs(fuel_summary, fuel_rates, total_consumed, tons, months) do
    main_refuels = fuel_summary["main"] || %{}

    main_costs =
      Enum.map(months, fn month ->
        total = Enum.reduce(main_refuels[month] || [], 0, &Decimal.add(&1.total_consumed, &2))

        rate =
          Enum.find_value(fuel_rates, 0, fn %{date: rate_month} = rate ->
            if rate_month == month, do: rate.fuel_avg
          end)

        Decimal.mult(total, rate)
      end)

    total_payments =
      Enum.with_index(months)
      |> Enum.map(fn
        {month, index} ->
          rate =
            Enum.find_value(fuel_rates, 0, fn %{date: rate_month} = rate ->
              if rate_month == month, do: rate.fuel_avg
            end)

          Decimal.mult(rate, Enum.at(total_consumed, index) || 0)

        _ ->
          0
      end)

    {total_efficiency, main_efficiency} =
      Enum.with_index(months)
      |> Enum.flat_map_reduce({[], []}, fn {month, index}, acc ->
        ton =
          Enum.find_value(tons, 0, fn %{date: ton_month} = ton ->
            if ton_month == month, do: ton.tonnages_per_km
          end)

        total_main =
          Enum.reduce(main_refuels[month] || [], 0, &Decimal.add(&1.total_consumed, &2))

        main_efficiency = (!Decimal.equal?(ton, 0) && Decimal.div(total_main, ton)) || ton

        total_efficiency =
          (!Decimal.equal?(ton, 0) && Decimal.div(Enum.at(total_consumed, index), ton)) || ton

        {total, main} = acc

        {[{total_efficiency, main_efficiency}],
         {total ++ [total_efficiency], main ++ [main_efficiency]}}
      end)
      |> elem(1)

    {main_costs, total_payments, total_efficiency, main_efficiency}
  end

  #################################### Weekly Report ##################################
  def weekly_fuel_report(conn, params) do
    # fuel_category = Rms.Order.get_fuel_monitor_by_date() |> Enum.group_by(&(&1.category))
    # user = conn.assigns.user
    company = SystemUtilities.list_company_info()

    month =
      case params do
        %{"month" => _, "year" => _} -> String.to_integer(params["month"])
        _ -> Timex.local().month
      end

    year = params["year"] || Timex.local().year

    fuel_summary =
      month
      |> Rms.Order.get_fuel_request_weekly(year)
      |> format_weekly_summary()

    weeks = monthly_weeks(month, year)
    week_no = Enum.sort(Map.keys(weeks), :asc)
    total_consumed = handle_weekly_total_consumed(weeks, fuel_summary)
    fuel_rate = SystemUtilities.get_weekly_fuel_request(month, year)
    distance = Rms.Order.get_fuel_request_weekly(month, year)

    comltive_dist =
      Enum.reduce(distance, 0, fn entry, sum -> sum + Decimal.to_float(entry.distance) end)

    tons = Rms.Order.lookup_weekly_tonnage(month, year)

    sect_consumption =
      month
      |> Rms.Order.get_consumption_by_routes(year)
      |> format_weekly_sec_consumption()

    mvt_exception = Rms.Order.get_mvt_exceptions(month, year)

    total_tonnages =
      Enum.reduce(tons, 0, fn entry, sum -> sum + Decimal.to_float(entry.tonnages) end)

    comltive_tonkm =
      Enum.reduce(tons, 0, fn entry, sum -> sum + Decimal.to_float(entry.tonnages_per_km) end)

    comltive_mvtrev =
      Enum.reduce(tons, 0, fn entry, sum -> sum + Decimal.to_float(entry.mvt_revenue) end)

    cmltive_empties =
      Enum.reduce(mvt_exception, 0, fn entry, sum ->
        sum + Decimal.to_float(entry.empty_wagons)
      end)

    summary = handle_weekly_summary_totals(fuel_summary)
    # handle_sec_weekly_totals(sect_consumption)
    section_summary = sect_consumption

    {main_costs, total_payments, total_efficiency, main_efficiency} =
      calcu_weekly_fuel_costs(fuel_summary, fuel_rate, total_consumed, tons, week_no)

    render(conn, "weekly_fuel_smry.html",
      weeks: week_no,
      main_refuel_costs: main_costs,
      total_payments: total_payments,
      sect_consumption: section_summary,
      total_consumed: total_consumed,
      total_efficiency: total_efficiency,
      main_efficiency: main_efficiency,
      fuel_rate: fuel_rate,
      ton_lookup: tons,
      mvt_exception: mvt_exception,
      distance: distance,
      fuel_summary: summary,
      month: month,
      year: year,
      total_tonnages: total_tonnages,
      comltive_tonkm: comltive_tonkm,
      comltive_dist: comltive_dist,
      comltive_mvtrev: comltive_mvtrev,
      cmltive_empties: cmltive_empties,
      # quarter: quarter,
      company: company
    )
  end

  defp format_weekly_summary(summary) do
    summary
    |> Enum.group_by(& &1.category)
    |> Map.new(fn {key, vals} -> {key, Enum.group_by(vals, & &1.date)} end)
    |> Enum.into(%{}, fn {category, cat_vals} ->
      cat_vals =
        Enum.into(cat_vals, %{}, fn {month, month_vals} ->
          month_vals =
            Enum.group_by(month_vals, & &1.refuel_type)
            |> Enum.map(fn {_type, refuels} ->
              Enum.reduce(refuels, %{}, fn refuel, acc ->
                Map.merge(acc, refuel, fn k, v1, v2 ->
                  (k == :total_consumed && Decimal.add(v1, v2)) || v2
                end)
              end)
            end)

          {month, month_vals}
        end)

      {category, cat_vals}
    end)
  end

  defp format_weekly_sec_consumption(summary) do
    summary
    |> Enum.group_by(& &1.section)
    |> Map.new(fn {key, vals} -> {key, Enum.group_by(vals, & &1.week_no)} end)
    |> Enum.into(%{}, fn {section, cat_vals} ->
      cat_vals =
        Enum.into(cat_vals, %{}, fn {week, week_vals} ->
          week_vals =
            Enum.group_by(week_vals, & &1.section)
            |> Enum.map(fn {_type, refuels} ->
              wk_entry =
                Enum.reduce(refuels, %{}, fn refuel, acc ->
                  Map.merge(acc, refuel, fn k, v1, v2 ->
                    (k == :total_consumed && Decimal.add(v1, v2)) || v2
                  end)
                end)

              efficiency = Decimal.div(wk_entry.litres, wk_entry.tonnages_per_km)
              Map.put(wk_entry, :efficiency, efficiency)
            end)

          {week, week_vals}
        end)

      {section, cat_vals}
    end)
    |> handle_sec_weekly_totals()
    |> weekly_totals()
  end

  defp weekly_totals(vals) do
    Enum.into(vals, %{}, fn {section, vals} ->
      total_ltrs =
        Enum.reduce(vals, 0, fn {_week, [%{litres: litres} | _]}, acc ->
          Decimal.add(litres, acc)
        end)

      avg_ltrs = Decimal.div(total_ltrs, map_size(vals))

      total_ton_km =
        Enum.reduce(vals, 0, fn {_week, [%{tonnages_per_km: ton_km} | _]}, acc ->
          Decimal.add(ton_km, acc)
        end)

      avg_ton_km = Decimal.div(total_ton_km, map_size(vals))
      efficiency = Decimal.div(total_ltrs, total_ton_km)

      vals =
        Map.merge(vals, %{
          "avg_ton_km" => avg_ton_km,
          "avg_ltrs" => avg_ltrs,
          "efficiency" => efficiency
        })

      {section, vals}
    end)
  end

  def monthly_weeks(month, year) do
    date_of_month =
      if 1 == byte_size(to_string(month)), do: "#{year}-0#{month}-01", else: "#{year}-#{month}-01"

    {:ok, date} = Timex.parse(date_of_month, "{YYYY}-{0M}-{D}")

    case Timex.days_in_month(date) <= 28 do
      true ->
        %{
          "Week 1" => [%{total_consumed: 0}],
          "Week 2" => [%{total_consumed: 0}],
          "Week 3" => [%{total_consumed: 0}],
          "Week 4" => [%{total_consumed: 0}]
        }

      _ ->
        %{
          "Week 1" => [%{total_consumed: 0}],
          "Week 2" => [%{total_consumed: 0}],
          "Week 3" => [%{total_consumed: 0}],
          "Week 4" => [%{total_consumed: 0}],
          "Week 5" => [%{total_consumed: 0}]
        }
    end
  end

  defp handle_weekly_summary_totals(summary) do
    Enum.map(summary, fn {group, vals} ->
      group_summary =
        Map.new(vals, fn {key, results} ->
          total =
            Enum.reduce(results, %{total: 0}, fn result, acc ->
              %{
                acc
                | total: Decimal.add(acc.total, result.monthly_total || 0)
              }
            end)

          results = Enum.map(results, &Map.merge(&1, total))
          {key, results}
        end)

      {group, group_summary}
    end)
    |> Enum.into(%{})
  end

  defp handle_sec_weekly_totals(summary) do
    Enum.map(summary, fn {group, vals} ->
      group_summary =
        Map.new(vals, fn {key, [week_val | _] = results} ->
          total =
            Enum.reduce(results, %{tonnages_per_km: 0, litres: 0}, fn
              %{litres: _litres} = result, acc ->
                %{
                  acc
                  | litres: Decimal.add(acc.litres, result.litres || 0),
                    tonnages_per_km: Decimal.add(acc.tonnages_per_km, result.tonnages_per_km || 0)
                }

              _result, acc ->
                acc
            end)

          results = List.wrap(Map.merge(week_val, total))
          {key, results}
        end)

      {group, group_summary}
    end)
    |> Enum.into(%{})
  end

  defp handle_weekly_total_consumed(_monthly_weeks, summary) when map_size(summary) < 1, do: []

  defp handle_weekly_total_consumed(monthly_weeks, summary) do
    Enum.map(summary, fn {_category, vals} ->
      monthly_weeks
      |> Enum.reduce(%{}, fn {date, result}, acc ->
        cond do
          is_map_key(vals, date) ->
            acc

          true ->
            Map.put(acc, date, result)
        end
      end)
      |> Map.merge(vals)
      # |> Map.to_list
      |> Enum.sort(:asc)
      |> Enum.map(fn {_date, results} ->
        Enum.reduce(results, 0, &Decimal.add(&1.total_consumed || 0, &2))
      end)
    end)
    |> Stream.zip()
    |> Enum.reduce([], fn
      {main_total, other_total}, acc ->
        acc ++ [Decimal.add(main_total, other_total)]

      _, acc ->
        acc ++ [0]
    end)
  end

  defp calcu_weekly_fuel_costs(fuel_summary, fuel_rates, total_consumed, tons, weeks) do
    main_refuels = fuel_summary["main"] || %{}

    main_costs =
      Enum.map(weeks, fn month ->
        total =
          Enum.reduce(main_refuels[month] || [], 0, &Decimal.add(&1.total_consumed || 0, &2))

        rate =
          Enum.find_value(fuel_rates, 0, fn %{date: rate_month} = rate ->
            if rate_month == month, do: rate.fuel_avg
          end)

        Decimal.mult(total, rate)
      end)

    total_payments =
      Enum.with_index(weeks)
      |> Enum.map(fn
        {month, index} ->
          rate =
            Enum.find_value(fuel_rates, 0, fn %{date: rate_month} = rate ->
              if rate_month == month, do: rate.fuel_avg
            end)

          Decimal.mult(rate, Enum.at(total_consumed, index) || 0)

        _ ->
          0
      end)

    {total_efficiency, main_efficiency} =
      Enum.with_index(weeks)
      |> Enum.flat_map_reduce({[], []}, fn {month, index}, acc ->
        ton =
          Enum.find_value(tons, 0, fn %{date: ton_month} = ton ->
            if ton_month == month, do: ton.tonnages_per_km
          end)

        total_main =
          Enum.reduce(main_refuels[month] || [], 0, &Decimal.add(&1.total_consumed || 0, &2))

        main_efficiency = (!Decimal.equal?(ton, 0) && Decimal.div(total_main, ton)) || ton

        total_efficiency =
          (!Decimal.equal?(ton, 0) && Decimal.div(Enum.at(total_consumed, index), ton)) || ton

        {total, main} = acc

        {[{total_efficiency, main_efficiency}],
         {total ++ [total_efficiency], main ++ [main_efficiency]}}
      end)
      |> elem(1)

    {main_costs, total_payments, total_efficiency, main_efficiency}
  end

  def weekly_fuel_smry_report_pdf(
        conn,
        %{"month" => _month, "year" => _year, "weeks" => _weeks} = _params
      ) do
    # user = conn.assigns.user
    # entries = Rms.Order.get_fuel_request_weekly(month, year)
    # IO.inspect(month, label: "PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP")
    # content = Rms.Workers.WeeklyFuelSummaryReport.generate(entries, month, year, weeks, params)

    conn =
      conn
      |> put_resp_header(
        "content-disposition",
        "attachment; filename=fuel_weekly_smry_report_#{Timex.today()}.pdf"
      )
      |> put_resp_content_type("text/pdf")

    send_resp(conn, 200, "")
  end

  #################### depo period report ###################################
  # def depo_period_report(conn, params) do
  #   # fuel_category = Rms.Order.get_fuel_monitor_by_date() |> Enum.group_by(&(&1.category))
  #   company = SystemUtilities.list_company_info()

  #   quarter =
  #     case params do
  #       %{"quarter" => _, "year" => _} -> String.to_integer(params["quarter"])
  #       _ -> Date.quarter_of_year(Timex.local())
  #     end

  #   year = params["year"] || Timex.local().year

  #   fuel_summary =
  #     quarter
  #     |> Rms.Order.get_refuel_depo_by_month(year)
  #     |> format_depo_summary()

  #   months = quarter_period_months(quarter, fuel_summary)
  #   month_names = Enum.sort_by(Map.keys(months), &Timex.month_to_num/1)
  #   fuel_consumed = handle_period_total_consumed(months, fuel_summary)
  #   fuel_rate = SystemUtilities.get_fuel_rate_by_date(quarter, year)
  #   distance = Rms.Order.get_refuel_depo_by_month(quarter, year)
  #   tons = Rms.Order.monthly_tonnage_lookup(quarter, year)
  #   summary = handle_depo_summary_totals(fuel_summary)

  #   {main_costs, total_payments, total_efficiency, main_efficiency} =
  #     calculate_fuel_costs(fuel_summary, fuel_rate, fuel_consumed, tons, month_names)

  #   render(conn, "depo_period_report.html",
  #     months: month_names,
  #     main_refuel_costs: main_costs,
  #     total_payments: total_payments,
  #     fuel_consumed: fuel_consumed,
  #     total_efficiency: total_efficiency,
  #     main_efficiency: main_efficiency,
  #     fuel_rate: fuel_rate,
  #     ton_lookup: tons,
  #     distance: distance,
  #     fuel_summary: summary,
  #     year: year,
  #     quarter: quarter,
  #     company: company
  #   )
  # end

  # defp format_depo_summary(summary) do
  #   summary
  #   |> Enum.group_by(& &1.depo)
  #   |> Map.new(fn {key, vals} -> {key, Enum.group_by(vals, & &1.date)} end)
  #   |> Enum.into(%{}, fn {depo, cat_vals} ->
  #     cat_vals =
  #       Enum.into(cat_vals, %{}, fn {month, month_vals} ->
  #         month_vals =
  #           Enum.group_by(month_vals, & &1.depo)
  #           |> Enum.map(fn {_type, refuels} ->
  #             Enum.reduce(refuels, %{}, fn refuel, acc ->
  #               Map.merge(acc, refuel, fn k, v1, v2 ->
  #                 (k == :fuel_consumed && Decimal.add(v1, v2)) || v2
  #               end)
  #             end)
  #           end)

  #         {month, month_vals}
  #       end)

  #     {depo, cat_vals}
  #   end)
  # end

  # defp quarter_period_months(quarter, _summary) do
  #   Enum.chunk_every(1..12, 3)
  #   |> Enum.at(quarter - 1)
  #   |> Enum.map(fn month_num -> {Timex.month_name(month_num), [%{fuel_consumed: 0}]} end)
  #   |> Enum.into(%{})
  # end

  # defp handle_depo_summary_totals(summary) do
  #   Enum.map(summary, fn {group, vals} ->
  #     group_summary =
  #       Map.new(vals, fn {key, results} ->
  #         total =
  #           Enum.reduce(results, %{total: 0}, fn result, acc ->
  #             %{
  #               acc
  #               | total: Decimal.add(acc.total, result.monthly_total)
  #             }
  #           end)

  #         results = Enum.map(results, &Map.merge(&1, total))
  #         {key, results}
  #       end)

  #     {group, group_summary}
  #   end)
  #   |> Enum.into(%{})
  # end

  # defp handle_period_total_consumed(_quarter_months, summary) when map_size(summary) < 1, do: []

  # defp handle_period_total_consumed(quarter_months, summary) do
  #   Enum.map(summary, fn {_category, vals} ->
  #     quarter_months
  #     |> Enum.reduce(%{}, fn {date, result}, acc ->
  #       cond do
  #         is_map_key(vals, date) ->
  #           acc

  #         true ->
  #           Map.put(acc, date, result)
  #       end
  #     end)
  #     |> Map.merge(vals)
  #     |> Map.to_list()
  #     |> Enum.sort_by(fn {month, _val} -> Timex.month_to_num(month) end)
  #     |> Enum.map(fn {_date, results} ->
  #       Enum.reduce(results, 0, &Decimal.add(&1.fuel_consumed, &2))
  #     end)
  #   end)
  #   |> Stream.zip()
  #   |> Enum.reduce([], fn
  #     {main_total, other_total}, acc ->
  #       acc ++ [Decimal.add(main_total, other_total)]

  #     _, acc ->
  #       acc ++ [0]
  #   end)
  # end

  # defp calculate_fuel_costs(fuel_summary, fuel_rates, fuel_consumed, tons, months) do
  #   main_refuels = fuel_summary["main"] || %{}

  #   main_costs =
  #     Enum.map(months, fn month ->
  #       total = Enum.reduce(main_refuels[month] || [], 0, &Decimal.add(&1.fuel_consumed, &2))

  #       rate =
  #         Enum.find_value(fuel_rates, 0, fn %{date: rate_month} = rate ->
  #           if rate_month == month, do: rate.fuel_avg
  #         end)

  #       Decimal.mult(total, rate)
  #     end)

  #   total_payments =
  #     Enum.with_index(months)
  #     |> Enum.map(fn
  #       {month, index} ->
  #         rate =
  #           Enum.find_value(fuel_rates, 0, fn %{date: rate_month} = rate ->
  #             if rate_month == month, do: rate.fuel_avg
  #           end)

  #         Decimal.mult(rate, Enum.at(fuel_consumed, index) || 0)

  #       _ ->
  #         0
  #     end)

  #   {total_efficiency, main_efficiency} =
  #     Enum.with_index(months)
  #     |> Enum.flat_map_reduce({[], []}, fn {month, index}, acc ->
  #       ton =
  #         Enum.find_value(tons, 0, fn %{date: ton_month} = ton ->
  #           if ton_month == month, do: ton.tonnages_per_km
  #         end)

  #       total_main = Enum.reduce(main_refuels[month] || [], 0, &Decimal.add(&1.fuel_consumed, &2))
  #       main_efficiency = (!Decimal.equal?(ton, 0) && Decimal.div(total_main, ton)) || ton

  #       total_efficiency =
  #         (!Decimal.equal?(ton, 0) && Decimal.div(Enum.at(fuel_consumed, index), ton)) || ton

  #       {total, main} = acc

  #       {[{total_efficiency, main_efficiency}],
  #        {total ++ [total_efficiency], main ++ [main_efficiency]}}
  #     end)
  #     |> elem(1)

  #   {main_costs, total_payments, total_efficiency, main_efficiency}
  # end

  ###########################################################################

  def section_summary_report(conn, params) do
    user = conn.assigns.user
    company = SystemUtilities.list_company_info()
    start_dt = params["start_date"] || Timex.today() |> to_string()
    end_dt = params["end_date"] || Timex.today() |> to_string()

    section_summary =
      SystemUtilities.get_by_section(start_dt, end_dt, user) |> Enum.group_by(& &1.section)

    total_cost =
      Enum.reduce(section_summary, 0, fn {_key, results}, acc ->
        acc + Enum.reduce(results, 0, &(Decimal.to_float(&1.total_cost) + &2))
      end)

    total_refuel =
      Enum.reduce(section_summary, 0, fn {_key, results}, acc ->
        acc + Enum.reduce(results, 0, &(Decimal.to_float(&1.qty_refueled) + &2))
      end)

    summary = handle_weekly_totals(section_summary)

    render(conn, "section_summary_report.html",
      total_refuel: total_refuel,
      section_summary: summary,
      start_date: start_dt,
      end_date: end_dt,
      company: company,
      total_cost: total_cost
    )
  end

  defp handle_weekly_totals(summary) do
    _summary =
      Map.new(summary, fn {key, results} ->
        total =
          Enum.reduce(results, %{total_refuel: 0, total_cost: 0}, fn result, acc ->
            %{
              acc
              | total_refuel: Decimal.add(acc.total_refuel, result.qty_refueled),
                total_cost: Decimal.add(acc.total_cost, result.total_cost)
            }
          end)

        results = Enum.map(results, &Map.merge(&1, total))
        {key, results}
      end)
  end

  def section_summary_generate_pdf(conn, %{"start_dt" => start_dt, "end_dt" => end_dt}) do
    user = conn.assigns.user
    entries = SystemUtilities.get_by_section(start_dt, end_dt, user)
    content = Rms.Workers.FuelSectionSummary.generate(entries, start_dt, end_dt)

    conn =
      conn
      |> put_resp_header(
        "content-disposition",
        "attachment; filename=fuel_section_summary_#{Timex.today()}.pdf"
      )
      |> put_resp_content_type("text/pdf")

    send_resp(conn, 200, content)
  end

  def depo_summary_report(conn, params) do
    user = conn.assigns.user
    company = SystemUtilities.list_company_info()
    start_dt = params["start_date"] || Timex.today() |> to_string()
    end_dt = params["end_date"] || Timex.today() |> to_string()

    currency =
      SystemUtilities.list_tbl_currency()
      |> Enum.reject(&(&1.status != "A"))
      |> Enum.reject(&(&1.type != "LOCAL"))

    depo_summary =
      SystemUtilities.get_depo_summary(start_dt, end_dt, user) |> Enum.group_by(& &1.depo)

    total_refuels =
      Enum.reduce(depo_summary, 0, fn {_key, results}, acc ->
        acc + Enum.reduce(results, 0, &(&1.count + &2))
      end)

    qty_refueled =
      Enum.reduce(depo_summary, 0, fn {_key, results}, acc ->
        acc + Enum.reduce(results, 0, &(Decimal.to_float(&1.qty_refueled) + &2))
      end)

    total_cost =
      Enum.reduce(depo_summary, 0, fn {_key, results}, acc ->
        acc + Enum.reduce(results, 0, &(Decimal.to_float(&1.total_cost) + &2))
      end)

    render(conn, "depo_summary_report.html",
      start_date: start_dt,
      end_date: end_dt,
      currency: currency,
      total_cost: total_cost,
      qty_refueled: qty_refueled,
      depo_summary: depo_summary,
      total_refuels: total_refuels,
      company: company
    )
  end

  def load_depo_report(conn, params),
    do:
      json(conn, %{
        "data" =>
          List.wrap(
            Rms.SystemUtilities.get_depo_summary(
              params["start_date"],
              params["end_date"],
              conn.assigns.user
            )
          )
      })

  def depo_summary_generate_pdf(conn, %{"start_dt" => start_dt, "end_dt" => end_dt}) do
    user = conn.assigns.user
    entries = SystemUtilities.get_depo_summary(start_dt, end_dt, user)
    content = Rms.Workers.DepoSummary.generate(entries, start_dt, end_dt)

    conn =
      conn
      |> put_resp_header(
        "content-disposition",
        "attachment; filename=depo_summary_#{Timex.today()}.pdf"
      )
      |> put_resp_content_type("text/pdf")

    send_resp(conn, 200, content)
  end

  def submit_fuel_request(conn, %{"entries" => params, "batch_id" => id}) do
    param = params |> Enum.at(0)
    {"0", new_params} = param

    new_date = Date.from_iso8601!(new_params["date"])

    conn.assigns.user
    |> handle_submit(params, new_date)
    |> Repo.transaction()
    |> case do
      {:ok, _} ->
        json(conn, %{"info" => "sucesss"})
        Rms.Order.update_batch(Rms.Order.get_batch!(id), %{status: "C"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        json(conn, %{"error" => "#{reason}"})
    end
  end

  defp handle_submit(user, params, new_date) do
    items = Map.values(params)

    week_number = to_string(Timex.week_of_month(new_date))

    Enum.with_index(items, 1)
    |> Enum.map(fn {item, index} ->
      entry =
        if(to_string(item["id"]) == "",
          do: %FuelMonitoring{maker_id: user.id, user_station_id: user.station_id},
          else: Rms.Order.get_fuel_monitoring!(item["id"])
        )

      Ecto.Multi.new()
      |> Ecto.Multi.insert_or_update(
        {:fuel_monitor, index},
        FuelMonitoring.changeset(
          entry,
          Map.merge(item, %{
            "status" => "PENDING_APPROVAL",
            "maker_id" => user.id,
            "week_no" => week_number
          })
        )
      )
      |> Ecto.Multi.insert(
        {:user_log, index},
        UserLog.changeset(%UserLog{}, %{
          user_id: user.id,
          activity:
            "Created fuel requisite order on requisite number: \"#{item["requisition_no"]}\""
        })
      )
    end)
    |> Enum.reduce(Ecto.Multi.new(), &Ecto.Multi.append/2)
  end

  def control_submit_fuel_request(
        conn,
        %{"requisition_no" => requisition_no, "entries" => params}
      ) do
    items = Rms.Order.get_fuel_by_batch_id(requisition_no)
    user = conn.assigns.user

    handle_update(user, items, Map.put(params, "checker_id", user.id))
    |> Repo.transaction()
    |> case do
      {:ok, %{update: _update, insert: _insert}} ->
        json(conn, %{"info" => "Changes applied successfully!"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        json(conn, %{"error" => reason})
    end
  end

  defp handle_update(user, items, params) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:update, FuelMonitoring.changeset(items, params))
    |> Ecto.Multi.run(:insert, fn repo, %{update: update} ->
      activity = "Updated items \"#{update.requisition_no}\""

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  def submit_form_approval(conn, %{"entries" => params, "batch_id" => id, "status" => status}) do
    conn.assigns.user
    |> handle_submit_approval(params, status)
    |> Repo.transaction()
    |> case do
      {:ok, _} ->
        json(conn, %{"info" => "sucesss"})
        Rms.Order.update_batch(Rms.Order.get_batch!(id), %{status: "C"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        json(conn, %{"error" => "#{reason}"})
    end
  end

  defp handle_submit_approval(user, params, status) do
    items = Map.values(params)

    Enum.with_index(items, 1)
    |> Enum.map(fn {item, index} ->
      entry =
        if(to_string(item["id"]) == "", do: %FuelMonitoring{maker_id: user.id}, else: Rms.Order.get_fuel_monitoring!(item["id"]))

      Ecto.Multi.new()
      |> Ecto.Multi.insert_or_update(
        {:fuel_monitor, index},
        FuelMonitoring.changeset(entry, Map.merge(item, %{"status" => status, maker_id: user.id}))
      )
      |> Ecto.Multi.insert(
        {:user_log, index},
        UserLog.changeset(%UserLog{}, %{
          user_id: user.id,
          activity:
            "submitted fuel requisite order for approval on requisite number: \"#{item["requisition_no"]}\""
        })
      )
    end)
    |> Enum.reduce(Ecto.Multi.new(), &Ecto.Multi.append/2)
  end

  def reject_fuel_requisite(conn, %{
        "requisition_no" => requisition_no,
        "status" => status,
        "reason" => reason
      }) do
    items = Rms.Order.get_fuel_by_batch_id(requisition_no)

    conn.assigns.user
    |> handle_reject_requisite(items, status, reason)
    |> Repo.transaction()
    |> case do
      {:ok, _} ->
        json(conn, %{"info" => "sucesss"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        json(conn, %{"error" => "#{reason}"})
    end
  end

  defp handle_reject_requisite(user, items, status, reason) do
    Enum.with_index(items, 1)
    |> Enum.map(fn {item, index} ->
      Ecto.Multi.new()
      |> Ecto.Multi.update(
        {:fuel_monitor, index},
        FuelMonitoring.changeset(item, %{
          "status" => status,
          "checker_id" => user.id,
          "comment" => reason
        })
      )
      |> Ecto.Multi.insert(
        {:user_log, index},
        UserLog.changeset(%UserLog{}, %{
          user_id: user.id,
          activity: "Rejected fuel requisite on Requisite number: \"#{item.requisition_no}\""
        })
      )
    end)
    |> Enum.reduce(Ecto.Multi.new(), &Ecto.Multi.append/2)
  end

  def approve_fuel_requisite(conn, %{"requisition_no" => requisition_no, "status" => status}) do
    items = Rms.Order.get_fuel_by_batch_id(requisition_no)

    conn.assigns.user
    |> handle_approve_requisite(items, status)
    |> Repo.transaction()
    |> case do
      {:ok, _} ->
        json(conn, %{"info" => "sucesss"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        json(conn, %{"error" => "#{reason}"})
    end
  end

  defp handle_approve_requisite(user, items, status) do
    Enum.with_index(items, 1)
    |> Enum.map(fn {item, index} ->
      Ecto.Multi.new()
      |> Ecto.Multi.update(
        {:fuel_monitor, index},
        FuelMonitoring.changeset(item, %{"status" => status, "checker_id" => user.id})
      )
      |> Ecto.Multi.insert(
        {:user_log, index},
        UserLog.changeset(%UserLog{}, %{
          user_id: user.id,
          activity: "Approved requisite \" to #{item.requisition_no}\" "
        })
      )
    end)
    |> Enum.reduce(Ecto.Multi.new(), &Ecto.Multi.append/2)
  end

  # def display_fuel_monitoring_details(conn, %{"batch_id" => batch_id}) do
  #   batch_items = Order.all_fuel_monitoring_entries(batch_id)
  #   json(conn, %{"data" => List.wrap(batch_items)})
  # end

  def update_fuel_request(conn, %{"requisition_no" => requisition_no, "current_status" => current_status} = params) do
    items = Order.get_fuel_request_by_requisition_no(requisition_no, current_status)

    conn.assigns.user
    |> handle_update_fuel_request(params, items)
    |> Repo.transaction()
    |> case do
      {:ok, _} ->
        json(conn, %{"info" => "sucesss"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        json(conn, %{"error" => "#{reason}"})
    end
  end

  defp handle_update_fuel_request(user, params, items) do
    Enum.with_index(items, 1)
    |> Enum.map(fn {item, index} ->
      Ecto.Multi.new()
      |> Ecto.Multi.update(
        {:fuel_monitor, index},
        FuelMonitoring.changeset(item, prepare_fuel_request_upadte_params(params))
      )
      |> Ecto.Multi.insert(
        {:user_log, index},
        UserLog.changeset(%UserLog{}, %{
          user_id: user.id,
          activity: "Created fuel requisite order on requisite number:"
        })
      )
    end)
    |> Enum.reduce(Ecto.Multi.new(), &Ecto.Multi.append/2)
  end

  defp prepare_fuel_request_upadte_params(params) do
    case params["current_status"] do
      "PENDING_CONTROL" ->
        %{
          status: "PENDING_COMPLETION",
          approved_refuel: params["approved_refuel"],
          fuel_blc_figures: params["fuel_blc_figures"],
          ctc_datestamp: params["ctc_datestamp"],
          ctc_time: params["ctc_time"],
          fuel_blc_words: params["fuel_blc_words"],
          comment: params["comment"],
          litres_in_words: params["litres_in_words"]
        }

      "PENDING_COMPLETION" ->
        %{
          status: "PENDING_APPROVAL",
          reading_after_refuel: params["reading_after_refuel"],
          seal_color_at_depture: params["seal_color_at_depture"],
          seal_number_at_depture: params["seal_number_at_depture"],
          bp_meter_after: params["bp_meter_after"],
          date: params["date"],
          time: params["time"],
          total_cost: params["total_cost"],
          quantity_refueled: params["quantity_refueled"],
          meter_at_destin: params["meter_at_destin"],
          reading: params["reading"],
          fuel_consumed: params["fuel_consumed"],
          deff_ctc_actual: params["deff_ctc_actual"],
          km_to_destin: params["km_to_destin"],
          consumption_per_km: params["consumption_per_km"],
          refuel_type: params["refuel_type"],
          Section_id: params["Section_id"]
        }

      "REJECTED" ->
        %{
          status: "PENDING_APPROVAL",
          reading_after_refuel: params["reading_after_refuel"],
          seal_color_at_depture: params["seal_color_at_depture"],
          seal_number_at_depture: params["seal_number_at_depture"],
          bp_meter_after: params["bp_meter_after"],
          date: params["date"],
          time: params["time"],
          total_cost: params["total_cost"],
          loco_no: params["loco_no"],
          train_number: params["train_number"],
          seal_number_at_arrival: params["seal_number_at_arrival"],
          seal_color_at_arrival: params["seal_color_at_arrival"],
          deff_ctc_actual: params["deff_ctc_actual"],
          bp_meter_before: params["bp_meter_before"],
          km_to_destin: params["km_to_destin"],
          section: params["section"],
          comment: params["comment"],
          locomotive_driver_id: params["locomotive_driver_id"],
          train_type_id: params["train_type_id"],
          commercial_clerk_id: params["commercial_clerk_id"],
          depo_refueled_id: params["depo_refueled_id"],
          train_destination_id: params["train_destination_id"],
          yard_master_id: params["yard_master_id"],
          oil_rep_name: params["oil_rep_name"],
          asset_protection_officers_name: params["asset_protection_officers_name"],
          other_refuel: params["other_instrument"],
          other_refuel_no: params["other_refuel_no"],
          refuel_type: params["refuel_type"],
          Section_id: params["Section_id"],
          shunt: params["shunt"],
          driver_name: params["driver_name"],
          commercial_clk_name: params["commercial_clk_name"],
          yard_master_name: params["yard_master_name"],
          controllers_name: params["controllers_name"]
        }

        "PENDING_APPROVAL" ->
          %{
            status: "COMPLETE",
            reading_after_refuel: params["reading_after_refuel"],
            seal_color_at_depture: params["seal_color_at_depture"],
            seal_number_at_depture: params["seal_number_at_depture"],
            bp_meter_after: params["bp_meter_after"],
            date: params["date"],
            time: params["time"],
            total_cost: params["total_cost"],
            loco_no: params["loco_no"],
            train_number: params["train_number"],
            seal_number_at_arrival: params["seal_number_at_arrival"],
            seal_color_at_arrival: params["seal_color_at_arrival"],
            deff_ctc_actual: params["deff_ctc_actual"],
            bp_meter_before: params["bp_meter_before"],
            km_to_destin: params["km_to_destin"],
            section: params["section"],
            comment: params["comment"],
            locomotive_driver_id: params["locomotive_driver_id"],
            train_type_id: params["train_type_id"],
            commercial_clerk_id: params["commercial_clerk_id"],
            depo_refueled_id: params["depo_refueled_id"],
            train_destination_id: params["train_destination_id"],
            yard_master_id: params["yard_master_id"],
            oil_rep_name: params["oil_rep_name"],
            asset_protection_officers_name: params["asset_protection_officers_name"],
            other_refuel: params["other_instrument"],
            other_refuel_no: params["other_refuel_no"],
            refuel_type: params["refuel_type"],
            Section_id: params["Section_id"],
            shunt: params["shunt"]
          }

      _ ->
        %{}
    end
  end

  def fuel_req_excel_exp(conn, params) do
    entries = process_report(conn, @current, params)
    user = conn.assigns.user

    conn
    |> put_resp_content_type("text/xlsx")
    |> put_resp_header(
      "content-disposition",
      "attachment; filename=FUEL_REQUISITE_REPORT_#{Timex.today()}.xlsx"
    )
    |> render("report.xlsx", %{entries: entries, user: user, report_type: ""})
  end

  defp process_report(conn, source, params) do
    params
    |> Map.delete("_csrf_token")
    |> report_generator(source, conn.assigns.user)
    |> Repo.all()
  end

  def report_generator(search_params, source, user) do
    # unmatched_period = SystemUtilities.list_company_info().unmatched_aging_period
    Rms.Order.fuel_report_lookup(source, Map.put(search_params, "isearch", ""), user)
  end

  def traverse_errors(errors) do
    for {key, {msg, _opts}} <- errors, do: "#{key} #{msg}"
  end

  def prepare_fuel_batch(user) do
    %{
      "trans_date" => to_string(Timex.today()),
      "batch_type" => "FUEL_REQUEST",
      "value_date" => Timex.format!(Timex.today(), "%Y%m%d", :strftime),
      "current_user_id" => user.id,
      "last_user_id" => user.id,
      "uuid" => Ecto.UUID.generate()
    }
  end

  def fuel_requisite_report_lookup(conn, params) do
    {draw, start, length, search_params} = InterchangeController.search_options(params)

    results = Rms.Order.fuel_report_lookup(search_params, start, length, conn.assigns.user)

    total_entries = InterchangeController.total_entries(results)

    results = %{
      draw: draw,
      recordsTotal: total_entries,
      recordsFiltered: total_entries,
      data: InterchangeController.entries(results)
    }

    json(conn, results)
  end

  def lookup_fuel_rate(conn, %{"station_id" => station_id, "month" => month}) do
    rate = Rms.SystemUtilities.lookup_fuel_rate(station_id, month)
    json(conn, %{"data" => List.wrap(rate)})
  end

  # def lookup_loco_type(conn, %{"loco_number" => loco_number}) do
  #   type = Rms.Locomotives.lookup_loco_type(loco_number)
  #   json(conn, %{"data" => List.wrap(type)})
  # end

  def authorize(conn) do
    case Phoenix.Controller.action_name(conn) do
      act when act in ~w(approve_fuel_requisite)a ->
        {:fuel_monitoring, :approve_fuel_requisite}

      act
      when act in ~w(back_office_fuel_approval back_office_form_details backoffice_edit_requiste reject_fuel_requisite)a ->
        {:fuel_monitoring, :back_office_fuel_approval}

      act when act in ~w(control_fuel_verification approver_view_fuel_form)a ->
        {:fuel_monitoring, :control_fuel_verification}

      act when act in ~w(depo_summary_report)a ->
        {:fuel_monitoring, :depo_summary_report}

      act when act in ~w(fuel_exco_report)a ->
        {:fuel_monitoring, :fuel_exco_report}

      act when act in ~w(fuel_order submit_fuel_request fuel_monitoring)a ->
        {:fuel_monitoring, :fuel_order}

      act
      when act in ~w(fuel_requisite_table fuel_requisite_report_lookup fuel_req_excel_exp display_requisiste_details fuel_report_entries rejected_requisite_table rejected_requisite_details weekly_fuel_report depo_period_report)a ->
        {:fuel_monitoring, :fuel_requisite_table}

      act when act in ~w(weekly_fuel_report weekly_fuel_smry_report_pdf)a ->
        {:fuel_monitoring, :weekly_fuel_report}

      act when act in ~w(back_office_fuel_approval back_office_form_details backoffice_edit_requiste)a ->
        {:fuel_monitoring, :back_office_fuel_approval}

      act when act in ~w(control_fuel_verification approver_view_fuel_form)a ->
        {:fuel_monitoring, :control_fuel_verification}

      act when act in ~w(depo_summary_report depo_summary_generate_pdf)a ->
        {:fuel_monitoring, :depo_summary_report}

      act when act in ~w(fuel_exco_report)a ->
        {:fuel_monitoring, :fuel_exco_report}

      act when act in ~w(fuel_order fuel_monitoring submit_fuel_request)a ->
        {:fuel_monitoring, :fuel_order}

      act
      when act in ~w(fuel_requisite_table fuel_requisite_report_lookup display_requisiste_details fuel_report_entries)a ->
        {:fuel_monitoring, :fuel_requisite_table}

      act when act in ~w(section_summary_report section_summary_generate_pdf)a ->
        {:fuel_monitoring, :section_summary_report}

      act when act in ~w(update_fuel_request update_edited_fuel_request)a ->
        {:fuel_monitoring, :update_fuel_request}

      act when act in ~w(pending_completion_entries view_completion_form)a ->
        {:fuel_monitoring, :pending_completion_entries}

      act when act in ~w(monthly_report)a ->
        {:fuel_monitoring, :monthly_report}

      _ ->
        {:fuel_monitoring, :unknown}
    end
  end
end
