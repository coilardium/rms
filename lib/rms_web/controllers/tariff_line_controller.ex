defmodule RmsWeb.TariffLineController do
  use RmsWeb, :controller

  alias Rms.SystemUtilities.TariffLine
  alias Rms.SystemUtilities.TariffLineRate
  alias Rms.{Repo, Activity.UserLog}
  alias Rms.{SystemUtilities, Accounts}
  alias RmsWeb.InterchangeController

  plug(
    RmsWeb.Plugs.RequireAuth
    when action not in [:unknown]
  )

  plug(
    RmsWeb.Plugs.EnforcePasswordPolicy
    when action not in [:unknown]
  )

  plug RmsWeb.Plugs.Authenticate,
       [module_callback: &RmsWeb.TariffLineController.authorize/1]
       when action not in [:unknown, :tariff_lookup, :tariff_rate_lookup]

  @current "tbl_tariff_line"

  def index(conn, _params) do
    stations = SystemUtilities.list_tbl_station() |> Enum.reject(&(&1.status != "A"))
    admins = Accounts.list_tbl_railway_administrator() |> Enum.reject(&(&1.status != "A"))
    clients = Accounts.list_tbl_clients() |> Enum.reject(&(&1.status != "A"))
    commodity = SystemUtilities.list_tbl_commodity() |> Enum.reject(&(&1.status != "A"))
    payment_type = SystemUtilities.list_tbl_payment_type() |> Enum.reject(&(&1.status != "A"))

    currency =
      SystemUtilities.list_tbl_currency()
      |> Enum.reject(&(&1.id != SystemUtilities.list_company_info().prefered_ccy_id))

    surcharge = SystemUtilities.list_tbl_surcharge() |> Enum.reject(&(&1.status != "A"))

    render(conn, "index.html",
      stations: stations,
      clients: clients,
      commodity: commodity,
      payment_type: payment_type,
      currency: currency,
      surcharge: surcharge,
      admins: admins
    )
  end

  def customer_tarriffline_lookup(conn, params) do
    {draw, start, length, search_params} = InterchangeController.search_options(params)

    results =
      SystemUtilities.tariff_line_rates_lookup(search_params, start, length, conn.assigns.user)

    total_entries = InterchangeController.total_entries(results)

    results = %{
      draw: draw,
      recordsTotal: total_entries,
      recordsFiltered: total_entries,
      data: InterchangeController.entries(results)
    }

    json(conn, results)
  end

  def tarriffline_excel(conn, params) do
    entries = process_report(conn, @current, params)
    user = conn.assigns.user

    conn
    |> put_resp_content_type("text/xlsx")
    |> put_resp_header(
      "content-disposition",
      "attachment; filename=TARRIFF_LINE_RATES_REPORT_#{Timex.today()}.xlsx"
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
    SystemUtilities.tariff_line_rates_lookup(source, Map.put(search_params, "isearch", ""), user)
  end

  def create(conn, params) do
    conn.assigns.user
    |> handle_create(params)
    |> Repo.transaction()
    |> case do
      {:ok, _} ->
        json(conn, %{info: "Tariff line created successfully"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        json(conn, %{error: reason})
    end
  end

  defp handle_create(user, params) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(:create, TariffLine.changeset(%TariffLine{}, params))
    |> Ecto.Multi.insert(
      {:user_log},
      UserLog.changeset(%UserLog{}, %{
        user_id: user.id,
        activity: "Tariff line created successfully"
      })
    )
    |> handle_rates(params)
  end

  defp handle_rates(muilt, params) do
    items = params["rates"] |> Map.values()

    Ecto.Multi.merge(muilt, fn %{:create => tariff_line} ->
      Enum.with_index(items, 1)
      |> Enum.map(fn {item, index} ->
        Ecto.Multi.new()
        |> Ecto.Multi.insert(
          {:rate, index},
          TariffLineRate.changeset(
            %TariffLineRate{},
            Map.merge(item, %{"tariff_id" => tariff_line.id})
          )
        )
      end)
      |> Enum.reduce(Ecto.Multi.new(), &Ecto.Multi.append/2)
    end)
  end

  def update(conn, %{"entry" => entry, "rates" => rates}) do
    tariff = SystemUtilities.get_tariff_line!(entry["id"])
    user = conn.assigns.user

    handle_update(user, tariff, Map.put(entry, "checker_id", user.id), rates)
    |> Repo.transaction()
    |> case do
      {:ok, _} ->
        json(conn, %{info: "Tariff line created successfully"})

      # conn
      # |> put_flash(:info, "")
      # |> redirect(to: Routes.tariff_line_path(conn, :index))

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        json(conn, %{error: reason})
        # conn
        # |> put_flash(:error, reason)
        # |> redirect(to: Routes.tariff_line_path(conn, :index))
    end
  end

  defp handle_update(user, tariff, entry, rates) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:update, TariffLine.changeset(tariff, entry))
    |> Ecto.Multi.run(:insert, fn repo, %{update: update} ->
      activity = "Updated Tariff line for client \"#{update.client_id}\""

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
    |> handle_rates_update(rates)
  end

  defp handle_rates_update(muilt, params) do
    items = params |> Map.values()

    Ecto.Multi.merge(muilt, fn %{:update => tariff_line} ->
      Enum.with_index(items, 1)
      |> Enum.map(fn {item, index} ->
        entry =
          if(to_string(item["id"]) == "",
            do: %TariffLineRate{},
            else: SystemUtilities.get_tariff_line_rate!(item["id"])
          )

        Ecto.Multi.new()
        |> Ecto.Multi.insert_or_update(
          {:rate, index},
          TariffLineRate.changeset(entry, Map.merge(item, %{"tariff_id" => tariff_line.id}))
        )
      end)
      |> Enum.reduce(Ecto.Multi.new(), &Ecto.Multi.append/2)
    end)
  end

  def change_status(conn, %{"id" => id} = params) do
    tariff = SystemUtilities.get_tariff_line!(id)
    user = conn.assigns.user

    handle_change_status(user, tariff, Map.put(params, "checker_id", user.id))
    |> Repo.transaction()
    |> case do
      {:ok, %{update: _update, insert: _insert}} ->
        json(conn, %{"info" => "Changes applied successfully!"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        json(conn, %{"error" => reason})
    end
  end

  defp handle_change_status(user, tariff, params) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:update, TariffLine.changeset(tariff, params))
    |> Ecto.Multi.run(:insert, fn repo, %{update: update} ->
      activity = "Updated Tariff line for client \"#{update.client_id}\""

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  def delete(conn, %{"id" => id}) do
    SystemUtilities.get_tariff_line!(id)
    |> handle_delete(conn.assigns.user)
    |> Repo.transaction()
    |> case do
      {:ok, %{del: _del, user_log: _user_log}} ->
        conn |> json(%{"info" => "Tariff line deleted successfully."})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        conn |> json(%{"error" => reason})
    end
  end

  defp handle_delete(tariff, user) do
    Ecto.Multi.new()
    |> Ecto.Multi.delete(:del, tariff)
    |> Ecto.Multi.run(:user_log, fn repo, %{del: del} ->
      activity = "Deleted Tariff line for client \"#{del.client_id}\""

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  def traverse_errors(errors) do
    for {key, {msg, _opts}} <- errors, do: "#{key} #{msg}"
  end

  def tariff_lookup(conn, %{
        "client_id" => client_id,
        "orign_station" => orign_station,
        "destin_station" => destin_station,
        "commodity" => commodity,
        "date" => date
      }) do
    consignment =
      Rms.SystemUtilities.tariffline_lookup(
        client_id,
        orign_station,
        destin_station,
        commodity,
        date
      )

    json(conn, %{"data" => List.wrap(consignment)})
  end

  def tariff_rate_lookup(conn, %{"id" => id}) do
    rate = Rms.SystemUtilities.tariff_line_rate_lookup(id)
    tariff = Rms.SystemUtilities.tariff_line_item_look(id)

    json(conn, %{"data" => List.wrap(rate), "tariff" => tariff})
  end

  def delete_tariff_rate(conn, %{"id" => id}) do
    SystemUtilities.get_tariff_line_rate!(id)
    |> handle_delete_tariff_rate(conn.assigns.user)
    |> Repo.transaction()
    |> case do
      {:ok, %{del: _del, user_log: _user_log}} ->
        conn |> json(%{"info" => "Tariff line deleted successfully."})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        conn |> json(%{"error" => reason})
    end
  end

  defp handle_delete_tariff_rate(tariff, user) do
    Ecto.Multi.new()
    |> Ecto.Multi.delete(:del, tariff)
    |> Ecto.Multi.run(:user_log, fn repo, %{del: del} ->
      activity =
        "Deleted Tariff line  rate for Tariff line  \"#{del.tariff_id}\" for Admin \"#{del.admin_id}\" with rate \"#{del.rate}\" "

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  def authorize(conn) do
    case Phoenix.Controller.action_name(conn) do
      act when act in ~w(new create)a ->
        {:tariff_line, :create}

      act when act in ~w(index customer_tarriffline_lookup tarriffline_excel)a ->
        {:tariff_line, :index}

      act when act in ~w(update delete_tariff_rate edit)a ->
        {:tariff_line, :edit}

      act when act in ~w(change_status)a ->
        {:tariff_line, :change_status}

      act when act in ~w(delete)a ->
        {:tariff_line, :delete}

      _ ->
        {:tariff_line, :unknown}
    end
  end

  @headers ~w/client_id commodity_id category orig_station_id destin_station_id pay_type_id currency_id old_rate rate33 surcharge_id unko_rat rate rate55 notherrate2 start_dt2 start_dt /a

  def extract_xlsx(path) do
    case Xlsxir.multi_extract(path, 0, false, extract_to: :memory) do
      {:ok, id} ->
        items =
          Xlsxir.get_list(id)
          |> Enum.reject(&Enum.empty?/1)
          |> Enum.reject(&Enum.all?(&1, fn item -> is_nil(item)
        end))
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
  #     {:error, reason} ->
  #       {:error, reason}
  #   end
  # end
      {:error, reason} ->
        {:error, reason}
    end
  end

  defp strgfy_term(term) when is_tuple(term), do: term
  defp strgfy_term(term) when not is_tuple(term), do: String.trim("#{term}")

  def upload_excel(params) do
     params = %{params | start_dt: covert_string_to_date(params.start_dt), surcharge_id: 2 } |> IO.inspect()

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:create, TariffLine.changeset(%TariffLine{status: "A"}, params))
    |> Ecto.Multi.run(:insert, fn repo, %{create: create} ->

      rate = Map.merge(params, %{tariff_id: create.id, admin_id: 3 })

      TariffLineRate.changeset(%TariffLineRate{}, rate)
      |> repo.insert()
    end)

    # |> handle_rates_excel(params)
    |> Repo.transaction()
    |> case do
      {:ok, _} ->
         "Tariff line deleted successfully."

      {:error, failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        IO.inspect(reason)
        IO.inspect(failed_operation)
    end
  end

  # defp handle_rates_excel( muilt, params) do
  #   items = params
  #     Ecto.Multi.merge(muilt, fn %{:create =>  tariff_line} ->
  #       Enum.with_index(items, 1)
  #       # |> Enum.map(fn {item, index} ->

  #         Ecto.Multi.new()

  #       # end)
  #       |> Enum.reduce(Ecto.Multi.new(), &Ecto.Multi.append/2)
  #     end)
  # end

  defp covert_string_to_date(str) do
    str
    |> Timex.parse!("{D}/{0M}/{YYYY}")
    |> Timex.to_date()
  end

  # {:ok, items} = RmsWeb.TariffLineController.extract_xlsx("C:/Users/Admin/Desktop/book2.xlsx")

  # Enum.each(items, fn x -> RmsWeb.TariffLineController.upload_excel(x) end)

  # @headers ~w/code wagon_symbol wagon_type_id owner_id status load_status /a

  # def extract_xlsx(path) do
  #   case Xlsxir.multi_extract(path, 0, false, extract_to: :memory) do
  #     {:ok, id} ->
  #       items =
  #         Xlsxir.get_list(id)
  #         |> Enum.reject(&Enum.empty?/1)
  #         |> Enum.reject(&Enum.all?(&1, fn item -> is_nil(item)
  #       end))
  #         |> List.delete_at(0)
  #         |> Enum.map(
  #           &Enum.zip(
  #             Enum.map(@headers, fn h -> h end),
  #             Enum.map(&1, fn v -> strgfy_term(v) end)
  #           )
  #         )
  #         |> Enum.map(&Enum.into(&1, %{}))
  #         |> Enum.reject(&(Enum.join(Map.values(&1)) == ""))

  #       Xlsxir.close(id)
  #       {:ok, items}

  #     {:error, reason} ->
  #       {:error, reason}
  #   end
  # end

  # defp strgfy_term(term) when is_tuple(term), do: term
  # defp strgfy_term(term) when not is_tuple(term), do: String.trim("#{term}")

  # def upload_excel(params) do
  #   Ecto.Multi.new()
  #   |> Ecto.Multi.insert(:create, TariffLine.changeset(%TariffLine{}, params))
  #   |> Ecto.Multi.run(:insert, fn repo, %{create: create} ->

  #     rate = Map.merge(params, %{tariff_id: create.id })

  #     TariffLineRate.changeset(%TariffLineRate{}, rate)
  #     |> repo.insert()
  #   end)

  #   # |> handle_rates_excel(params)
  #   |> Repo.transaction()
  #   |> IO.inspect()
  # end

  # defp handle_rates_excel( muilt, params) do
  #   items = params
  #     Ecto.Multi.merge(muilt, fn %{:create =>  tariff_line} ->
  #       Enum.with_index(items, 1)
  #       # |> Enum.map(fn {item, index} ->

  #         Ecto.Multi.new()

  #       # end)
  #       |> Enum.reduce(Ecto.Multi.new(), &Ecto.Multi.append/2)
  #     end)
  # end

  # {:ok, items} = RmsWeb.TariffLineController.extract_xlsx("C:/Users/Admin/Desktop/book2.xlsx")

  # Enum.each(items, fn x -> RmsWeb.TariffLineController.upload_excel(x) end)

  # {:ok, items} = RmsWeb.TariffLineController.extract_xlsx("D:/wagon.xlsx")

  # Enum.each(items, fn x -> RmsWeb.TariffLineController.handle_create(x) end)

  # def handle_create(params) do

  #   Ecto.Multi.new()
  #   |> Ecto.Multi.insert(:create,  Rms.SystemUtilities.Wagon.changeset(%Rms.SystemUtilities.Wagon{}, params))
  #   |> Ecto.Multi.run(:user_log, fn repo, %{create: create} ->
  #     activity = "New Wagon created with code \"#{create.code}\""

  #     user_log = %{
  #       user_id: 1,
  #       activity: activity
  #     }

  #     UserLog.changeset(%UserLog{}, user_log)
  #     |> repo.insert()
  #   end)
  #   |> IO.inspect()
  #   |> Repo.transaction()
  # end

  # def handle_save(items) do

  #   Enum.with_index(items, 1)
  #   |> Enum.map(fn {item, index} ->
  #     Ecto.Multi.new()
  #     |> Ecto.Multi.insert_or_update({:consignment, index}, Rms.SystemUtilities.Wagon.changeset(%Rms.SystemUtilities.Wagon{maker_id: 1}, item))

  #   end)
  #   |> Enum.reduce(Ecto.Multi.new(), &Ecto.Multi.append/2)
  # end
end
