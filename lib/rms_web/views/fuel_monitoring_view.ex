defmodule RmsWeb.FuelMonitoringView do
  use RmsWeb, :view

  alias Elixlsx.{Workbook, Sheet}

  @headers [
    ["Date", bg_color: "#f6e004", bold: true],
    ["Loco #", bg_color: "#f6e004", bold: true],
    ["Loco Type", bg_color: "#f6e004", bold: true],
    ["Train #", bg_color: "#f6e004", bold: true],
    ["Type", bg_color: "#f6e004", bold: true],
    ["Requisition", bg_color: "#f6e004", bold: true],
    ["Seal # at Arrival", bg_color: "#f6e004", bold: true],
    ["Seal # at Departure", bg_color: "#f6e004", bold: true],
    ["Seal color at Arrival", bg_color: "#f6e004", bold: true],
    ["Seal color at Departure", bg_color: "#f6e004", bold: true],
    ["Time", bg_color: "#f6e004", bold: true],
    ["Loco Driver", bg_color: "#f6e004", bold: true],
    ["Commercial Clerk", bg_color: "#f6e004", bold: true],
    ["Balance before Refuel", bg_color: "#f6e004", bold: true],
    ["Authorized CTC", bg_color: "#f6e004", bold: true],
    ["After Refuel", bg_color: "#f6e004", bold: true],
    ["Oil Meter Before", bg_color: "#f6e004", bold: true],
    ["Oil Meter After", bg_color: "#f6e004", bold: true],
    ["Reading", bg_color: "#f6e004", bold: true],
    ["Depo Refueled", bg_color: "#f6e004", bold: true],
    ["Train Destination", bg_color: "#f6e004", bold: true],
    ["Km to Destination", bg_color: "#f6e004", bold: true],
    ["Fuel Consumed", bg_color: "#f6e004", bold: true],
    ["Consumption/km", bg_color: "#f6e004", bold: true],
    ["Week", bg_color: "#f6e004", bold: true],
    ["Section.", bg_color: "#f6e004", bold: true]
  ]

  def render("report.xlsx", %{entries: entries}) do
    report_generator(entries)
    |> Elixlsx.write_to_memory("report.xlsx")
    |> elem(1)
    |> elem(1)
  end

  def report_generator(entries) do
    rows = entries |> Enum.sort_by(& &1.batch_id) |> Enum.map(&row(&1))

    %Workbook{
      sheets: [
        %Sheet{name: "Fuel Requisite Entries", rows: [@headers] ++ rows} |> set_col_width()
      ]
    }
  end

  defp set_col_width(sheet) do
    sheet
    |> Sheet.set_col_width("A", 14.50)
    |> Sheet.set_col_width("B", 14.78)
    |> Sheet.set_col_width("C", 25.33)
    |> Sheet.set_col_width("D", 25.44)
    |> Sheet.set_col_width("E", 16.50)
    |> Sheet.set_col_width("F", 20.50)
    |> Sheet.set_col_width("G", 25.50)
    |> Sheet.set_col_width("H", 20.50)
    |> Sheet.set_col_width("I", 20.50)
    |> Sheet.set_col_width("J", 30.50)
    |> Sheet.set_col_width("K", 25.50)
    |> Sheet.set_col_width("L", 25.50)
    |> Sheet.set_col_width("M", 25.50)
    |> Sheet.set_col_width("N", 25.50)
    |> Sheet.set_col_width("O", 25.50)
    |> Sheet.set_col_width("P", 25.50)
    |> Sheet.set_col_width("Q", 25.50)
    |> Sheet.set_col_width("R", 25.50)
    |> Sheet.set_col_width("S", 25.50)
    |> Sheet.set_col_width("T", 25.50)
    |> Sheet.set_col_width("U", 25.50)
    |> Sheet.set_col_width("V", 25.50)
    |> Sheet.set_col_width("W", 25.50)
    |> Sheet.set_col_width("X", 25.50)
    |> Sheet.set_col_width("Y", 25.50)
    |> Sheet.set_col_width("Z", 25.50)
    |> Sheet.set_col_width("AA", 25.50)
  end

  def row(entry) do
    [
      [
        to_string(entry.date || "")
      ],
      [
        entry.loco_number || ""
      ],
      [
        entry.loco_type || ""
      ],
      [
        entry.train_number || ""
      ],
      [
        entry.refuel_type || ""
      ],
      [
        entry.requisition_no || ""
      ],
      [
        entry.seal_number_at_arrival || ""
      ],
      [
        entry.seal_number_at_depture || ""
      ],
      [
        entry.seal_color_at_arrival || ""
      ],
      [
        entry.seal_color_at_depture || ""
      ],
      [
        entry.time || ""
      ],
      [
        "#{entry.loco_driver_fname || ""} #{entry.loco_driver_srname || ""}"
      ],
      [
        "#{entry.clerk_fname || ""} #{entry.clerk_sname || ""}"
      ],
      [
        Number.Delimit.number_to_delimited(entry.balance_before_refuel || 0, precision: 2)
      ],
      [
        Number.Delimit.number_to_delimited(entry.approved_refuel || 0, precision: 2)
      ],
      [
        Number.Delimit.number_to_delimited(entry.reading_after_refuel || 0, precision: 2)
      ],
      [
        Number.Delimit.number_to_delimited(entry.bp_meter_before || 0, precision: 2)
      ],
      [
        Number.Delimit.number_to_delimited(entry.bp_meter_after || 0, precision: 2)
      ],
      [
        Number.Delimit.number_to_delimited(entry.reading || 0, precision: 2)
      ],
      [
        entry.depo_stn_name || ""
      ],
      [
        entry.train_destination || ""
      ],
      [
        Number.Delimit.number_to_delimited(entry.km_to_destin || 0, precision: 2)
      ],
      [
        Number.Delimit.number_to_delimited(entry.fuel_consumed || 0, precision: 2)
      ],
      [
        Number.Delimit.number_to_delimited(entry.consumption_per_km || 0, precision: 2)
      ],
      [
        entry.week_no || ""
      ],
      [
        entry.section_name || ""
      ]
    ]
  end
end
