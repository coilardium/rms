defmodule Rms.Workers.FuelSectionSummary do
  def generate(entry, start_date, end_date) do
    summary = entry |> Enum.group_by(& &1.section)
    details = prepare_details(summary, start_date, end_date)
    template = read_template(summary)

    template
    |> :bbmustache.render(details, key_type: :binary)
    |> PdfGenerator.generate_binary!()
  end

  defp read_template(summary) do
    html =
      Application.app_dir(:rms, "priv/static/pdf_templates/fuel_section_summary.html.eex")
      |> File.read!()

    summary =
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

    all_entries =
      Enum.map(summary, fn {name, sections} ->
        section = """
          <tr>
            <td> #{name} </td>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
          </tr>
        
        """

        totals = """
              <tr>
                <td ></td>
                <td></td>
                <td></td>
                <td>#{Number.Delimit.number_to_delimited(hd(sections).total_refuel || 0, precision: 2)}</td>
                <td>#{Number.Delimit.number_to_delimited(hd(sections).total_cost || 0, precision: 2)}</td>
              </tr>
        """

        html_str =
          Enum.map(sections, fn section ->
            entry_details = %{
              "section" => to_string(section.section),
              "week" => to_string(section.week || 0),
              "qty_refueled" =>
                to_string(
                  Number.Delimit.number_to_delimited(section.qty_refueled || 0, precision: 2)
                ),
              "total_cost" =>
                to_string(
                  Number.Delimit.number_to_delimited(section.total_cost || 0, precision: 2)
                )
            }

            """
            <tr>
              <td style=" font-weight: normal !important; text-"></td>
              <td style=" font-weight: normal !important; text-"></td>
              <td style=" font-weight: normal !important;">{{ week }}</td>
              <td style=" font-weight: normal !important;">{{ qty_refueled }} </td>
              <td style=" font-weight: normal !important;">{{ total_cost }} </td>
            </tr>
            """
            |> :bbmustache.render(entry_details, key_type: :binary)
          end)

        "#{section}#{html_str}#{totals}"
      end)

    all_entries = "<tbody>" <> Enum.join(all_entries, "") <> "</tbody>"
    String.replace(html, "<tbody></tbody>", all_entries)
  end

  def prepare_details(summary, start_date, end_date) do
    company = Rms.SystemUtilities.list_company_info()

    total_cost =
      Number.Delimit.number_to_delimited(
        Enum.reduce(summary, 0, fn {_key, results}, acc ->
          acc + Enum.reduce(results, 0, &(Decimal.to_float(&1.total_cost) + &2))
        end) || 0,
        precision: 0
      )

    total_refuel =
      Number.Delimit.number_to_delimited(
        Enum.reduce(summary, 0, fn {_key, results}, acc ->
          acc + Enum.reduce(results, 0, &(Decimal.to_float(&1.qty_refueled) + &2))
        end) || 0,
        precision: 0
      )

    %{
      "total_refuel" => total_refuel,
      "total_cost" => total_cost,
      "start_date" => Timex.format!(Date.from_iso8601!(start_date), "%A, %B %e, %Y", :strftime),
      "end_date" => Timex.format!(Date.from_iso8601!(end_date), "%A, %B %e, %Y", :strftime),
      "campany_name" => company.company_name,
      "company_address" => company.company_address
    }
  end
end
