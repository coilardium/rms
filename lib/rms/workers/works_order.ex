defmodule Rms.Workers.WorksOrder do
  alias Rms.SystemUtilities

  def generate(item) do
    details = prepare_details(item)
    template = read_template(item)

    template
    |> :bbmustache.render(details, key_type: :binary)
    |> PdfGenerator.generate_binary!(
      page_width: "11.695",
      page_height: "8.26772",
      shell_params: ["--orientation", "landscape"]
    )
  end

  defp read_template(item) do

    orders= Rms.Order.works_order_lookup(item.client_id, item.train_no, item.area_name, item.departure_date)
    html =
      Application.app_dir(:rms, "priv/static/pdf_templates/works_order.html.eex")
      |> File.read!()

    html_str =
      Enum.map(orders, fn order ->
        entry_details = %{
          "commodity" => order.commodity,
          "order_no" => order.order_no,
          "wagon_code" => order.wagon_code,
          "origin_station" => order.origin_station,
          "destin_station" => order.destin_station,
          "load_date" => to_string(order.load_date),
          "off_loading_date" => to_string(order.off_loading_date),
          "supplied" => order.supplied,
          "date_on_label" => to_string(order.date_on_label),
          "comment" => order.comment
        }

        """
          <tr>
            <td>{{wagon_code}}</td>
            <td>{{commodity}}</td>
            <td>{{order_no}}</td>
            <td>{{origin_station}}</td>
            <td>{{destin_station}}</td>
            <td>{{load_date}}</td>
            <td>{{off_loading_date}}</td>
            <td>{{supplied}}</td>
            <td>{{date_on_label}}</td>
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
      "date" => Timex.format!(Timex.today(), "%A, %B %e, %Y", :strftime),
      "campany_name" => company.company_name,
      "company_address" => company.company_address,
      "departure_date"  => to_string(item[:departure_date]),
      "area_name" => item[:area_name],
      "client_name" => item[:client],
      "time_arrived" => item[:time_arrival],
      "departure_time"=> item[:departure_time],
      "yard_foreman" => item[:yard_foreman],
      "driver_name"  => item[:driver_name],
      "time_out" => item[:time_out],
      "train_no" => item[:train_no],
      "placed" => if(item[:placed] == "PLACED", do: "&#10003", else: ""),
      "removed" => if(item[:placed] == "REMOVED", do: "&#10003", else: "")
    }
  end
end
