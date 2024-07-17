defmodule RmsWeb.MovementController do
  use RmsWeb, :controller

  alias Rms.SystemUtilities
  alias Rms.Accounts
  alias Rms.SystemUtilities
  alias Rms.Locomotives
  alias Rms.Order.WorksOrders
  alias Rms.Activity.UserLog
  alias Rms.Repo
  alias Rms.Order
  alias Rms.Order.Movement
  alias Rms.Tracking.WagonTracking
  alias Rms.SystemUtilities.Wagon
  alias RmsWeb.UserController
  alias RmsWeb.InterchangeController
  alias Rms.Order.Batch

  @current "tbl_movement"

  plug(
    RmsWeb.Plugs.RequireAuth
    when action not in [:unknown]
  )

  plug(
    RmsWeb.Plugs.EnforcePasswordPolicy
    when action not in [:unknown]
  )

  plug RmsWeb.Plugs.Authenticate,
       [module_callback: &RmsWeb.MovementController.authorize/1]
       when action not in [
          :search_station,
          :search_loco_number,
          :movement_batch_entries_lookup,
          :movement_report_lookup,
          :movement_draft_entries,
          :movement_pending_approval,
          :movement_pending_entries,
          :works_order_pdf,
          :movement_pending_entries,
          :works_order_pdf,
          :invoice_lookup
        ]

  def movement(conn, _params) do
    stations = SystemUtilities.list_tbl_station() |> Enum.reject(&(&1.status != "A"))
    wagons = SystemUtilities.list_tbl_wagon() |> Enum.reject(&(&1.status != "A"))
    clients = Accounts.list_tbl_clients() |> Enum.reject(&(&1.status != "A"))
    commodity = SystemUtilities.list_tbl_commodity() |> Enum.reject(&(&1.status != "A"))
    loco = Locomotives.list_tbl_locomotive() |> Enum.reject(&(&1.status != "A"))

    render(conn, "movement.html",
      stations: stations,
      wagons: wagons,
      clients: clients,
      commodity: commodity,
      loco: loco
    )
  end

  def create_movement(conn, %{"entries" => params, "loco_no" => loco_no}) do
    conn.assigns.user
    |> handle_create(params, loco_no)
    |> Repo.transaction()
    |> case do
      {:ok, _} ->
        json(conn, %{"info" => "sucesss"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        json(conn, %{"error" => "#{reason}"})
    end
  end

  defp handle_create(user, params, loco_no) do
    items = Map.values(params) |> Enum.reject(&(&1["wagon_id"] == nil))

    Enum.with_index(items, 1)
    |> Enum.map(fn {item, index} ->
      entry =
        if(to_string(item["id"]) == "",
          do: %Movement{maker_id: user.id},
          else: Rms.Order.get_movement!(item["id"])
        )

      loco_no = Poison.encode!(loco_no)

      Ecto.Multi.new()
      |> Ecto.Multi.insert_or_update(
        {:movement, index},
        Movement.changeset(entry, Map.merge(item, %{"loco_no" => loco_no}))
      )
      |> Ecto.Multi.insert(
        {:user_log, index},
        UserLog.changeset(%UserLog{}, %{
          user_id: user.id,
          activity: "Created movement train list No. : \"#{item["train_list_no"]}\""
        })
      )
    end)
    |> Enum.reduce(Ecto.Multi.new(), &Ecto.Multi.append/2)
  end


  def submit_movement(conn, %{"entries" => params, "batch_id" => batch_id, "loco_no" => loco_no}) do
    conn.assigns.user
    |> handle_submit(params, loco_no, batch_id)
    |> Repo.transaction()
    |> case do
      {:ok, _} ->
        # Rms.Order.update_batch(Rms.Order.get_batch!(batch_id), %{status: "C"})
        json(conn, %{"info" => "sucesss"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        json(conn, %{"error" => "#{reason}"})
    end
  end

  def submit_movement(conn, %{"entries" => params, "batch_id" => id}) do
    conn.assigns.user
    |> handle_submit_draft(params)
    |> Repo.transaction()
    |> case do
      {:ok, _} ->
        Rms.Order.update_batch(Rms.Order.get_batch!(id), %{status: "C"})
        json(conn, %{"info" => "sucesss"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        json(conn, %{"error" => "#{reason}"})
    end
  end

  defp handle_submit_draft(user, params) do
    items = Map.values(params) |> Enum.reject(&(&1["wagon_id"] == nil))

    Enum.with_index(items, 1)
    |> Enum.map(fn {item, index} ->
      entry =
        if(to_string(item["id"]) == "",
          do: %Movement{maker_id: user.id},
          else: Rms.Order.get_movement!(item["id"])
        )

      Ecto.Multi.new()
      |> Ecto.Multi.insert_or_update(
        {:movement, index},
        Movement.changeset(
          entry,
          Map.merge(item, %{"status" => "PENDING_VERIFICATION", "maker_id" => user.id})
        )
      )
      |> Ecto.Multi.insert(
        {:user_log, index},
        UserLog.changeset(%UserLog{}, %{
          user_id: user.id,
          activity: "Created movement train list No. : \"#{item["train_list_no"]}\""
        })
      )
    end)
    |> Enum.reduce(Ecto.Multi.new(), &Ecto.Multi.append/2)
  end

  defp handle_submit(user, params, loco_no, "") do
    items = Map.values(params) |> Enum.reject(&(&1["wagon_id"] == nil))
    {:ok, batch} = Order.create_batch(prepare_movement_batch(user))

      batch = Order.get_by_uuid(batch.uuid)
      # batch = Order.select_last_movement_batch(user.id) |> IO.inspect()

    Enum.with_index(items, 1)
    |> Enum.map(fn {item, index} ->
      loco_no = Poison.encode!(loco_no)
      item = %{item |
          "batch_id" => batch.id,
          "train_list_no" => batch.batch_no
        }

      entry =
        if(to_string(item["id"]) == "",
          do: %Movement{maker_id: user.id},
          else: Rms.Order.get_movement!(item["id"])
        )

      Ecto.Multi.new()
      |> Ecto.Multi.insert_or_update(
        {:movement, index},
        Movement.changeset(
          entry,
          Map.merge(item, %{
            "status" => "PENDING_VERIFICATION",
            "maker_id" => user.id,
            "loco_no" => loco_no
          })
        )
      )
      |> Ecto.Multi.insert(
        {:user_log, index},
        UserLog.changeset(%UserLog{}, %{
          user_id: user.id,
          activity: "Created movement train list No. : \"#{item["train_list_no"]}\""
        })
      )
    end)
    |> Enum.reduce(Ecto.Multi.new(), &Ecto.Multi.append/2)
    |> Ecto.Multi.update(:update_batch, Batch.changeset(batch, %{status: "C"}))
  end

  defp handle_submit(user, params, loco_no, batch_id) do
    items = Map.values(params) |> Enum.reject(&(&1["wagon_id"] == nil))
    {:ok, _batch} = Order.create_batch(prepare_movement_batch(user))

    batch = Rms.Order.get_batch!(batch_id)

    Enum.with_index(items, 1)
    |> Enum.map(fn {item, index} ->
      loco_no = Poison.encode!(loco_no)
      item = %{item |
          "batch_id" => batch.id,
          "train_list_no" => batch.batch_no
        }

      entry =
        if(to_string(item["id"]) == "",
          do: %Movement{maker_id: user.id},
          else: Rms.Order.get_movement!(item["id"])
        )

      Ecto.Multi.new()
      |> Ecto.Multi.insert_or_update(
        {:movement, index},
        Movement.changeset(
          entry,
          Map.merge(item, %{
            "status" => "PENDING_VERIFICATION",
            "maker_id" => user.id,
            "loco_no" => loco_no
          })
        )
      )
      |> Ecto.Multi.insert(
        {:user_log, index},
        UserLog.changeset(%UserLog{}, %{
          user_id: user.id,
          activity: "Created movement train list No. : \"#{item["train_list_no"]}\""
        })
      )
    end)
    |> Enum.reduce(Ecto.Multi.new(), &Ecto.Multi.append/2)
    |> Ecto.Multi.update(:update_batch, Batch.changeset(batch, %{status: "C"}))
  end

  def movement_draft(conn, _params) do
    user = conn.assigns.user
    data_entry_batches = Rms.Order.movement_draft_batches(user)
    render(conn, "movement_draft.html", data_entry_batches: data_entry_batches)
  end

  def rejected_movement(conn, _params) do
    user = conn.assigns.user
    data_entry_batches = Rms.Order.movement_rejected_batches(user)
    render(conn, "rejected_movement.html", data_entry_batches: data_entry_batches)
  end

  def movement_verification_batch(conn, _params) do
    user = conn.assigns.user
    batches = Rms.Order.movement_verification_batch_entries(user)
    render(conn, "movement_verification_batch.html", batches: batches)
  end

  def movement_intransit_batch(conn, _params) do
    user = conn.assigns.user
    batches = Rms.Order.movement_intransit_batch_entries(user, "INTRANSIT")
    render(conn, "movement_intransit_batch.html", batches: batches)
  end

  def movement_detached_batch(conn, _params) do
    user = conn.assigns.user
    batches = Rms.Order.movement_intransit_batch_entries(user, "DETACHED")
    render(conn, "movement_detacted_batch.html", batches: batches)
  end

  def movement_detached_entries(conn, params) do
    batch_items = Order.list_movement_batch_items(params["batch_id"])
    batch = Order.get_batch!(params["batch_id"])
    stations = Rms.SystemUtilities.list_tbl_station()
    wagons = Rms.SystemUtilities.list_tbl_wagon()
    clients = Rms.Accounts.list_tbl_clients()
    commodity = Rms.SystemUtilities.list_tbl_commodity()
    loco = Rms.Locomotives.list_tbl_locomotive()

    render(conn, "movement_detached_entries.html",
      batch_no: batch.batch_no,
      batch_id: params["batch_id"],
      batch_items: batch_items,
      stations: stations,
      wagons: wagons,
      clients: clients,
      commodity: commodity,
      loco: loco
    )
  end

  def movement_intransit_entries(conn, params) do
    batch_items = Order.list_movement_batch_items(params["batch_id"])
    batch = Order.get_batch!(params["batch_id"])
    stations = Rms.SystemUtilities.list_tbl_station()
    wagons = Rms.SystemUtilities.list_tbl_wagon()
    clients = Rms.Accounts.list_tbl_clients()
    commodity = Rms.SystemUtilities.list_tbl_commodity()
    loco = Rms.Locomotives.list_tbl_locomotive()

    render(conn, "movement_intransit_entries.html",
      batch_no: batch.batch_no,
      batch_id: params["batch_id"],
      batch_items: batch_items,
      stations: stations,
      wagons: wagons,
      clients: clients,
      commodity: commodity,
      loco: loco
    )
  end

  def intransit_train_attachment(conn, %{"train_no" => train_no}) do
    train = Order.intransit_train_lookup(train_no)

    clients = Accounts.list_tbl_clients() |> Enum.reject(&(&1.status != "A"))
    stations = SystemUtilities.list_tbl_station() |> Enum.reject(&(&1.status != "A"))
    commodity = SystemUtilities.list_tbl_commodity() |> Enum.reject(&(&1.status != "A"))

    render(conn, "intransit_train_attachment.html",
      train: train,
      stations: stations,
      clients: clients,
      commodity: commodity
    )
  end

  def train_attachment(conn, %{"train_no" => train_no} = params) do

    train = Order.intransit_train_lookup(train_no)

    conn.assigns.user
    |> handle_train_attachment(params, train)
    |> Repo.transaction()
    |> case do
      {:ok, _} ->

        json(conn, %{"info" => "sucesss"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        json(conn, %{"error" => "#{reason}"})
    end
  end

  defp handle_train_attachment(user, params, train) do
    params["entries"]
    |> Enum.map(fn {index, item} ->

      item = prepare_attachment(item, train)

      Ecto.Multi.new()
      |> Ecto.Multi.insert({:movement, index}, Movement.changeset(%Movement{maker_id: user.id}, item))

    end)
    |> Enum.reduce(Ecto.Multi.new(), &Ecto.Multi.append/2)
    |> Ecto.Multi.insert(:user_log, UserLog.changeset(%UserLog{}, %{
      user_id: user.id,
      activity: "Attached Wagons to Train No. : \"#{train.train_no}\" and Train List No .: \"#{train.train_list_no}\""
    }))
  end

  defp prepare_attachment(item, train) do
    item =
       item
       |> Map.new(fn {k, v} -> {String.to_atom(k), v} end)  |> IO.inspect()
    Map.merge(train, item)
  end

  def detach_wagon(conn,  params) do
    conn.assigns.user
    |> handle_detach_wagon(params)
    |> Repo.transaction()
    |> case do
      {:ok, _} ->

        json(conn, %{"info" => "sucesss"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        json(conn, %{"error" => "#{reason}"})
    end
  end

  defp handle_detach_wagon(user, params) do

   [train | _] = params["entries"] |> Map.values()

    params["entries"]
    |> Enum.map(fn {index, item} ->

      item = Rms.Order.get_movement!(item["id"])
      tracking_entry = Order.mvt_detected_wagon_lookup(item.id)
      wag = Rms.SystemUtilities.get_wagon!(item.wagon_id)
      tracking_entry = prepare_wagon_tracker_params(params, tracking_entry, wag)

      commodity = SystemUtilities.get_commodity!(item.commodity_id)

      Ecto.Multi.new()
      |> Ecto.Multi.update(
        {:movement, index},
        Movement.changeset(item, %{ "status" => "DETACHED", "detach_reason" => params["detach_reason"], "detach_date" => params["detach_date"] }))
      |> Ecto.Multi.insert({:wagontracking, index}, WagonTracking.changeset(%WagonTracking{maker_id: user.id}, tracking_entry))
      |> Ecto.Multi.update(
        {:update_wagon, index},
        Wagon.changeset(wag, %{
          load_status: commodity.load_status,
          mvt_status: "A",
          station_id: params["reporting_station_id"],
          commodity_id: commodity.id,
        })
      )
    end)
    |> Enum.reduce(Ecto.Multi.new(), &Ecto.Multi.append/2)
    |> Ecto.Multi.insert(:user_log, UserLog.changeset(%UserLog{}, %{
      user_id: user.id,
      activity: "Detached Wagons from  Train No. : \"#{train["train_no"]}\" and Train List No .: \"#{train["train_list_no"]}\""
    }))
  end

  defp prepare_wagon_tracker_params(params, item, wagon) do
    Map.merge(item, %{
      update_date: params["detach_date"],
      departure: to_string(wagon.wagon_status_id),
      on_hire: "N",
      month: month_name(params),
      current_location_id: params["reporting_station_id"],
      condition_id: wagon.condition_id,
      year: year(params)
    })
  end

  def month_name(params) do
    new_date = String.slice(params["detach_date"], -5..-4) |> String.trim() |> String.to_integer()
    Timex.month_shortname(new_date)
  end

  def year(params) do
    String.slice(params["detach_date"], -10..3)
  end

  def attach_detected_wagons(conn, %{"train_no" => train_no} = params) do

    with nil <- Order.intransit_train_lookup(train_no) do
      json(conn, %{"error" => "Train #{train_no} is not Intransit"})
    else
      train ->

      conn.assigns.user
      |> handle_attach_detected_wagons(params, train)
      |> Repo.transaction()
      |> case do
        {:ok, _} ->

          json(conn, %{"info" => "sucesss"})

        {:error, _failed_operation, failed_value, _changes_so_far} ->
          reason = traverse_errors(failed_value.errors) |> List.first()
          json(conn, %{"error" => "#{reason}"})
        end
    end
  end

  defp handle_attach_detected_wagons(user, params, train) do
    params["entries"]
    |> Enum.map(fn {index, item} ->

      item = prepare_new_train(item, train, params)
      entry = Rms.Order.get_movement!(item["id"])

      Ecto.Multi.new()
      |> Ecto.Multi.update( {:movement, index}, Movement.changeset(entry, item))
    end)
    |> Enum.reduce(Ecto.Multi.new(), &Ecto.Multi.append/2)
    |> Ecto.Multi.insert(:user_log, UserLog.changeset(%UserLog{}, %{
      user_id: user.id,
      activity: "Attached Wagons to Train No. : \"#{train.train_no}\" and Train List No .: \"#{train.train_list_no}\""
    }))
  end

  defp prepare_new_train(item, train, params) do
    Map.merge(item, %{
      "movement_destination_id" => train.movement_destination_id,
      "movement_reporting_station_id" => train.movement_reporting_station_id,
      "movement_origin_id" => train.movement_origin_id,
      "batch_id" => train.batch_id,
      "train_no" => train.train_no,
      "movement_time" => train.movement_time,
      "movement_date" => train.movement_date,
      "status" => train.status,
      "dead_loco" => train.dead_loco,
      "loco_no" => train.loco_no,
      "train_list_no" =>  train.train_list_no,
      "attached_date" => params["attached_date"]
    })
  end

  def mark_train_arrived(conn, params) do

    conn.assigns.user
    |> handle_mark_train_arrived(params)
    |> Repo.transaction()
    |> case do
      {:ok, _} ->

        json(conn, %{"info" => "sucesss"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        json(conn, %{"error" => "#{reason}"})
      end
  end

  defp handle_mark_train_arrived(user, params) do
    params["entries"]
    |> Enum.map(fn {index, item} ->

      entry = Rms.Order.get_movement!(item["id"])

      Ecto.Multi.new()
      |> Ecto.Multi.update( {:movement, index}, Movement.changeset(entry, %{"status" => "APPROVED", "arrival_date" => params["arrival_date"]  }))
    end)
    |> Enum.reduce(Ecto.Multi.new(), &Ecto.Multi.append/2)
    |> Ecto.Multi.insert(:user_log, UserLog.changeset(%UserLog{}, %{
      user_id: user.id,
      activity: "Marked  Train No. : \"#{params["train_no"]}\" with Train List No .: \"#{params["train_list_no"]}\" as arrived"
    }))
  end

  def movement_pending_approval(conn, _params) do
    user = conn.assigns.user
    batches = Rms.Order.movement_batch_pending_approval(user)
    render(conn, "movement_pending_batch.html", batches: batches)
  end

  def movement_pending_entries(conn, params) do
    batch_items = Order.list_movement_batch_items(params["batch_id"])
    batch = Order.get_batch!(params["batch_id"])
    stations = Rms.SystemUtilities.list_tbl_station()
    wagons = Rms.SystemUtilities.list_tbl_wagon()
    clients = Rms.Accounts.list_tbl_clients()
    commodity = Rms.SystemUtilities.list_tbl_commodity()
    loco = Rms.Locomotives.list_tbl_locomotive()

    render(conn, "movement_pending_entries.html",
      batch_no: batch.batch_no,
      batch_id: params["batch_id"],
      batch_items: batch_items,
      stations: stations,
      wagons: wagons,
      clients: clients,
      commodity: commodity,
      loco: loco
    )
  end

  def approve_movement(conn, %{"batch_id" => id, "status" => status}) do
    unmatched_period = SystemUtilities.list_company_info().unmatched_aging_period
    params = Order.all_movement_batch_entries(id, "PENDING_VERIFICATION", unmatched_period)

    conn.assigns.user
    |> handle_approve_movement(params, status)
    |> Repo.transaction()
    |> case do
      {:ok, _} ->
        Rms.Order.update_batch(Rms.Order.get_batch!(id), %{status: "COMPT"})
        json(conn, %{"info" => "sucesss"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        json(conn, %{"error" => "#{reason}"})
    end
  end

  defp handle_approve_movement(user, items, status) do
    Enum.with_index(items, 1)
    |> Enum.map(fn {item, index} ->
      entry = Rms.Order.get_movement!(item.id)

      Ecto.Multi.new()
      |> Ecto.Multi.update(
        {:movement, index},
        Movement.changeset(entry, Map.merge(item, %{status: status, checker_id: user.id}))
      )
      |> Ecto.Multi.insert(
        {:user_log, index},
        UserLog.changeset(%UserLog{}, %{
          user_id: user.id,
          activity: "Approved movement train list No. : \"#{item.train_list_no}\""
        })
      )
    end)
    |> Enum.reduce(Ecto.Multi.new(), &Ecto.Multi.append/2)
  end

  def reject_movement(conn, %{"batch_id" => id}) do
    unmatched_period = SystemUtilities.list_company_info().unmatched_aging_period
    params = Order.all_movement_batch_entries(id, "PENDING_VERIFICATION", unmatched_period)

    conn.assigns.user
    |> handle_reject_movement(params)
    |> Repo.transaction()
    |> case do
      {:ok, _} ->
        Rms.Order.update_batch(Rms.Order.get_batch!(id), %{status: "R"})
        Rms.Emails.Email.rejected_movement(id)
        json(conn, %{"info" => "sucesss"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        json(conn, %{"error" => "#{reason}"})
    end
  end

  defp handle_reject_movement(user, items) do
    Enum.with_index(items, 1)
    |> Enum.map(fn {item, index} ->
      entry = Rms.Order.get_movement!(item.id)

      Ecto.Multi.new()
      |> Ecto.Multi.update(
        {:movement, index},
        Movement.changeset(entry, Map.merge(item, %{status: "REJECTED", checker_id: user.id}))
      )
      |> Ecto.Multi.insert(
        {:user_log, index},
        UserLog.changeset(%UserLog{}, %{
          user_id: user.id,
          activity: "Rejected movement train list No. : \"#{item.train_list_no}\""
        })
      )
    end)
    |> Enum.reduce(Ecto.Multi.new(), &Ecto.Multi.append/2)
  end

  def discard_movement(conn, %{"batch_id" => id}) do
    unmatched_period = SystemUtilities.list_company_info().unmatched_aging_period
    params = Order.all_movement_batch_entries(id, "PENDING", unmatched_period)

    conn.assigns.user
    |> handle_discard_movement(params)
    |> Repo.transaction()
    |> case do
      {:ok, _} ->
        Rms.Order.update_batch(Rms.Order.get_batch!(id), %{status: "R"})
        json(conn, %{"info" => "sucesss"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        json(conn, %{"error" => "#{reason}"})
    end
  end

  defp handle_discard_movement(user, items) do
    Enum.with_index(items, 1)
    |> Enum.map(fn {item, index} ->
      entry = Rms.Order.get_movement!(item.id)

      Ecto.Multi.new()
      |> Ecto.Multi.update(
        {:movement, index},
        Movement.changeset(entry, Map.merge(item, %{status: "DISCARDED", checker_id: user.id}))
      )
      |> Ecto.Multi.insert(
        {:user_log, index},
        UserLog.changeset(%UserLog{}, %{
          user_id: user.id,
          activity: "Discared movement train list No. : \"#{item.train_list_no}\""
        })
      )
    end)
    |> Enum.reduce(Ecto.Multi.new(), &Ecto.Multi.append/2)
  end

  def create_movement_batch(conn, _params) do
    user = conn.assigns.user
    params = prepare_movement_batch(user)

    case Order.create_batch(params) do
      {:ok, _batch} ->
        last_batch = Order.select_last_movement_batch(user.id)

        assigns = [
          batch: last_batch.batch_no,
          batch_id: last_batch.id,
          tid: params["tid"]
        ]

        redirect(conn, to: Routes.movement_path(conn, :movement_batch_entries, assigns))

      {:error, changeset} ->
        reason = UserController.traverse_errors(changeset.errors)

        conn
        |> put_flash(:error, reason)
        |> redirect(to: Routes.movement_path(conn, :index_movement))
    end
  end

  def movement_draft_entries(conn, params) do
    batch_items = Order.list_movement_batch_items(params["batch_id"])
    batch = Order.get_batch!(params["batch_id"])
    stations = Rms.SystemUtilities.list_tbl_station() |> Enum.reject(&(&1.status != "A"))
    wagons = Rms.SystemUtilities.list_tbl_wagon() |> Enum.reject(&(&1.status != "A"))
    clients = Rms.Accounts.list_tbl_clients() |> Enum.reject(&(&1.status != "A"))
    commodity = Rms.SystemUtilities.list_tbl_commodity() |> Enum.reject(&(&1.status != "A"))
    loco = Rms.Locomotives.list_tbl_locomotive() |> Enum.reject(&(&1.status != "A"))

    render(conn, "movement_draft_entries.html",
      batch_no: batch.batch_no,
      batch_id: params["batch_id"],
      batch_items: batch_items,
      stations: stations,
      wagons: wagons,
      clients: clients,
      commodity: commodity,
      loco: loco
    )
  end

  def prepare_movement_batch(user) do
    %{
      "trans_date" => to_string(Timex.today()),
      "batch_type" => "MOVEMENT",
      "value_date" => Timex.format!(Timex.today(), "%Y%m%d", :strftime),
      "current_user_id" => user.id,
      "last_user_id" => user.id,
      "uuid" => Ecto.UUID.generate()
    }
  end

  def movement_batch_entries(conn, params) do
    batch_items = Order.list_movement_batch_items(params["batch_id"])
    batch = Order.get_batch!(params["batch_id"])
    stations = Rms.SystemUtilities.list_tbl_station() |> Enum.reject(&(&1.status != "A"))
    wagons = Rms.SystemUtilities.list_tbl_wagon() |> Enum.reject(&(&1.status != "A"))
    clients = Rms.Accounts.list_tbl_clients() |> Enum.reject(&(&1.status != "A"))
    commodity = Rms.SystemUtilities.list_tbl_commodity() |> Enum.reject(&(&1.status != "A"))
    loco = Rms.Locomotives.list_tbl_locomotive() |> Enum.reject(&(&1.status != "A"))

    render(conn, "new_movement_entries.html",
      batch_no: batch.batch_no,
      batch_id: params["batch_id"],
      batch_items: batch_items,
      stations: stations,
      wagons: wagons,
      clients: clients,
      commodity: commodity,
      loco: loco
    )
  end

  def movement_batch_entries_lookup(conn, %{"batch_id" => batch_id, "status" => status}) do
    unmatched_period = SystemUtilities.list_company_info().unmatched_aging_period
    batch_items = Order.all_movement_batch_entries(batch_id, status, unmatched_period)
    json(conn, %{"data" => List.wrap(batch_items)})
  end

  def movement_verification_entries(conn, params) do
    batch_items = Order.list_movement_batch_items(params["batch_id"])
    batch = Order.get_batch!(params["batch_id"])
    stations = Rms.SystemUtilities.list_tbl_station()
    wagons = Rms.SystemUtilities.list_tbl_wagon()
    clients = Rms.Accounts.list_tbl_clients()
    commodity = Rms.SystemUtilities.list_tbl_commodity()
    loco = Rms.Locomotives.list_tbl_locomotive()

    render(conn, "movement_verification_entries.html",
      batch_no: batch.batch_no,
      batch_id: params["batch_id"],
      batch_items: batch_items,
      stations: stations,
      wagons: wagons,
      clients: clients,
      commodity: commodity,
      loco: loco
    )
  end

  def movement_report_batch(conn, _params) do
    render(conn, "movement_report_batch.html")
  end

  def movement_haulage_report(conn, _params) do
    render(conn, "movement_haulage_report.html")
  end

  def movement_customer_based_report(conn, _params) do
    render(conn, "movement_customer_based_report.html")
  end

  def movement_report_lookup(conn, params) do
    {draw, start, length, search_params} = InterchangeController.search_options(params)

    results = Rms.Order.movement_report_lookup(search_params, start, length, conn.assigns.user)

    total_entries = InterchangeController.total_entries(results)

    results = %{
      draw: draw,
      recordsTotal: total_entries,
      recordsFiltered: total_entries,
      data:
        InterchangeController.entries(results)
        |> Enum.map(fn item -> %{item | batch_id: mvt_salt(conn, item.batch_id)} end)
    }

    json(conn, results)
  end

  defp mvt_salt(conn, id),
    do: Phoenix.Token.sign(conn, "mvt salt", id, signed_at: System.system_time(:second))

  defp confirm_token(conn, token) do
    case Phoenix.Token.verify(conn, "mvt salt", token, max_age: 86400) do
      {:ok, batch_id} ->
        {:ok, batch_id}

      {:error, _} ->
        :error
    end
  end

  def report_batch_entries(conn, params) do
    with :error <- confirm_token(conn, params["batch"]) do
      conn
      |> put_flash(:error, "invalid token received")
      |> redirect(to: Routes.movement_path(conn, :movement_report_batch))
    else
      {:ok, batch_id} ->
        batch_items = Order.list_movement_batch_items(batch_id)
        stations = Rms.SystemUtilities.list_tbl_station()
        wagons = Rms.SystemUtilities.list_tbl_wagon()
        clients = Rms.Accounts.list_tbl_clients()
        commodity = Rms.SystemUtilities.list_tbl_commodity()
        loco = Rms.Locomotives.list_tbl_locomotive()

        render(conn, "movement_report_batch_entries.html",
          batch_items: batch_items,
          stations: stations,
          wagons: wagons,
          clients: clients,
          commodity: commodity,
          loco: loco
        )
    end
  end

  def report_batch_entries_lookup(conn, %{"batch_id" => batch_id}) do
    unmatched_period = SystemUtilities.list_company_info().unmatched_aging_period
    batch_items = Order.all_movement_batch_entries(batch_id, "COMPLETE", unmatched_period)
    json(conn, %{"data" => List.wrap(batch_items)})
  end

  def movement_report_entry_lookup(conn, %{"id" => id}) do
    batch_item = Order.movement_report_entry_lookup(id)
    json(conn, %{"data" => batch_item})
  end

  def monthly_income_summary(conn, params) do
    company = SystemUtilities.list_company_info()
    unmatched_period = company.unmatched_aging_period

    start_dt = params["start_date"] || Timex.today() |> to_string()
    end_dt = params["end_date"] || Timex.today() |> to_string()

    summary =
      Order.monthly_income_summary(start_dt, end_dt, unmatched_period, conn.assigns.user)
      |> format_monthly_income_summary()

    total_amount =
      Enum.reduce(summary, 0, fn {_key, results}, acc ->
        acc + Enum.reduce(results, 0, &(Decimal.to_float(&1.amount) + &2))
      end)

    total_tonnages =
      Enum.reduce(summary, 0, fn {_key, results}, acc ->
        acc + Enum.reduce(results, 0, &(Decimal.to_float(&1.tonnages) + &2))
      end)

    total_rate =
      Enum.reduce(summary, 0, fn {_key, results}, acc ->
        acc + Enum.reduce(results, 0, &(Decimal.to_float(&1.rate) + &2))
      end)

    total_wagons =
      Enum.reduce(summary, 0, fn {_key, results}, acc ->
        Decimal.add(acc, Enum.reduce(results, 0, &Decimal.add(&1.wagons, &2)))
      end)

    summary =
      Map.new(summary, fn {key, results} ->
        total =
          Enum.reduce(
            results,
            %{total_wagons: 0, total_amount: 0, total_rate: 0, total_tonnage: 0},
            fn result, acc ->
              %{
                acc
                | total_wagons: Decimal.add(acc.total_wagons, result.wagons),
                  total_amount: Decimal.add(acc.total_amount, result.amount),
                  total_rate: Decimal.add(acc.total_rate, result.rate),
                  total_tonnage: Decimal.add(acc.total_tonnage, result.tonnages)
              }
            end
          )

        results = Enum.map(results, &Map.merge(&1, total))
        {key, results}
      end)

    render(conn, "monthly_income_summary.html",
      summary: summary,
      total_amount: total_amount,
      total_tonnages: total_tonnages,
      total_wagons: total_wagons,
      total_rate: total_rate,
      start_date: start_dt,
      end_date: end_dt,
      company: company
    )
  end

  defp format_monthly_income_summary(entries) do
    entries
    |> Enum.group_by(& &1.transport_type)
    |> Enum.into(%{}, fn {trans_type, entries} ->
      entries =
        Enum.group_by(entries, & &1.commodity_id)
        |> Enum.map(fn {_com_id, vals} ->
          entry =
            Enum.reduce(vals, fn val, acc ->
              val_fields = [:amount, :rate, :tarrif_rate_count, :tonnages, :wagons]

              Map.merge(acc, val, fn key, v1, v2 ->
                if Enum.member?(val_fields, key), do: Decimal.add(v1, v2), else: v2
              end)
            end)

          %{entry | rate: Decimal.div(entry.rate, entry.tarrif_rate_count)}
        end)

      {trans_type, entries}
    end)
  end

  def excel_exp(conn, params) do
    entries = process_report(conn, @current, params)
    user = conn.assigns.user

    conn
    |> put_resp_content_type("text/xlsx")
    |> put_resp_header(
      "content-disposition",
      "attachment; filename=#{params["report_type"]}_#{Timex.today()}.xlsx"
    )
    |> render("report.xlsx", %{entries: entries, user: user, report_type: params["report_type"]})
  end

  defp process_report(conn, source, params) do
    params
    |> Map.delete("_csrf_token")
    |> report_generator(source, conn.assigns.user)
    |> Repo.all()
  end

  def report_generator(search_params, source, user) do
    settings = SystemUtilities.list_company_info()

    Rms.Order.movement_report_lookup_excel(
      source,
      Map.put(search_params, "isearch", ""),
      settings,
      user
    )
  end

  def movement_without_consignment(conn, _params) do
    user = conn.assigns.user
    params = Map.put(prepare_movement_batch(user), "status", "C")

    case Order.create_batch(params) do
      {:ok, _batch} ->
        last_batch = Order.select_last_movement_batch(user.id)

        assigns = [
          batch: last_batch.batch_no,
          batch_id: last_batch.id,
          tid: params["tid"]
        ]

        redirect(conn, to: Routes.movement_path(conn, :movement_without_congnmt_batch, assigns))

      {:error, changeset} ->
        reason = UserController.traverse_errors(changeset.errors)

        conn
        |> put_flash(:error, reason)
        |> redirect(to: Routes.movement_path(conn, :index_movement))
    end
  end


  def movement_without_congnmt_batch(conn, params) do
    batch_items =
      case params["batch_id"] do
        nil -> []
        _-> Order.list_movement_batch_items(params["batch_id"])
      end
    # batch =
    #   case params["batch_id"] do
    #     nil -> []
    #     _-> Order.get_batch!(params["batch_id"])
    #   end
    stations = Rms.SystemUtilities.list_tbl_station() |> Enum.reject(&(&1.status != "A")) |> Enum.sort_by(&(&1.description), :asc)
    clients = Rms.Accounts.list_tbl_clients() |> Enum.reject(&(&1.status != "A")) |> Enum.sort_by(&(&1.client_name), :asc)
    commodity = Rms.SystemUtilities.list_tbl_commodity() |> Enum.reject(&(&1.status != "A")) |> Enum.sort_by(&(&1.description), :asc)
    loco = Rms.Locomotives.list_tbl_locomotive() |> Enum.reject(&(&1.status != "A"))
    render(conn, "new_mvt_without_consgmnt.html",
      batch_no: params["batch_no"],
      batch_id: params["batch_id"],
      batch_items: batch_items,
      stations: stations,
      wagons: [],
      clients: clients,
      commodity: commodity,
      loco: loco
    )
  end


  def edit_movement_entries(conn, %{"batch" => batch_id}) do
    batch_items = Order.list_movement_batch_items(batch_id)
    batch = Order.get_batch!(batch_id)
    stations = Rms.SystemUtilities.list_tbl_station() |> Enum.reject(&(&1.status != "A"))
    wagons = Rms.SystemUtilities.list_tbl_wagon() |> Enum.reject(&(&1.status != "A"))
    clients = Rms.Accounts.list_tbl_clients() |> Enum.reject(&(&1.status != "A"))
    commodity = Rms.SystemUtilities.list_tbl_commodity() |> Enum.reject(&(&1.status != "A"))
    loco = Rms.Locomotives.list_tbl_locomotive() |> Enum.reject(&(&1.status != "A"))

    render(conn, "edit_movement_entries.html",
      batch_no: batch.batch_no,
      batch_id: batch_id,
      batch_items: batch_items,
      stations: stations,
      wagons: wagons,
      clients: clients,
      commodity: commodity,
      loco: loco
    )
  end

  def edit_movement_entries(conn, params) do
    with :error <- confirm_token(conn, params["batch_id"]) do
      conn
      |> put_flash(:error, "invalid token received")
      |> redirect(to: Routes.movement_path(conn, :movement_report_batch))
    else
      {:ok, batch_id} ->
        batch_items = Order.list_movement_batch_items(batch_id)
        batch = Order.get_batch!(batch_id)
        stations = Rms.SystemUtilities.list_tbl_station() |> Enum.reject(&(&1.status != "A"))
        wagons = Rms.SystemUtilities.list_tbl_wagon() |> Enum.reject(&(&1.status != "A"))
        clients = Rms.Accounts.list_tbl_clients() |> Enum.reject(&(&1.status != "A"))
        commodity = Rms.SystemUtilities.list_tbl_commodity() |> Enum.reject(&(&1.status != "A"))
        loco = Rms.Locomotives.list_tbl_locomotive() |> Enum.reject(&(&1.status != "A"))

        render(conn, "edit_movement_entries.html",
          batch_no: batch.batch_no,
          batch_id: batch_id,
          batch_items: batch_items,
          stations: stations,
          wagons: wagons,
          clients: clients,
          commodity: commodity,
          loco: loco
        )
    end
  end

  def movement_item_lookup(conn, %{"id" => id}) do
    unmatched_period = SystemUtilities.list_company_info().unmatched_aging_period
    item = Order.mvt_item_lookup(id, unmatched_period)
    json(conn, %{"data" => item})
  end

  def update_movement_item(conn, params) do
    item = Rms.Order.get_movement!(params["id"])

    Ecto.Multi.new()
    |> Ecto.Multi.update(
      :update,
      Movement.changeset(item, Map.merge(params, %{"modifier_id" => conn.assigns.user.id}))
    )
    |> Ecto.Multi.run(:user_log, fn _, %{update: update} ->
      activity =
        "Updated movement item in Train list number \"#{update.train_list_no}\" wagon Id \"#{update.wagon_id}\""

      user_log = %{
        user_id: conn.assigns.user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> Repo.insert()
    end)
    |> Repo.transaction()
    |> case do
      {:ok, _} ->
        json(conn, %{"info" => "Changes applied successfully!"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        json(conn, %{"error" => reason})
    end
  end

  def update_movement(conn, %{"entries" => params, "batch_id" => _id, "loco_no" => loco_no}) do
    conn.assigns.user
    |> handle_update(params, loco_no)
    |> Repo.transaction()
    |> case do
      {:ok, _} ->
        json(conn, %{"info" => "sucesss"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        json(conn, %{"error" => "#{reason}"})
    end
  end

  defp handle_update(user, params, loco_no) do
    items = Map.values(params) |> Enum.reject(&(&1["wagon_id"] == nil))

    Enum.with_index(items, 1)
    |> Enum.map(fn {item, index} ->
      loco_no = Poison.encode!(loco_no)
      entry = Rms.Order.get_movement!(item["id"])

      Ecto.Multi.new()
      |> Ecto.Multi.insert_or_update(
        {:movement, index},
        Movement.changeset(
          entry,
          Map.merge(item, %{"loco_no" => loco_no, "modifier_id" => user.id})
        )
      )
      |> Ecto.Multi.insert(
        {:user_log, index},
        UserLog.changeset(%UserLog{}, %{
          user_id: user.id,
          activity: "Updated movement train list No. : \"#{item["train_list_no"]}\""
        })
      )
    end)
    |> Enum.reduce(Ecto.Multi.new(), &Ecto.Multi.append/2)
  end

  def search_loco_number(conn, %{"search" => search_term, "page" => start}) do
    results = Locomotives.select_locomotive_no("%#{search_term}%", String.to_integer(start))
    total_count = if(length(results) > 0, do: List.first(results).total_count, else: 0)

    json(conn, %{
      results: Enum.map(results, &Map.delete(&1, :total_count)),
      total_count: total_count
    })
  end

  def search_station(conn, %{"search" => search_term, "page" => start}) do
    results = SystemUtilities.search_station("%#{search_term}%", String.to_integer(start))
    total_count = if(length(results) > 0, do: List.first(results).total_count, else: 0)

    json(conn, %{
      results: Enum.map(results, &Map.delete(&1, :total_count)),
      total_count: total_count
    })
  end

  def lookup_stn_owner(conn, %{"movement_reporting_station_id" => movement_reporting_station_id}) do
    owner = Rms.SystemUtilities.station_owner_lookup(movement_reporting_station_id)
    json(conn, %{"data" => List.wrap(owner)})
  end

  def invoice_lookup(conn, %{"station_code" => station_code, "wagon_id" => wagon_id}) do
    invoice = Rms.Order.invoice_lookup(station_code, wagon_id)
    json(conn, %{"data" => invoice})
  end

  def mvt_recon_report(conn, _params) do
    render(conn, "mvt_recon_report.html")
  end

  def mvt_wagon_querry_report(conn, _params) do
    render(conn, "mvt_wagon_querry_report.html")
  end

  def traverse_errors(errors) do
    for {key, {msg, _opts}} <- errors, do: "#{key} #{msg}"
  end

  def works_order(conn, _params) do
    stations = SystemUtilities.list_tbl_station() |> Enum.reject(&(&1.status != "A"))
    clients = Accounts.list_tbl_clients() |> Enum.reject(&(&1.status != "A"))
    commodity = SystemUtilities.list_tbl_commodity() |> Enum.reject(&(&1.status != "A"))
    render(conn, "works_order.html",  stations:  stations, clients: clients, commodity: commodity)
  end

  def create_works_order(conn, %{"entries" => params}) do
    conn.assigns.user
    |> handle_create_works_order(params)
    |> Repo.transaction()
    |> case do
      {:ok, _} ->
        json(conn, %{"info" => "sucesss"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        json(conn, %{"error" => "#{reason}"})
    end
  end

  defp handle_create_works_order(user, params) do
    params
    |> Enum.map(fn {index, item} ->
      Ecto.Multi.new()
      |> Ecto.Multi.insert(
        {:works_order, index},
        WorksOrders.changeset(%WorksOrders{maker_id: user.id}, item)
      )
      |> Ecto.Multi.insert(
        {:user_log, index},
        UserLog.changeset(%UserLog{}, %{
          user_id: user.id,
          activity:
            "Create Works Order on Wagon: \"#{item["wagon_id"]}\" on Train \"#{item["train_no"]}\""
        })
      )
    end)
    |> Enum.reduce(Ecto.Multi.new(), &Ecto.Multi.append/2)
  end

  def works_order_report(conn, _params) do
    admins = Accounts.list_tbl_railway_administrator() |> Enum.reject(&(&1.status != "A"))
    render(conn, "works_order_report.html",  admins:  admins)
  end

  def works_order_lookup(conn, %{"id" => id}) do
    item = Order.works_order_lookup(id)
    json(conn, %{"data" => item})
  end

  def  works_order_pdf(conn, %{"id" => id}) do
    item = Order.works_order_lookup(id)
    content = Rms.Workers.WorksOrder.generate(item)

    conn =
      conn
      |> put_resp_header(
        "content-disposition",
        "attachment; filename=Works_order#{Timex.today()}.pdf"
      )
      |> put_resp_content_type("text/pdf")

    send_resp(conn, 200, content)
  end

  def authorize(conn) do
    case Phoenix.Controller.action_name(conn) do
      act
      when act in ~w(create_movement_batch movement_pending_approval movement_batch_entries submit_movement )a ->
        {:movement, :create_movement_batch}

      act when act in ~w(approve_movement)a ->
        {:movement, :approve_movement}

      act
      when act in ~w(movement_draft movement_draft movement_draft_entries  create_movement )a ->
        {:movement, :movement_draft}

      act when act in ~w( create_movement rejected_movement)a ->
        {:movement, :rejected_movement}

      act when act in ~w(reject_movement)a ->
        {:movement, :reject_movement}

      act when act in ~w(discard_movement)a ->
        {:movement, :discard_movement}

      act when act in ~w(movement_verification_batch movement_verification_entries )a ->
        {:movement, :movement_verification_batch}

      act
      when act in ~w(movement_report_batch mvt_wagon_querry_report mvt_recon_report movement_customer_based_report movement_haulage_report excel_exp report_batch_entries)a ->
        {:movement, :movement_report_batch}

      act when act in ~w(monthly_income_summary)a ->
        {:movement, :monthly_income_summary}

      act
      when act in ~w(edit_movement_entries movement_item_lookup update_movement update_movement_item)a ->
        {:movement, :edit_movement_entries}

      act
      when act in ~w(movement_without_consignment movement_pending_approval create_movement_batch movement_without_congnmt_batch movement_batch_entries submit_movement)a ->
        {:movement, :movement_without_consignment}

      act
      when act in ~w(works_order_report works_order_lookup)a ->
        {:movement, :works_order_report}

      act
      when act in ~w(works_order create_works_order)a ->
        {:movement, :works_order}
      act
      when act in ~w(movement_intransit_batch movement_intransit_entries)a ->
        {:movement, :movement_intransit_batch}
      act
      when act in ~w(movement_detached_batch movement_detached_entries)a ->
        {:movement, :movement_detached_batch}
      act
      when act in ~w(train_attachment)a ->
        {:movement, :train_attachment}
      act
      when act in ~w(mark_train_arrived)a ->
        {:movement, :mark_train_arrived}
      act
      when act in ~w(attach_detected_wagons)a ->
        {:movement, :attach_detected_wagons}
      act
      when act in ~w(detach_wagon)a ->
        {:movement, :detach_wagon}

      _ ->
        {:movement, :unknown}
    end
  end
end
