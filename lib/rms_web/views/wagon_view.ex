defmodule RmsWeb.WagonView do
  use RmsWeb, :view

  alias Elixlsx.{Workbook, Sheet}

  @headers [
    ["Wagon No.", bg_color: "#f6e004", bold: true],
    ["Wagon Description", bg_color: "#f6e004", bold: true],
    ["Wagon Type", bg_color: "#f6e004", bold: true],
    ["Wagon Owner", bg_color: "#f6e004", bold: true],
    ["Load Status", bg_color: "#f6e004", bold: true],
    ["Movement status", bg_color: "#f6e004", bold: true],
    ["Assigned", bg_color: "#f6e004", bold: true],
    ["Assigned to", bg_color: "#f6e004", bold: true],
    ["Current Position", bg_color: "#f6e004", bold: true],
    ["Condition", bg_color: "#f6e004", bold: true],
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
      |> Enum.sort_by(& &1.owner_id)
      |> Enum.map(&row(&1))
      |> Enum.reduce([], fn row, acc -> acc ++ row end)

    %Workbook{
      sheets: [%Sheet{name: "Wagon Fleet", rows: [@headers] ++ rows} |> set_col_width()]
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
  end

  def row(entry) do
    [
      [
        [
          entry.wagon_code || ""
        ],
        [
          entry.description || ""
        ],
        [
          entry.wagon_type || ""
        ],
        [
          entry.owner || ""
        ],
        [
          if(entry.load_status == "L", do: "Loaded", else: "empty")
        ],
        [
          if(entry.mvt_status == "A", do: "Active", else: "Not Active")
        ],
        [
          entry.assigned || ""
        ],
        [
          entry.client_name || ""
        ],
        [
          entry.station || ""
        ],
        [
          entry.condition || ""
        ],
        [
          "#{entry.maker_ft_name} #{entry.maker_lt_name}"
        ],
        [
          "#{entry.checker_ft_name} #{entry.checker_lt_name}"
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
