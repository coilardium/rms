defmodule Rms.Workers.HaulageInvoice do
  def generate(entry, start_date, end_date) do
    summary = entry |> Enum.reject(&is_nil(&1.tonnages_per_km)) |> format_haulage_summary()
    details = prepare_details(summary, start_date, end_date)
    template = read_template(summary)

    template
    |> :bbmustache.render(details, key_type: :binary)
    |> PdfGenerator.generate_binary!()
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

  defp read_template(summary) do
    html =
      Application.app_dir(:rms, "priv/static/pdf_templates/haulage_invoice.html.eex")
      |> File.read!()

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

    all_entries =
      Enum.map(summary, fn {name, types} ->
        transport_type = """
          <tr>
            <td style="font-weight: bold;"> #{name}</td>
            <td></td>
            <td></td>
            <td></td>
          </tr>
        
        """

        totals = """
         <tr>
           <td></td>
           <td></td>
           <td>#{hd(types).total_tonnage}</td>
           <td>#{hd(types).total_km}</td>
           <td>#{hd(types).currency_symbol}#{hd(types).total_amount}</td>
         </tr>
        
        """

        html_str =
          Enum.map(types, fn type ->
            entry_details = %{
              "commodity_type" => to_string(type.commodity_type),
              "tonnages" =>
                to_string(Number.Delimit.number_to_delimited(type.tonnages || 0, precision: 2)),
              "tonnages_per_km" =>
                to_string(
                  Number.Delimit.number_to_delimited(type.tonnages_per_km || 0, precision: 2)
                ),
              "amount" =>
                to_string(
                  "#{type.currency_symbol} #{Number.Delimit.number_to_delimited(type.amount || 0, precision: 2)}"
                )
            }

            """
              <tr>
                <td>{{ commodity_type }}</td>
                <td></td>
                <td>{{ tonnages }}</td>
                <td>{{ tonnages_per_km }}</td>
                <td>{{ amount }}</td>
              </tr>
            """
            |> :bbmustache.render(entry_details, key_type: :binary)
          end)

        "#{transport_type}#{html_str}#{totals}"
      end)

    all_entries = "<tbody>" <> Enum.join(all_entries, "") <> "</tbody>"
    String.replace(html, "<tbody></tbody>", all_entries)
  end

  def prepare_details(summary, start_date, end_date) do
    company = Rms.SystemUtilities.list_company_info()

    total_amount =
      Enum.reduce(summary, 0.00, fn {_key, results}, acc ->
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

    %{
      "total_amount" => Number.Delimit.number_to_delimited(total_amount || 0, precision: 2),
      "total_tonnages" => Number.Delimit.number_to_delimited(total_tonnages || 0, precision: 2),
      "total_km" => Number.Delimit.number_to_delimited(total_km || 0, precision: 2),
      "start_date" => Timex.format!(Date.from_iso8601!(start_date), "%A, %B %e, %Y", :strftime),
      "end_date" => Timex.format!(Date.from_iso8601!(end_date), "%A, %B %e, %Y", :strftime),
      "campany_name" => company.company_name,
      "company_address" => company.company_address
    }
  end
end
