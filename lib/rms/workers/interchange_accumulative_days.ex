defmodule Rms.Workers.InterchangeAccumulativeDays do
  alias Rms.Tracking
  alias Rms.Tracking.Interchange
  alias Rms.{SystemUtilities, Emails.Email, Notifications}
  alias RmsWeb.InterchangeController
  alias Rms.Tracking.{Auxiliary, WagonTracking}
  alias Rms.Repo
  require Logger

  def wagons_on_hire() do
    case Tracking.list_interchange_on_hire() do
      [] ->
        IO.inspect("----No wagons are on hire !!!-----")

      items ->
        handle_on_hire_wagon_update(items)
    end
  end

  def handle_on_hire_wagon_update(items) do
    Enum.with_index(items, 1)
    |> Enum.map(fn {item, index} ->
      accumulative_days = item.accumulative_days + 1
      total_accum_days = item.total_accum_days + 1

      chargeable_days = total_accum_days - (item.lease_period || 0)
      accumulative_amount = Decimal.mult(item.rate, chargeable_days)

      Ecto.Multi.new()
      |> Ecto.Multi.update(
        {:interchange, index},
        Interchange.changeset(item, %{
          "accumulative_days" => accumulative_days,
          "total_accum_days" => total_accum_days,
          "accumulative_amount" => accumulative_amount
        })
      )
    end)
    |> Enum.reduce(Ecto.Multi.new(), &Ecto.Multi.append/2)
    |> Repo.transaction()
    |> case do
      {:ok, _} ->
        check_over_stayed_wagons()
        wagons_exceeded_half_onhire_period()
        IO.inspect("----Accumulative days updated successfully for all wagons on hire----")

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = InterchangeController.traverse_errors(failed_value.errors) |> List.first()
        Logger.error("------Accumulative  days failed to update due to: \"#{reason}\"----")
        IO.inspect("---Accumulative  days failed to update due to: \"#{reason}\"-----")
    end
  end

  defp check_over_stayed_wagons() do
    settings = SystemUtilities.list_company_info()

    Tracking.list_interchange_on_hire_emailing()
    |> Enum.reject(&(&1.accumulative_days > settings.on_hire_max_period == false))
    |> case do
      [] ->
        IO.inspect("-----No Wagons have exceeded on hire period------")

      result ->
        send_alert(result, "EXCEEDED")
    end
  end

  defp wagons_exceeded_half_onhire_period() do
    settings = SystemUtilities.list_company_info()

    Tracking.list_interchange_on_hire_emailing()
    |> Enum.reject(&(&1.accumulative_days > settings.on_hire_max_period == true))
    |> Enum.reject(&(&1.accumulative_days > settings.on_hire_max_period / 2 == false))
    |> case do
      [] ->
        IO.inspect("-----No Wagons have exceeded half on hire period------")

      result ->
        send_alert(result, "HALF")
    end
  end

  defp send_alert(result, type) do
    Notifications.get_email_by("ON_HIRE")
    |> Task.async_stream(&Email.wagons_alert(&1.email, result, type),
      max_concurrency: 10,
      timeout: 30_000
    )
    |> Stream.run()

    {:ok, :sent}
  end

  def auxiliary_on_hire() do
    case Tracking.auxiliary_on_hire_lookup() do
      [] ->
        IO.inspect("-------------No auxiliary are on hire !!!-------------------")

      items ->
        handle_on_hire_auxiliary_update(items)
    end
  end

  defp handle_on_hire_auxiliary_update(items) do
    Enum.with_index(items, 1)
    |> Enum.map(fn {item, index} ->
      accumulative_days = item.accumlative_days + 1
      total_accum_days = item.total_accum_days + 1
      rate = SystemUtilities.get_equipment_rate!(item.equipment_rate_id).rate
      total_amount = Decimal.mult(rate, total_accum_days)

      Ecto.Multi.new()
      |> Ecto.Multi.update(
        {:auxiliary, index},
        Auxiliary.changeset(item, %{
          accumlative_days: accumulative_days,
          total_accum_days: total_accum_days,
          total_amount: total_amount
        })
      )
    end)
    |> Enum.reduce(Ecto.Multi.new(), &Ecto.Multi.append/2)
    |> Repo.transaction()
    |> case do
      {:ok, _} ->
        IO.inspect("-----Accumulative days updated successfully for all auxiliary on hire-----")

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = InterchangeController.traverse_errors(failed_value.errors) |> List.first()
        Logger.error("------Accumulative  days failed to update due to: \"#{reason}\"-----")
        IO.inspect("--Accumulative  days failed to update due to: \"#{reason}\"---")
    end
  end

  def update_wagon_days_at_station() do
    items = Rms.Tracking.list_wagon_tracker_with_wagon_id()

    Enum.with_index(items, 1)
    |> Enum.map(fn {item, index} ->
      entry = Rms.Tracking.get_wagon_tracking!(item)
      total_accum_days = entry.total_accum_days + 1
      days_at = entry.days_at + 1

      Ecto.Multi.new()
      |> Ecto.Multi.update(
        {:wagontracking, index},
        WagonTracking.changeset(entry, %{
          "days_at" => days_at,
          "total_accum_days" => total_accum_days
        })
      )
    end)
    |> Enum.reduce(Ecto.Multi.new(), &Ecto.Multi.append/2)
    |> Repo.transaction()
    |> case do
      {:ok, _} ->
        IO.inspect("---wagon tracking updated successufully---")

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = InterchangeController.traverse_errors(failed_value.errors) |> List.first()
        IO.inspect(reason, label: "----Failed to update wagon tracking---")
    end
  end
end
