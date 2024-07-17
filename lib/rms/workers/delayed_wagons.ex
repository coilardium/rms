defmodule Rms.Workers.DelayedWagons do
  alias Rms.Tracking

  def generate(entry, start_date, end_date) do
    summary = entry |> Enum.group_by(& &1.period)
    details = prepare_details(summary, start_date, end_date)
    template = read_template(summary)

    template
    |> :bbmustache.render(details, key_type: :binary)
    |> PdfGenerator.generate_binary!()
  end

  defp read_template(summary) do
    html =
      Application.app_dir(:rms, "priv/static/pdf_templates/delayed_wagons.html.eex")
      |> File.read!()

    all_entries =
      Enum.map(summary, fn {name, periods} ->
        range =
          case name do
            nil ->
              ""

            _ ->
              """
                <tr>
                  <td style ="text-align: left; text-indent: 30px;"> #{name} </td>
                  <td></td>
                </tr>
              
              """
          end

        html_str =
          case name do
            nil ->
              ""

            _ ->
              Enum.map(periods, fn period ->
                entry_details = %{
                  "period" => to_string(period.period),
                  "status" => to_string(period.status),
                  "count" => to_string(period.count),
                  "status_empty" =>
                    if to_string(period.status) == "E" do
                      "Empty"
                    else
                      "Loaded"
                    end
                }

                """
                
                  <tr>
                
                    <td style=" font-weight: normal !important;"></td>
                    <td style=" font-weight: normal !important;">{{ status_empty }}</td>
                    <td style=" font-weight: normal !important;">{{ count }}</td>
                  </tr>
                """
                |> :bbmustache.render(entry_details, key_type: :binary)
              end)
          end

        "#{range}#{html_str}"
      end)

    all_entries = "<tbody>" <> Enum.join(all_entries, "") <> "</tbody>"
    String.replace(html, "<tbody></tbody>", all_entries)
  end

  def prepare_details(_summary, start_date, end_date) do
    company = Rms.SystemUtilities.list_company_info()

    delayed_wagons =
      Tracking.delayed_wagons_lookup(start_date, end_date)
      |> Enum.reject(&(&1.period == nil))
      |> Enum.group_by(& &1.period)

    grand_total =
      Enum.reduce(delayed_wagons, 0, fn {_key, results}, acc ->
        acc + Enum.reduce(results, 0, &(&1.count + &2))
      end)

    totals = Tracking.count_wagons(start_date, end_date)

    loaded =
      case Enum.find(totals, fn map -> map[:wagon_status] == "L" end) do
        nil -> 0
        loaded -> loaded.count_all
      end

    empty =
      case Enum.find(totals, fn map -> map[:wagon_status] == "E" end) do
        nil -> 0
        empty -> empty.count_all
      end

    tot = Tracking.count_wagons(start_date, end_date) |> Enum.group_by(& &1.wagon_status)

    total =
      Enum.reduce(tot, 0, fn {_key, results}, acc ->
        acc + Enum.reduce(results, 0, &(&1.count_all + &2))
      end)

    %{
      "delayed_wagons" => delayed_wagons,
      "grand_total" => grand_total,
      "loaded" => loaded,
      "empty" => empty,
      "total" => total,
      "start_date" => Timex.format!(Date.from_iso8601!(start_date), "%A, %B %e, %Y", :strftime),
      "end_date" => Timex.format!(Date.from_iso8601!(end_date), "%A, %B %e, %Y", :strftime),
      "campany_name" => company.company_name,
      "company_address" => company.company_address
    }
  end
end
