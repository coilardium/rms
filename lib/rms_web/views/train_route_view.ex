defmodule RmsWeb.TrainRouteView do
  use RmsWeb, :view
  alias Elixlsx.{Workbook, Sheet}

  @headers [
    ["Description", bg_color: "#f6e004", bold: true],
    ["code", bg_color: "#f6e004", bold: true],
    ["Origin Station", bg_color: "#f6e004", bold: true],
    ["Distination Station", bg_color: "#f6e004", bold: true],
    ["Distance", bg_color: "#f6e004", bold: true],
    ["Transport Type", bg_color: "#f6e004", bold: true],
    ["Operator", bg_color: "#f6e004", bold: true],
    ["Maker", bg_color: "#f6e004", bold: true],
    ["Checker", bg_color: "#f6e004", bold: true],
    ["Date Created", bg_color: "#f6e004", bold: true],
    ["Date Updated", bg_color: "#f6e004", bold: true]
  ]

  def render("report.xlsx", %{entries: entries}) do
    report_generator(entries)
    |> Elixlsx.write_to_memory("report.xlsx")
    |> elem(1)
    |> elem(1)
  end

  def report_generator(entries) do
    rows =
      entries
      |> Enum.sort_by(& &1.id)
      |> Enum.map(&row(&1))
      |> Enum.reduce([], fn row, acc -> acc ++ row end)

    %Workbook{
      sheets: [%Sheet{name: "Routes", rows: [@headers] ++ rows} |> set_col_width()]
    }
  end

  defp set_col_width(sheet) do
    sheet
    |> Sheet.set_col_width("A", 40.50)
    |> Sheet.set_col_width("B", 40.50)
    |> Sheet.set_col_width("C", 40.50)
    |> Sheet.set_col_width("D", 40.50)
    |> Sheet.set_col_width("E", 16.50)
    |> Sheet.set_col_width("F", 20.50)
    |> Sheet.set_col_width("G", 25.50)
    |> Sheet.set_col_width("G", 25.50)
    |> Sheet.set_col_width("H", 20.50)
    |> Sheet.set_col_width("I", 20.50)
    |> Sheet.set_col_width("J", 30.50)
    |> Sheet.set_col_width("K", 25.50)
    |> Sheet.set_col_width("L", 25.50)
  end

  def row(entry) do
    [
      [
        [
          entry.description || ""
        ],
        [
          entry.code || ""
        ],
        [
          entry.route_org_station || ""
        ],
        [
          entry.route_dest_station || ""
        ],
        [
          Number.Delimit.number_to_delimited(entry.distance || 0, precision: 2)
        ],
        [
          entry.route_transport_type || ""
        ],
        [
          entry.route_operator || ""
        ],
        [
          "#{entry.maker_frt_name} #{entry.maker_lst_name}"
        ],
        [
          "#{entry.checker_frt_name} #{entry.checker_lst_name}"
        ],
        [
          Timex.format!(entry.inserted_at, "%d/%m/%Y %H:%M:%S", :strftime)
        ],
        [
          Timex.format!(entry.updated_at, "%d/%m/%Y %H:%M:%S", :strftime)
        ]
      ]
    ]
  end
end
