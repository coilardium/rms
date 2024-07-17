defmodule Rms.Workers.ConsignDeliveryNote do
  alias Rms.SystemUtilities

  def generate(items) do

    [item | _] = items
    details = prepare_details(item)
    template = read_template(items)

    template
    |> :bbmustache.render(details, key_type: :binary)
    |> PdfGenerator.generate_binary!()
  end

  defp read_template(items) do

    html =
      Application.app_dir(:rms, "priv/static/pdf_templates/consign_delivery_note.html.eex")
      |> File.read!()

    html_str =
      Enum.with_index(items, 1)
      |> Enum.map(fn {order, index} ->
        entry_details = %{
          "sn" => index,
          "wagon_code" => order.wagon_code,
          "wagon_type" => order.wagon_type,
          "wagon_owner" => order.wagon_owner,
          "capacity" => Number.Delimit.number_to_delimited(order.capacity_tonnes|| 0, precision: 2),
          "actual" => Number.Delimit.number_to_delimited(order.actual_tonnes || 0, precision: 2),
        }

        """
          <tr>
            <td scope="row" style="font-size: 13px">{{sn}}</td>
            <td style="font-size: 13px">{{wagon_code}}</td>
            <td style="font-size: 13px">{{wagon_owner}}</td>
            <td style="font-size: 13px">{{wagon_type}}</td>
            <td style="font-size: 13px">{{capacity}}</td>
            <td style="font-size: 13px">{{actual}}</td>
            <td></td>
          </tr>
        """
        |> :bbmustache.render(entry_details, key_type: :binary)
      end)

    html_str = "" <> Enum.join(html_str, "") <> ""
    String.replace(html, "<tbody></tbody>", html_str)
  end

  def prepare_details(item) do
    company = SystemUtilities.list_company_info()

    %{
      "date" => to_string(item.capture_date),
      "campany_name" => company.company_name,
      "company_address" => company.company_address,
      "customer" => item.customer,
      "customer_ref" => item.customer_ref,
      "commodity" => item.commodity,
      "consignee"=> item.consignee,
      "consigner" => item.consigner,
      "origin_station"  => item.origin_station,
      "destin_station" => item.final_destination,
      "station_code" => item.station_code

    }
  end
end
