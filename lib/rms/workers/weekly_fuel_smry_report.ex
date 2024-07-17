defmodule Rms.Workers.WeeklyFuelSummaryReport do
  alias Rms.SystemUtilities

  def generate(entry, month, year, weeks, params) do
    summary = entry |> format_weekly_summary()
    details = prepare_details(summary, month, year)
    # template = read_template(weeks)
    map = %{"Name" => "chipasha"}

    weeks
    |> weeks_logs()
    |> read_template(params)
    |> :bbmustache.render(map, key_type: :binary)
    |> PdfGenerator.generate_binary!(page_width: "11.695", page_height: "8.26772")
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

  defp read_template(months, params) do
    template =
      Application.app_dir(:rms, "priv/static/pdf_templates/fuel_weekly_smry_report_pdf.html.eex")
      |> File.read!()

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

    html_headers =
      Enum.map(months, fn week ->
        week_name = %{
          "week" => week["weeks"]
        }

        """
         <td> {{ week }} </td>
        """
        |> :bbmustache.render(week_name, key_type: :binary)
      end)

    html_headers = "" <> Enum.join(html_headers, "") <> ""
    template = String.replace(template, "</weeks>", html_headers)

    categories =
      Enum.map(fuel_summary, fn {category, vals} ->
        cat = """
          <tr style="font-weight: bold;">
            <td>#{category}</td>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
          </tr>
        """

        refuel_types =
          Enum.map(vals, fn {week, results} ->
            Enum.map(results, fn week_entries ->
              """
                <tr>
                <td>#{week_entries.refuel_type}</td>
                <td></td>
                <td>#{if Enum.find_index(months, &(&1 == week)) == 0, do: Number.Delimit.number_to_delimited(week_entries.total_consumed || 0, precision: 2), else: 0}</td>
                <td>#{if Enum.find_index(months, &(&1 == week)) == 1, do: Number.Delimit.number_to_delimited(week_entries.total_consumed || 0, precision: 2), else: 0}</td>
                <td>#{if Enum.find_index(months, &(&1 == week)) == 2, do: Number.Delimit.number_to_delimited(week_entries.total_consumed || 0, precision: 2), else: 0}</td>
                <td>#{if Enum.find_index(months, &(&1 == week)) == 3, do: Number.Delimit.number_to_delimited(week_entries.total_consumed || 0, precision: 2), else: 0}</td>
                <td>#{if Enum.find_index(months, &(&1 == week)) == 4, do: Number.Delimit.number_to_delimited(week_entries.total_consumed || 0, precision: 2), else: 0}</td>
                <td></td>
                </tr>
              """
            end)
          end)

        "#{cat} #{refuel_types}"
      end)

    categories = "" <> Enum.join(categories, "") <> ""
    template = String.replace(template, "</catogory>", categories)

    # total_consumption = Enum.map(total_consumed, fn total ->
    #   IO.inspect(total_consumed, label: "----------------ffffffffffffffffffffffff---------------------")
    #    total_cons =  """

    #       <td>#{Number.Delimit.number_to_delimited(total.total || 0, precision: 0)}</td>
    #     """
    #    "#{total_cons}"
    #   end)

    # total_consumption = "" <> Enum.join(total_consumption, "") <> ""
    # template = String.replace(template, "</totalconsumption>", total_consumption)

    #     <tr>
    #   <td style=" font-weight: normal !important;">Total Consumption</td>
    #   <%= for total <- @total_consumed do %>
    #     <td style="color: #6f727d; font-weight: normal !important;"><%= Number.Delimit.number_to_delimited(total || 0, precision: 2) %></td>
    #   <% end %>
    #   <td>
    #     <%= Number.Delimit.number_to_delimited(Enum.reduce(@total_consumed, 0, &Decimal.add(&1, &2)), precision: 2) %>
    #   </td>
    # </tr>
  end

  def weeks_logs(months) do
    Enum.map(months, fn x ->
      %{
        "weeks" => to_string(x)
      }
    end)
  end

  def prepare_details(summary, month, year) do
    # company =  Rms.SystemUtilities.list_company_info()

    # %{
    #   "start_date" => Timex.format!(Date.from_iso8601!(start_date),"%A, %B %e, %Y", :strftime),
    #   "end_date" => Timex.format!(Date.from_iso8601!(end_date),"%A, %B %e, %Y", :strftime),
    #   "campany_name" => company.company_name,
    #   "company_address" =>  company.company_address
    # }
  end
end
