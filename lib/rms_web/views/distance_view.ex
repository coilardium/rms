defmodule RmsWeb.DistanceView do
  use RmsWeb, :view
  alias Elixlsx.{Workbook, Sheet}

  @headers [
    ["Origin Station", bg_color: "#f6e004", bold: true],
    ["Distination Station", bg_color: "#f6e004", bold: true],
    ["Distance", bg_color: "#f6e004", bold: true],
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
      sheets: [%Sheet{name: "Distances", rows: [@headers] ++ rows} |> set_col_width()]
    }
  end

  defp set_col_width(sheet) do
    sheet
    |> Sheet.set_col_width("A", 20.00)
    |> Sheet.set_col_width("B", 20.00)
    |> Sheet.set_col_width("C", 25.33)
    |> Sheet.set_col_width("D", 25.44)
    |> Sheet.set_col_width("E", 16.50)
    |> Sheet.set_col_width("F", 20.50)
    |> Sheet.set_col_width("G", 25.50)
  end

  def row(entry) do
    [
      [
        [
          entry.station_origin_name || ""
        ],
        [
          entry.station_destin_name || ""
        ],
        [
          Number.Delimit.number_to_delimited(entry.distance || 0, precision: 2)
        ],
        [
          "#{entry.maker_first_name} #{entry.maker_lastname}"
        ],
        [
          "#{entry.checker_first_name} #{entry.checker_lastname}"
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
