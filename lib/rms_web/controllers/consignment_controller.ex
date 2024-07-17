defmodule RmsWeb.ConsignmentController do
  use RmsWeb, :controller

  alias Rms.Consignments
  alias Rms.Order.{Consignment, Movement}
  alias Rms.Order
  alias Rms.Accounts
  alias Rms.SystemUtilities
  alias Rms.Activity.UserLog
  alias Rms.Repo
  alias RmsWeb.InterchangeController
  alias Rms.Order.Batch

  @current "tbl_consignment"

  plug(
    RmsWeb.Plugs.RequireAuth
    when action not in [:unknown]
  )

  plug(
    RmsWeb.Plugs.EnforcePasswordPolicy
    when action not in [:unknown]
  )

  plug RmsWeb.Plugs.Authenticate,
       [module_callback: &RmsWeb.ConsignmentController.authorize/1]
       when action not in [
              :unknown,
              :consignment_sales_orders_batch_entries,
              :search_for_consignment,
              :lookup_consignment,
              :search_commodity,
              :search_client_name,
              :search_station_name,
              :consign_delivery_note,
              :station_code_lookup,
              :mvt_search_for_consignment
            ]

  def new_consignment(conn, _params) do
    user = conn.assigns.user
    params = prepare_batch_params(user)

    case Order.create_batch(params) do
      {:ok, batch} ->
        last_batch = Order.get_by_uuid(batch.uuid)

        assigns = [
          batch: last_batch.batch_no,
          batch_id: last_batch.id,
          doc_seq_no: last_batch.doc_seq_no
        ]

        redirect(conn, to: Routes.consignment_path(conn, :batch_entries, assigns))

      {:error, changeset} ->
        reason = traverse_errors(changeset.errors)

        conn
        |> put_flash(:error, reason)
        |> redirect(to: Routes.consignment_path(conn, :index))
    end
  end

  def prepare_batch_params(user) do
    %{
      "trans_date" => to_string(Timex.today()),
      "value_date" => Timex.format!(Timex.today(), "%Y%m%d", :strftime),
      "current_user_id" => user.id,
      "last_user_id" => user.id,
      "uuid" => Ecto.UUID.generate(),
      "doc_seq_no" => ""
    }
  end

  def gen_new_doc_seq_no() do
    query = """
    select doc_ref = format(NEXT VALUE FOR dbo.DocSeqNumber, '00000')
    """

    {:ok, %{columns: _columns, rows: rows}} = Rms.Repo.query(query, [])
    rows |> List.flatten() |> List.first()
  end

  def consignment_draft(conn, _params) do
    user = conn.assigns.user
    data_entry_batches = Order.consignment_draft_batches(user)
    render(conn, "consignment_draft.html", data_entry_batches: data_entry_batches)
  end

  def rejected_consignment(conn, _params) do
    user = conn.assigns.user
    data_entry_batches = Order.consignment_rejected_batches(user)
    render(conn, "rejected_consignment.html", data_entry_batches: data_entry_batches)
  end

  def draft(conn, params) do
    empty_commodity = SystemUtilities.empty_commodity_lookup().id
    batch_items = Order.list_batch_items(params["batch_id"], empty_commodity)
    batch = Order.get_batch!(params["batch_id"])
    clients = Accounts.list_tbl_clients() |> Enum.reject(&(&1.status != "A"))
    stations = SystemUtilities.list_tbl_station() |> Enum.reject(&(&1.status != "A"))
    commodity = SystemUtilities.list_tbl_commodity() |> Enum.reject(&(&1.status != "A"))

    railway_administrator =
      Accounts.list_tbl_railway_administrator() |> Enum.reject(&(&1.status != "A"))

    rate = SystemUtilities.list_company_info()

    render(conn, "drafted_consignment_entries.html",
      batch_no: batch.batch_no,
      doc_seq_no: batch.doc_seq_no,
      batch_id: params["batch_id"],
      batch_items: batch_items,
      # consignments: consignments,
      clients: clients,
      stations: stations,
      commodity: commodity,
      stations: stations,
      railway_administrator: railway_administrator,
      rate: rate
    )
  end

  def consignment_sales_orders_batch_entries(conn, %{
        "batch_id" => batch_id,
        "tarriff_id" => tarriff_id,
        "status" => status
      }) do
    rate =
      case tarriff_id do
        "" -> []
        _ -> Rms.SystemUtilities.tariffline_lookup(tarriff_id)
      end

    batch_items = Order.all_batch_items(batch_id, [status, "PENDING_INVOICE", "REJECTED"])
    json(conn, %{"data" => List.wrap(batch_items), "rate" => List.wrap(rate)})
  end

  def batch_entries(conn, params) do
    empty_commodity = SystemUtilities.empty_commodity_lookup().id
    batch_items =
      case params["batch_id"] do
       nil -> []
       _ -> Order.list_batch_items(params["batch_id"], empty_commodity)
       end
    stations = SystemUtilities.list_tbl_station() |> Enum.reject(&(&1.status != "A"))
    rate = SystemUtilities.list_company_info()

    render(conn, "new_consignment_entries.html",
      batch_no: params["batch"],
      batch_id: params["batch_id"],
      doc_seq_no: params["doc_seq_no"],
      batch_items: batch_items,
      stations: stations,
      rate: rate
    )
  end

  def save_consignment(conn, %{"entries" => params,  "batch_id" => batch_id}) do
    conn.assigns.user
    |> handle_create(params, batch_id)
    |> Repo.transaction()
    |> case do
      {:ok, _} ->
        json(conn, %{"info" => "sucesss"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        json(conn, %{"error" => "#{reason}"})
    end
  end


  defp handle_create(user, params, "") do

      items = Map.values(params) |> Enum.reject(&(&1["wagon_id"] == nil))
      {:ok, batch} = Order.create_batch(prepare_batch_params(user))

      batch = Order.get_by_uuid(batch.uuid) |> IO.inspect()

      Enum.with_index(items, 1)
      |> Enum.map(fn {item, index} ->
        item = %{item |
          "station_code" => String.replace(item["station_code"], ~r/[[:blank:]]/, ""),
          "batch_id" => batch.id,
          "sale_order" => batch.batch_no
        }

        entry =
          if(to_string(item["id"]) == "",
            do: %Consignment{maker_id: user.id},
            else: Consignments.get_consignment!(item["id"])
          )

        Ecto.Multi.new()
        |> Ecto.Multi.insert_or_update({:consignment, index}, Consignment.changeset(entry, item))
        |> Ecto.Multi.insert(
          {:user_log, index},
          UserLog.changeset(%UserLog{}, %{
            user_id: user.id,
            activity: "saved consignment order on sales number: \"#{batch.batch_no}\""
          })
        )
      end)
      |> Enum.reduce(Ecto.Multi.new(), &Ecto.Multi.append/2)
  end

  defp handle_create(user, params, _) do
    items = Map.values(params) |> Enum.reject(&(&1["wagon_id"] == nil))

    Enum.with_index(items, 1)
    |> Enum.map(fn {item, index} ->
      item = %{item | "station_code" => String.replace(item["station_code"], ~r/[[:blank:]]/, "")}

      entry =
        if(to_string(item["id"]) == "",
          do: %Consignment{maker_id: user.id},
          else: Consignments.get_consignment!(item["id"])
        )

      Ecto.Multi.new()
      |> Ecto.Multi.insert_or_update({:consignment, index}, Consignment.changeset(entry, item))
      |> Ecto.Multi.insert(
        {:user_log, index},
        UserLog.changeset(%UserLog{}, %{
          user_id: user.id,
          activity: "saved consignment order on sales number: \"#{item["sale_order"]}\""
        })
      )
    end)
    |> Enum.reduce(Ecto.Multi.new(), &Ecto.Multi.append/2)
  end


  def submit_consignment(conn, %{"entries" => params,  "batch_id" => batch_id}) do
    conn.assigns.user
    |> handle_submit(params, batch_id)
    |> Repo.transaction()
    |> case do
      {:ok, _} ->
        # Rms.Order.update_batch(Rms.Order.get_batch!(id), %{status: "C"})
        json(conn, %{"info" => "sucesss"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        json(conn, %{"error" => "#{reason}"})
    end
  end


  defp handle_submit(user, params, "") do

      items = Map.values(params) |> Enum.reject(&(&1["wagon_id"] == nil))
      {:ok, batch} = Order.create_batch(prepare_batch_params(user))

      batch = Order.get_by_uuid(batch.uuid) |> IO.inspect()

      Enum.with_index(items, 1)
      |> Enum.map(fn {item, index} ->
        item = %{item |
          "station_code" => String.replace(item["station_code"], ~r/[[:blank:]]/, ""),
          "batch_id" => batch.id,
          "sale_order" => batch.batch_no
        }

        entry =
          if(to_string(item["id"]) == "",
            do: %Consignment{maker_id: user.id},
            else: Consignments.get_consignment!(item["id"])
          )

        Ecto.Multi.new()
        |> Ecto.Multi.insert_or_update({:consignment, index}, Consignment.changeset(entry, Map.merge(item, %{"status" => "PENDING_APPROVAL"})))
        |> Ecto.Multi.insert(
          {:user_log, index},
          UserLog.changeset(%UserLog{}, %{
            user_id: user.id,
            activity: "Submited consignment order on sales number: \"#{batch.batch_no}\" for verification"
          })
        )
      end)
      |> Enum.reduce(Ecto.Multi.new(), &Ecto.Multi.append/2)
      |> Ecto.Multi.update(:update_batch, Batch.changeset(batch, %{status: "C"}))
  end

  defp handle_submit(user, params, batch_id) do
    items = Map.values(params) |> Enum.reject(&(&1["wagon_id"] == nil))

    batch = Rms.Order.get_batch!(batch_id)

    Enum.with_index(items, 1)
    |> Enum.map(fn {item, index} ->
      item = %{item | "station_code" => String.replace(item["station_code"], ~r/[[:blank:]]/, "")}

      entry =
        if(to_string(item["id"]) == "",
          do: %Consignment{maker_id: user.id},
          else: Consignments.get_consignment!(item["id"])
        )

      Ecto.Multi.new()
      |> Ecto.Multi.insert_or_update({:consignment, index}, Consignment.changeset(entry, Map.merge(item, %{"status" => "PENDING_APPROVAL"})))
      |> Ecto.Multi.insert(
        {:user_log, index},
        UserLog.changeset(%UserLog{}, %{
          user_id: user.id,
          activity: "saved consignment order on sales number: \"#{item["sale_order"]}\""
        })
      )
    end)
    |> Enum.reduce(Ecto.Multi.new(), &Ecto.Multi.append/2)
    |> Ecto.Multi.update(:update_batch, Batch.changeset(batch, %{status: "C"}))
  end

  # def submit_consignment(conn, %{
  #       "entries" => params,
  #       "batch" => id,
  #       "client_id" => _client_id,
  #       "sale_order" => _sale_order
  #     }) do
  #   conn.assigns.user
  #   |> handle_save(params)
  #   |> Repo.transaction()
  #   |> case do
  #     {:ok, _} ->
  #       Rms.Order.update_batch(Rms.Order.get_batch!(id), %{status: "C"})
  #       # Rms.Emails.Email.send_consignment_initized(client_id, sale_order)

  #       json(conn, %{"info" => "sucesss"})

  #     {:error, _failed_operation, failed_value, _changes_so_far} ->
  #       reason = traverse_errors(failed_value.errors) |> List.first()

  #       json(conn, %{"error" => "#{reason}"})
  #   end
  # end

  # defp handle_save(user, params) do
  #   items = Map.values(params) |> Enum.reject(&(&1["wagon_id"] == nil))

  #   Enum.with_index(items, 1)
  #   |> Enum.map(fn {item, index} ->
  #     entry =
  #       if(to_string(item["id"]) == "",
  #         do: %Consignment{maker_id: user.id},
  #         else: Consignments.get_consignment!(item["id"])
  #       )

  #     item = %{item | "station_code" => String.replace(item["station_code"], ~r/[[:blank:]]/, "")}

  #     Ecto.Multi.new()
  #     |> Ecto.Multi.insert_or_update(
  #       {:consignment, index},
  #       Consignment.changeset(entry, Map.merge(item, %{"status" => "PENDING_APPROVAL"}))
  #     )
  #     |> Ecto.Multi.insert(
  #       {:user_log, index},
  #       UserLog.changeset(%UserLog{}, %{
  #         user_id: user.id,
  #         activity:
  #           "Submited consignment order on sales number: \"#{item["sale_order"]}\" for verification"
  #       })
  #     )
  #   end)
  #   |> Enum.reduce(Ecto.Multi.new(), &Ecto.Multi.append/2)
  # end

  def verify_consignment_entries(conn, params) do
    batch = Order.get_by_uuid(params["batch_id"])
    empty_commodity = SystemUtilities.empty_commodity_lookup().id
    batch_items = Order.list_batch_items(batch.id, empty_commodity)
    clients = Accounts.list_tbl_clients()
    stations = SystemUtilities.list_tbl_station()
    commodity = SystemUtilities.list_tbl_commodity()
    railway_administrator = Accounts.list_tbl_railway_administrator()
    rate = SystemUtilities.list_company_info()

    render(conn, "verify_consignment_entries.html",
      batch_no: params["batch"],
      batch_id: params["batch_id"],
      batch_items: batch_items,
      clients: clients,
      stations: stations,
      commodity: commodity,
      stations: stations,
      railway_administrator: railway_administrator,
      rate: rate
    )
  end

  def verification_consignment(conn, %{"batch" => id, "status" => status}) do
    items = Rms.Order.get_consignment_batch_items(id)

    conn.assigns.user
    |> handle_verification(items, status)
    |> Repo.transaction()
    |> case do
      {:ok, _} ->
        case status do
          "REJECTED" ->
            Rms.Order.update_batch(Rms.Order.get_batch!(id), %{status: "O"})

            Rms.Emails.Email.rejected_consignment(id)

          "PENDING_APPROVAL" ->
            Rms.Order.update_batch(Rms.Order.get_batch!(id), %{status: "V"})
        end

        json(conn, %{"info" => "sucesss"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        json(conn, %{"error" => "#{reason}"})
    end
  end

  defp handle_verification(user, items, status) do
    Enum.with_index(items, 1)
    |> Enum.map(fn {item, index} ->
      Ecto.Multi.new()
      |> Ecto.Multi.update(
        {:consignment, index},
        Consignment.changeset(item, %{"status" => status, "verifier_id" => user.id})
      )
      |> Ecto.Multi.insert(
        {:user_log, index},
        UserLog.changeset(%UserLog{}, %{
          user_id: user.id,
          activity:
            "Modified consignment order on sales number: \"#{item.sale_order}\" to #{status}"
        })
      )
    end)
    |> Enum.reduce(Ecto.Multi.new(), &Ecto.Multi.append/2)
  end

  def approve_consignment_entries(conn, params) do
    batch = Order.get_by_uuid(params["batch_id"])
    empty_commodity = SystemUtilities.empty_commodity_lookup().id
    batch_items = Order.list_batch_items(batch.id, empty_commodity)
    clients = Accounts.list_tbl_clients()
    stations = SystemUtilities.list_tbl_station()
    commodity = SystemUtilities.list_tbl_commodity()
    railway_administrator = Accounts.list_tbl_railway_administrator()
    rate = SystemUtilities.list_company_info()

    render(conn, "approve_consignment_entries.html",
      batch_items: batch_items,
      clients: clients,
      stations: stations,
      commodity: commodity,
      stations: stations,
      railway_administrator: railway_administrator,
      rate: rate
    )
  end

  def approval_consignment(conn, %{"batch" => id, "status" => status, "reason" => reason}) do
    items = Rms.Order.get_consignment_batch_items(id)

    conn.assigns.user
    |> handle_approval(items, status, reason)
    |> Repo.transaction()
    |> case do
      {:ok, _} ->
        case status do
          "REJECTED" ->
            Rms.Order.update_batch(Rms.Order.get_batch!(id), %{status: "R"})

          "PENDING_INVOICE" ->
            Rms.Order.update_batch(Rms.Order.get_batch!(id), %{status: "COMPT"})

            # Rms.Emails.Email.send_consignment_approved( consignment_smry["customer_id"], consignment_smry["sale_order"])
        end

        json(conn, %{"info" => "sucesss"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        json(conn, %{"error" => "#{reason}"})
    end
  end

  defp handle_approval(user, items, status, reason) do
    Enum.with_index(items, 1)
    |> Enum.map(fn {item, index} ->
      comment = if(reason == "", do: item.comment, else: reason)

      Ecto.Multi.new()
      |> Ecto.Multi.insert_or_update(
        {:consignment, index},
        Consignment.changeset(item, %{
          "status" => status,
          "checker_id" => user.id,
          "comment" => comment
        })
      )
      |> Ecto.Multi.insert(
        {:user_log, index},
        UserLog.changeset(%UserLog{}, %{
          user_id: user.id,
          activity:
            "Modified consignment order on sales number: \"#{item.sale_order}\" to #{status}"
        })
      )
    end)
    |> Enum.reduce(Ecto.Multi.new(), &Ecto.Multi.append/2)
  end

  def discard_consignment(conn, %{"batch" => id}) do
    items = Rms.Order.get_consignment_batch_items(id)

    conn.assigns.user
    |> handle_discard(items)
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

  defp handle_discard(user, items) do
    Enum.with_index(items, 1)
    |> Enum.map(fn {item, index} ->
      Ecto.Multi.new()
      |> Ecto.Multi.update(
        {:consignment, index},
        Consignment.changeset(item, %{status: "DISCARDED", checker_id: user.id})
      )
      |> Ecto.Multi.insert(
        {:user_log, index},
        UserLog.changeset(%UserLog{}, %{
          user_id: user.id,
          activity: "Discarded order on sales number: \"#{item.sale_order}\" "
        })
      )
    end)
    |> Enum.reduce(Ecto.Multi.new(), &Ecto.Multi.append/2)
  end

  def pending_consign_lookup(conn, _params) do
    consignment = Rms.Consignments.pending_consign_lookup()
    json(conn, %{"data" => List.wrap(consignment)})
  end

  def consignment_batch_report(conn, _params) do
    render(conn, "consignment_batch_report.html")
  end

  def customer_based_consignment_list(conn, _params) do
    render(conn, "customer_base_consignment_list.html")
  end

  def haulage_export(conn, _params) do
    render(conn, "haulage_export.html")
  end

  def consignment_report_batch_lookup(conn, params) do
    {draw, start, length, search_params} = InterchangeController.search_options(params)
    empty_commodity = SystemUtilities.empty_commodity_lookup().id

    results =
      Rms.Order.consignment_report_lookup(
        search_params,
        start,
        length,
        conn.assigns.user,
        empty_commodity
      )

    total_entries = InterchangeController.total_entries(results)

    results = %{
      draw: draw,
      recordsTotal: total_entries,
      recordsFiltered: total_entries,
      data: InterchangeController.entries(results)
    }

    json(conn, results)
  end

  def consignment_batch_entries(conn, params) do
    batch_items = Rms.Order.list_consignment_batch_item(params["batch"])
    wagons = SystemUtilities.list_tbl_wagon()
    clients = Accounts.list_tbl_clients()
    tariff_line = SystemUtilities.list_tbl_tariff_line()
    stations = SystemUtilities.list_tbl_station()
    commodity = SystemUtilities.list_tbl_commodity()
    # consignments = Consignments.list_tbl_consignments()
    railway_administrator = Accounts.list_tbl_railway_administrator()
    currency = SystemUtilities.list_tbl_currency()
    rate = SystemUtilities.list_company_info()

    render(conn, "consignment_report_batch_entries.html",
      batch_no: params["batch"],
      batch_id: params["batch_id"],
      batch_items: batch_items,
      # consignments: consignments,
      currency: currency,
      clients: clients,
      stations: stations,
      commodity: commodity,
      stations: stations,
      tariff_line: tariff_line,
      wagons: wagons,
      railway_administrator: railway_administrator,
      rate: rate
    )
  end

  def consignment_verifcation_batches(conn, _params) do
    render(conn, "verifcation_batches.html")
  end

  def consignment_approval_batches(conn, _params) do
    render(conn, "approval_batches.html")
  end

  def consignment_invoice_batches(conn, _params) do
    render(conn, "invoice_batches.html")
  end

  def invoice_consignment_entries(conn, params) do
    batch = Order.get_by_uuid(params["batch_id"])
    empty_commodity = SystemUtilities.empty_commodity_lookup().id
    batch_items = Order.list_batch_items(batch.id, empty_commodity)

    wagons = SystemUtilities.list_tbl_wagon()

    currency =
      SystemUtilities.list_tbl_currency()
      |> Enum.reject(&(&1.id != SystemUtilities.list_company_info().prefered_ccy_id))

    clients = Accounts.list_tbl_clients()
    tariff_line = SystemUtilities.list_tbl_tariff_line()
    stations = SystemUtilities.list_tbl_station()
    commodity = SystemUtilities.list_tbl_commodity()
    # consignments = Consignments.list_tbl_consignments()
    railway_administrator = Accounts.list_tbl_railway_administrator()
    rate = SystemUtilities.list_company_info()
    collection_types = SystemUtilities.list_tbl_collection_types()

    render(conn, "invoice_consignment_entries.html",
      batch_no: params["batch"],
      batch_id: params["batch_id"],
      batch_items: batch_items,
      # consignments: consignments,
      clients: clients,
      stations: stations,
      commodity: commodity,
      stations: stations,
      tariff_line: tariff_line,
      wagons: wagons,
      currency: currency,
      railway_administrator: railway_administrator,
      rate: rate,
      collection_types: collection_types
    )
  end

  def consignment_invoicing(conn, %{"batch" => id, "status" => status} = params) do
    items = Rms.Order.get_consignment_batch_items(id)

    conn.assigns.user
    |> handle_invoicing(items, status, params)
    |> Repo.transaction()
    |> case do
      {:ok, _} ->
        json(conn, %{"info" => "sucesss"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        json(conn, %{"error" => "#{reason}"})
    end
  end

  defp handle_invoicing(user, items, status, params) do
    Enum.with_index(items, 1)
    |> Enum.map(fn {item, index} ->
      Ecto.Multi.new()
      |> Ecto.Multi.insert_or_update(
        {:consignment, index},
        Consignment.changeset(item, Map.merge(params, %{"acc_checker_id" => user.id}))
      )
      |> Ecto.Multi.insert(
        {:user_log, index},
        UserLog.changeset(%UserLog{}, %{
          user_id: user.id,
          activity:
            "Modified consignment order on sales number: \"#{item.sale_order}\" to #{status}"
        })
      )
    end)
    |> Enum.reduce(Ecto.Multi.new(), &Ecto.Multi.append/2)
  end

  def consignment_batch_lookup(conn, %{"status" => status}) do
    user = conn.assigns.user
    empty_commodity = SystemUtilities.empty_commodity_lookup().id
    consignment = Rms.Order.consignment_batch_lookup(status, user, empty_commodity)
    json(conn, %{"data" => List.wrap(consignment)})
  end

  def monthly_income_summary(conn, params) do
    user = conn.assigns.user
    company = SystemUtilities.list_company_info()
    unmatched_period = company.unmatched_aging_period

    start_dt = params["start_date"] || Timex.today() |> to_string()
    end_dt = params["end_date"] || Timex.today() |> to_string()

    summary =
      Order.monthly_income_summary(start_dt, end_dt, unmatched_period, user)
      |> format_monthly_income_summary()

    total_amount =
      Enum.reduce(summary, 0, fn {_key, results}, acc ->
        acc + Enum.reduce(results, 0, &(Decimal.to_float(&1.amount) + &2))
      end)

    total_tonnages =
      Enum.reduce(summary, 0, fn {_key, results}, acc ->
        acc + Enum.reduce(results, 0, &(Decimal.to_float(&1.tonnages) + &2))
      end)

    total_wagons =
      Enum.reduce(summary, 0, fn {_key, results}, acc ->
        Decimal.add(acc, Enum.reduce(results, 0, &Decimal.add(&1.wagons, &2)))
      end)

    total_rate =
      Enum.reduce(summary, 0, fn {_key, results}, acc ->
        acc + Enum.reduce(results, 0, &(Decimal.to_float(&1.rate) + &2))
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

  def monthly_income_generate_pdf(conn, %{
        "start_dt" => start_dt,
        "end_dt" => end_dt,
        "type" => type
      }) do
    unmatched_period = SystemUtilities.list_company_info().unmatched_aging_period
    user = conn.assigns.user

    entries = Order.monthly_income_summary(start_dt, end_dt, unmatched_period, user)
    content = Rms.Workers.ConsignmentMonthlyIncome.generate(entries, start_dt, end_dt, type)

    conn =
      conn
      |> put_resp_header(
        "content-disposition",
        "attachment; filename=monthly_income_summary_#{Timex.today()}.pdf"
      )
      |> put_resp_content_type("text/pdf")

    send_resp(conn, 200, content)
  end

  def haulage_invoice(conn, params) do
    user = conn.assigns.user
    company = SystemUtilities.list_company_info()
    unmatched_period = company.unmatched_aging_period

    start_dt = params["start_date"] || Timex.today() |> to_string()
    end_dt = params["end_date"] || Timex.today() |> to_string()

    summary =
      Order.haulage_invoice_report(start_dt, end_dt, unmatched_period, user)
      |> format_haulage_summary()

    total_amount =
      Enum.reduce(summary, 0, fn {_key, results}, acc ->
        acc + Enum.reduce(results, 0, &(Decimal.to_float(&1.amount) + &2))
      end)

    total_tonnages =
      Enum.reduce(summary, 0.00, fn {_key, results}, acc ->
        acc + Enum.reduce(results, 0, &(Decimal.to_float(&1.tonnages) + &2))
      end)

    total_km =
      Enum.reduce(summary, 0, fn {_key, results}, acc ->
        acc + Enum.reduce(results, 0, &(Decimal.to_float(&1.tonnages_per_km) + &2))
      end)

    # total_rate = Enum.reduce(summary, 0, fn {_key, results}, acc -> acc + Enum.reduce(results, 0, &(Decimal.to_float(&1.tonnages_per_km) + &2)) end)
    summary =
      Map.new(summary, fn {key, results} ->
        total =
          Enum.reduce(results, %{total_km: 0, total_amount: 0, total_tonnage: 0}, fn result,
                                                                                     acc ->
            %{
              acc
              | total_km: Decimal.add(acc.total_km, result.tonnages_per_km),
                total_amount: Decimal.add(acc.total_amount, result.amount),
                total_tonnage: Decimal.add(acc.total_tonnage, result.tonnages)
            }
          end)

        results = Enum.map(results, &Map.merge(&1, total))
        {key, results}
      end)

    render(conn, "haulage_invoice.html",
      summary: summary,
      total_amount: total_amount,
      total_tonnages: total_tonnages,
      total_km: total_km,
      # total_rate: total_rate,
      start_date: start_dt,
      end_date: end_dt,
      company: company
    )
  end

  defp format_haulage_summary(entries) do
    entries
    |> Enum.reject(&is_nil(&1.tonnages_per_km))
    |> Enum.group_by(& &1.transport_type)
    |> Enum.into(%{}, fn {trans_type, entries} ->
      entries =
        Enum.group_by(entries, & &1.commodity_id)
        |> Enum.map(fn {_com_id, vals} ->
          entry =
            Enum.reduce(vals, fn val, acc ->
              val_fields = [
                :amount,
                :rate,
                :tarrif_rate_count,
                :tonnages,
                :tonnages_per_km,
                :wagons
              ]

              Map.merge(acc, val, fn key, v1, v2 ->
                if Enum.member?(val_fields, key), do: Decimal.add(v1, v2), else: v2
              end)
            end)

          %{entry | rate: Decimal.div(entry.rate, entry.tarrif_rate_count)}
        end)

      {trans_type, entries}
    end)
  end

  def haulage_invoice_generate_pdf(conn, %{"start_dt" => start_dt, "end_dt" => end_dt}) do
    unmatched_period = SystemUtilities.list_company_info().unmatched_aging_period
    user = conn.assigns.user
    entries = Order.haulage_invoice_report(start_dt, end_dt, unmatched_period, user)
    content = Rms.Workers.HaulageInvoice.generate(entries, start_dt, end_dt)

    conn =
      conn
      |> put_resp_header(
        "content-disposition",
        "attachment; filename=haulage_invoice_#{Timex.today()}.pdf"
      )
      |> put_resp_content_type("text/pdf")

    send_resp(conn, 200, content)
  end

  def unmatched_aging(conn, params) do
    user = conn.assigns.user
    company = SystemUtilities.list_company_info()
    unmatched_period = company.unmatched_aging_period

    start_dt = params["start_date"] || Timex.today() |> to_string()
    end_dt = params["end_date"] || Timex.today() |> to_string()

    summary =
      Order.unmatched_unaging(start_dt, end_dt, unmatched_period, user)
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

    render(conn, "unmatched_aging.html",
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

  def unmatched_aging_generate_pdf(conn, %{"start_dt" => start_dt, "end_dt" => end_dt}) do
    unmatched_period = SystemUtilities.list_company_info().unmatched_aging_period
    user = conn.assigns.user

    entries = Order.unmatched_unaging(start_dt, end_dt, unmatched_period, user)
    content = Rms.Workers.UnmatchedAging.generate(entries, start_dt, end_dt)

    conn =
      conn
      |> put_resp_header(
        "content-disposition",
        "attachment; filename=unmatched_aging_#{Timex.today()}.pdf"
      )
      |> put_resp_content_type("text/pdf")

    send_resp(conn, 200, content)
  end

  def search_for_consignment(conn, %{"station_code" => station_code, "wagon" => wagon_id}) do
    consignment = Rms.Order.search_for_consignment_by_station_code(wagon_id, station_code)
    json(conn, %{"data" => consignment})
  end

  # def mvt_search_for_consignment(conn, %{"station_code" => station_code, "wagon" => wagon_id}) do
  #   consignment = Rms.Order.test_consgsign_search(wagon_id, station_code)
  #   json(conn, %{"data" => consignment})
  # end

  def lookup_consignment(conn, %{
        "wagon_id" => wagon_id,
        "commodity_id" => commodity_id,
        "destination_id" => destination_id,
        "origin_id" => origin_id,
        "document_date" => document_date,
        "consignee_id" => consignee_id,
        "consigner_id" => consigner_id
      }) do
    consignment =
      Rms.Order.search_for_consignment_order_item(
        commodity_id,
        document_date,
        destination_id,
        origin_id,
        wagon_id,
        consignee_id,
        consigner_id
      )

    json(conn, %{"data" => consignment})
  end

  def excel_exp(conn, %{"report_type" => "INVOICING_LIST"}) do
    user = conn.assigns.user
    entries = Rms.Order.consignment_batch_lookup_excel("PENDING_INVOICE", user)

    conn
    |> put_resp_content_type("text/xlsx")
    |> put_resp_header(
      "content-disposition",
      "attachment; filename=CONSIGNMENT_REPORT_#{Timex.today()}.xlsx"
    )
    |> render("report.xlsx", %{entries: entries, user: user, report_type: ""})
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

    Rms.Order.consignment_report_excel(
      source,
      Map.put(search_params, "isearch", ""),
      settings,
      user
    )
  end

  def manual_matching(conn, _params) do
    wagons = SystemUtilities.list_tbl_wagon()
    clients = Accounts.list_tbl_clients()
    tariff_line = SystemUtilities.list_tbl_tariff_line()
    stations = SystemUtilities.list_tbl_station()
    commodity = SystemUtilities.list_tbl_commodity()
    railway_administrator = Accounts.list_tbl_railway_administrator()

    render(conn, "manual_matching.html",
      clients: clients,
      stations: stations,
      commodity: commodity,
      stations: stations,
      tariff_line: tariff_line,
      wagons: wagons,
      railway_administrator: railway_administrator
    )
  end

  def manual_matching_report_lookup(conn, params) do
    {draw, start, length, search_params} = InterchangeController.search_options(params)

    user = conn.assigns.user

    unmatched_period = SystemUtilities.list_company_info().unmatched_aging_period

    results =
      Rms.Order.manual_matching_report_lookup(
        search_params,
        start,
        length,
        unmatched_period,
        user
      )

    total_entries = InterchangeController.total_entries(results)

    results = %{
      draw: draw,
      recordsTotal: total_entries,
      recordsFiltered: total_entries,
      data: InterchangeController.entries(results)
    }

    json(conn, results)
  end

  def manual_matching_excel_exp(conn, params) do
    entries = process_manual_matching_report(conn, @current, params)
    user = conn.assigns.user

    conn
    |> put_resp_content_type("text/xlsx")
    |> put_resp_header(
      "content-disposition",
      "attachment; filename=UNMATCHED_CONSIGNMENT_REPORT_#{Timex.today()}.xlsx"
    )
    |> render("report.xlsx", %{entries: entries, user: user, report_type: ""})
  end

  defp process_manual_matching_report(conn, source, params) do
    user = conn.assigns.user
    unmatched_period = SystemUtilities.list_company_info().unmatched_aging_period
    params |> Map.delete("_csrf_token")

    Rms.Order.manual_matching_report_lookup(
      source,
      Map.put(params, "isearch", ""),
      unmatched_period,
      user
    )
    |> Repo.all()
  end

  def unmatched_movement_lookup(conn, %{"id" => id}) do
    consignment = Consignments.get_consignment!(id)

    movement_list =
      Rms.Order.get_related_movement_items(
        consignment.commodity_id,
        consignment.document_date,
        consignment.final_destination_id,
        consignment.origin_station_id,
        consignment.wagon_id,
        consignment.consignee_id,
        consignment.consigner_id
      )

    json(conn, %{"data" => movement_list})
  end

  def manual_match_entries(conn, %{
        "consignment_id" => consignment_id,
        "movenment_id" => movenment_id
      }) do
    consignment = Consignments.get_consignment!(consignment_id)
    movenment = Rms.Order.get_movement!(movenment_id)

    Ecto.Multi.new()
    |> Ecto.Multi.update(
      :consignment,
      Consignment.changeset(consignment, %{manual_matching: "YES"})
    )
    |> Ecto.Multi.update(
      :movement,
      Movement.changeset(movenment, %{manual_matching: "YES", consignment_id: consignment_id})
    )
    |> Ecto.Multi.insert(
      :user,
      UserLog.changeset(%UserLog{}, %{
        user_id: conn.assigns.user.id,
        activity:
          "manual matched consignment on sales number: \"#{consignment.sale_order}\" and train list number: \"#{movenment.train_list_no}\""
      })
    )
    |> Repo.transaction()
    |> case do
      {:ok, _} ->
        json(conn, %{"info" => "sucesss"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        json(conn, %{"error" => "#{reason}"})
    end
  end

  def modify_consignment(conn, params) do
    batch = Order.get_by_uuid(params["batch_id"])
    empty_commodity = SystemUtilities.empty_commodity_lookup().id
    batch_items = Order.list_batch_items(batch.id, empty_commodity)
    wagons = SystemUtilities.list_tbl_wagon() |> Enum.reject(&(&1.status != "A"))

    currency =
      SystemUtilities.list_tbl_currency()
      |> Enum.reject(&(&1.id != SystemUtilities.list_company_info().prefered_ccy_id))

    clients = Accounts.list_tbl_clients() |> Enum.reject(&(&1.status != "A"))
    tariff_line = SystemUtilities.list_tbl_tariff_line() |> Enum.reject(&(&1.status != "A"))
    stations = SystemUtilities.list_tbl_station() |> Enum.reject(&(&1.status != "A"))
    commodity = SystemUtilities.list_tbl_commodity() |> Enum.reject(&(&1.status != "A"))
    # consignments = Consignments.list_tbl_consignments()
    railway_administrator =
      Accounts.list_tbl_railway_administrator() |> Enum.reject(&(&1.status != "A"))

    rate = SystemUtilities.list_company_info()
    collection_types = SystemUtilities.list_tbl_collection_types()

    render(conn, "modify_consignment_entries.html",
      batch_no: params["batch"],
      batch_id: params["batch_id"],
      batch_items: batch_items,
      # consignments: consignments,
      clients: clients,
      stations: stations,
      commodity: commodity,
      stations: stations,
      tariff_line: tariff_line,
      wagons: wagons,
      currency: currency,
      railway_administrator: railway_administrator,
      rate: rate,
      collection_types: collection_types
    )
  end

  def update_movement_item(conn, params) do
    item = Consignments.get_consignment!(params["id"])

    Ecto.Multi.new()
    |> Ecto.Multi.update(
      :update,
      Consignment.changeset(item, Map.merge(params, %{"modifier_id" => conn.assigns.user.id}))
    )
    |> Ecto.Multi.run(:user_log, fn _, %{update: update} ->
      activity =
        "Updated Consignment item in Sales order number \"#{update.sale_order}\" wagon Id \"#{update.wagon_id}\""

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

  def update_movement_entries(conn, %{"entries" => params}) do
    conn.assigns.user
    |> handle_update_movement(params)
    |> Repo.transaction()
    |> case do
      {:ok, _} ->
        json(conn, %{"info" => "sucesss"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        json(conn, %{"error" => "#{reason}"})
    end
  end

  defp handle_update_movement(user, params) do
    items = Map.values(params) |> Enum.reject(&(&1["wagon_id"] == nil))

    Enum.with_index(items, 1)
    |> Enum.map(fn {item, index} ->
      entry = Consignments.get_consignment!(item["id"])

      item = %{item | "station_code" => String.replace(item["station_code"], ~r/[[:blank:]]/, "")}

      Ecto.Multi.new()
      |> Ecto.Multi.insert_or_update(
        {:consignment, index},
        Consignment.changeset(entry, Map.merge(item, %{"modifier_id" => user.id}))
      )
      |> Ecto.Multi.insert(
        {:user_log, index},
        UserLog.changeset(%UserLog{}, %{
          user_id: user.id,
          activity:
            "Updated consignment order on sales number: \"#{item["sale_order"]}\" with wagon ID: \"#{item["wagon_id"]}\""
        })
      )
    end)
    |> Enum.reduce(Ecto.Multi.new(), &Ecto.Multi.append/2)
  end

  def consignment_pending_approval(conn, _params) do
    user = conn.assigns.user
    empty_commodity = SystemUtilities.empty_commodity_lookup().id
    consignments = Order.con_batch_lookup(user, empty_commodity)
    render(conn, "consignment_pending_approval.html", consignments: consignments)
  end

  def consignment_pending_approval_entries(conn, params) do
    empty_commodity = SystemUtilities.empty_commodity_lookup().id
    batch = Order.get_by_uuid(params["batch_id"])
    batch_items = Order.list_batch_items(batch.id, empty_commodity)
    wagons = SystemUtilities.list_tbl_wagon()
    clients = Accounts.list_tbl_clients()
    tariff_line = SystemUtilities.list_tbl_tariff_line()
    stations = SystemUtilities.list_tbl_station()
    commodity = SystemUtilities.list_tbl_commodity()
    railway_administrator = Accounts.list_tbl_railway_administrator()
    rate = SystemUtilities.list_company_info()

    render(conn, "consignment_pending_entries.html",
      batch_items: batch_items,
      clients: clients,
      stations: stations,
      commodity: commodity,
      stations: stations,
      tariff_line: tariff_line,
      wagons: wagons,
      railway_administrator: railway_administrator,
      rate: rate
    )
  end

  def search_client_name(conn, %{"search" => search_term, "page" => start}) do
    results = Rms.Accounts.search_client("%#{search_term}%", String.to_integer(start))
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

  def search_commodity(conn, %{"search" => search_term, "page" => start}) do
    results = SystemUtilities.search_commoditty("%#{search_term}%", String.to_integer(start))
    total_count = if(length(results) > 0, do: List.first(results).total_count, else: 0)

    json(conn, %{
      results: Enum.map(results, &Map.delete(&1, :total_count)),
      total_count: total_count
    })
  end

  def con_recon_report(conn, _params) do
    render(conn, "con_recon_report.html")
  end

  def con_wagon_querry_report(conn, _params) do
    render(conn, "con_wagon_querry_report.html")
  end

  def consign_delivery_note(conn, %{"id" => batch_id}) do
    item = Order.consignment_delivery_note_lookup(batch_id)
    content = Rms.Workers.ConsignDeliveryNote.generate(item)

    conn =
      conn
      |> put_resp_header(
        "content-disposition",
        "attachment; filename=consignment_delivery_note#{Timex.today()}.pdf"
      )
      |> put_resp_content_type("text/pdf")

    send_resp(conn, 200, content)
  end


  def station_code_lookup(conn, %{"station_code" => station_code}) do
    code = Rms.Order.station_code_lookup(String.trim(station_code))
    json(conn, code)
  end


  def traverse_errors(errors) do
    for {key, {msg, _opts}} <- errors, do: "#{key} #{msg}"
  end

  def authorize(conn) do
    case Phoenix.Controller.action_name(conn) do
      act
      when act in ~w(approval_consignment consignment_approval_batches consignment_batch_lookup)a ->
        {:consignment, :approval_consignment}

      act
      when act in ~w(consignment_approval_batches approve_consignment_entries consignment_batch_lookup)a ->
        {:consignment, :consignment_approval_batches}

      act when act in ~w(consignment_draft draft save_consignment)a ->
        {:consignment, :consignment_draft}

      act when act in ~w(consignment_invoice_batches invoice_consignment_entries)a ->
        {:consignment, :consignment_invoice_batches}

      act
      when act in ~w(consignment_invoice_batches invoice_consignment_entries consignment_invoicing)a ->
        {:consignment, :consignment_invoicing}

      act when act in ~w(consignment_verifcation_batches)a ->
        {:consignment, :consignment_verifcation_batches}

      act
      when act in ~w(consignment_verifcation_batches verify_consignment_entries verification_consignment)a ->
        {:consignment, :consignment_verifcation_batches}

      act
      when act in ~w(new_consignment consign_delivery_note batch_entries submit_consignment consignment_pending_approval_entries consignment_pending_approval)a ->
        {:consignment, :new_consignment}

      act when act in ~w(haulage_invoice haulage_invoice_generate_pdf)a ->
        {:consignment, :haulage_invoice}

      act when act in ~w(monthly_income_summary monthly_income_generate_pdf)a ->
        {:consignment, :monthly_income_summary}

      act when act in ~w(unmatched_aging unmatched_aging_generate_pdf)a ->
        {:consignment, :unmatched_aging}

      act when act in ~w(rejected_consignment consignment_draft save_consignment)a ->
        {:consignment, :rejected_consignment}

      act when act in ~w(approval_consignment)a ->
        {:consignment, :rejection}

      act when act in ~w(discard_consignment)a ->
        {:consignment, :discard_consignment}

      act
      when act in ~w(consignment_batch_report consignment_batch_entries con_wagon_querry_report con_recon_report customer_based_consignment_list excel_exp consignment_report_batch_lookup manual_matching_excel_exp unmatched_movement_lookup manual_matching_report_lookup manual_match_entries manual_matching haulage_export)a ->
        {:consignment, :consignment_batch_report}

      act when act in ~w(modify_consignment update_movement_entries update_movement_item)a ->
        {:consignment, :modify_consignment}

      _ ->
        {:consignment, :unknown}
    end
  end
end
