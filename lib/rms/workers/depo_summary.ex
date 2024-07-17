defmodule Rms.Workers.DepoSummary do
  def generate(entry, start_date, end_date) do
    summary = entry |> Enum.group_by(& &1.depo)
    details = prepare_details(summary, start_date, end_date)
    template = read_template(summary)

    template
    |> :bbmustache.render(details, key_type: :binary)
    |> PdfGenerator.generate_binary!()
  end

  defp read_template(summary) do
    html =
      Application.app_dir(:rms, "priv/static/pdf_templates/depo_summary.html.eex") |> File.read!()

    all_entries =
      Enum.map(summary, fn {name, depos} ->
        depo = """
          <tr>
            <td> #{name} </td>
            <td></td>
            <td></td>
            <td></td>
          </tr>

        """

        html_str =
          Enum.map(depos, fn depo ->
            entry_details = %{
              "depo" => to_string(depo.depo),
              "count" =>
                to_string(Number.Delimit.number_to_delimited(depo.count || 0, precision: 0)),
              "qty_refueled" =>
                to_string(
                  Number.Delimit.number_to_delimited(depo.qty_refueled || 0, precision: 2)
                ),
              "total_cost" =>
                to_string(Number.Delimit.number_to_delimited(depo.total_cost || 0, precision: 2))
            }

            """
            <tr>
              <td style=" font-weight: normal !important; text-"></td>
              <td style=" font-weight: normal !important; text-"></td>
              <td style=" font-weight: normal !important; text-">{{ count }}</td>
              <td style=" font-weight: normal !important;">{{ qty_refueled }} </td>
              <td style=" font-weight: normal !important;">{{ total_cost }} </td>
            </tr>
            """
            |> :bbmustache.render(entry_details, key_type: :binary)
          end)

        "#{depo}#{html_str}"
      end)

    all_entries = "<tbody>" <> Enum.join(all_entries, "") <> "</tbody>"
    String.replace(html, "<tbody></tbody>", all_entries)
  end

  def prepare_details(summary, start_date, end_date) do
    company = Rms.SystemUtilities.list_company_info()

    total_refuels =
      Enum.reduce(summary, 0, fn {_key, results}, acc ->
        acc + Enum.reduce(results, 0, &(&1.count + &2))
      end)

    qty_refueled =
      Number.Delimit.number_to_delimited(
        Enum.reduce(summary, 0, fn {_key, results}, acc ->
          acc + Enum.reduce(results, 0, &(Decimal.to_float(&1.qty_refueled) + &2))
        end) || 0,
        precision: 0
      )

    total_cost =
      Number.Delimit.number_to_delimited(
        Enum.reduce(summary, 0, fn {_key, results}, acc ->
          acc + Enum.reduce(results, 0, &(Decimal.to_float(&1.total_cost) + &2))
        end) || 0,
        precision: 0
      )

    %{
      "total_refuels" => total_refuels,
      "qty_refueled" => qty_refueled,
      "total_cost" => total_cost,
      "start_date" => Timex.format!(Date.from_iso8601!(start_date), "%A, %B %e, %Y", :strftime),
      "end_date" => Timex.format!(Date.from_iso8601!(end_date), "%A, %B %e, %Y", :strftime),
      "campany_name" => company.company_name,
      "company_address" => company.company_address
    }
  end
end
