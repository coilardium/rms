defmodule RmsWeb.WagonTrackingView do
  use RmsWeb, :view
  alias Elixlsx.{Workbook, Sheet}

  @headers [
    ["Wagon No.", bg_color: "#f6e004", bold: true],
    ["Wagon Type", bg_color: "#f6e004", bold: true],
    ["Wagon Owner", bg_color: "#f6e004", bold: true],
    ["Condition", bg_color: "#f6e004", bold: true],
    ["Domain", bg_color: "#f6e004", bold: true],
    ["Region", bg_color: "#f6e004", bold: true],
    ["Bound", bg_color: "#f6e004", bold: true],
    ["Train No.", bg_color: "#f6e004", bold: true],
    ["Customer", bg_color: "#f6e004", bold: true],
    ["Commodity", bg_color: "#f6e004", bold: true],
    ["Origin Station", bg_color: "#f6e004", bold: true],
    ["Current Location", bg_color: "#f6e004", bold: true],
    ["Destination Station", bg_color: "#f6e004", bold: true],
    ["Yard", bg_color: "#f6e004", bold: true],
    ["Upadte Date", bg_color: "#f6e004", bold: true],
    ["On Hire", bg_color: "#f6e004", bold: true],
    ["Days At", bg_color: "#f6e004", bold: true],
    ["Comment", bg_color: "#f6e004", bold: true]
  ]

  @wagon_position_headers [
    ["Domain", bg_color: "#f6e004", bold: true],
    ["Wagon Symbol", bg_color: "#f6e004", bold: true],
    ["Wagon Status", bg_color: "#f6e004", bold: true],
    ["Total", bg_color: "#f6e004", bold: true]
  ]

  @wagon_alocatn_headers [
    ["Customer", bg_color: "#f6e004", bold: true],
    ["Domain", bg_color: "#f6e004", bold: true],
    ["Total", bg_color: "#f6e004", bold: true]
  ]

  @wagon_condition_headers [
    ["Domain", bg_color: "#f6e004", bold: true],
    ["Condition", bg_color: "#f6e004", bold: true],
    ["Total", bg_color: "#f6e004", bold: true]
  ]

  @wagon_yard_headers [
    ["Station", bg_color: "#f6e004", bold: true],
    ["Owner", bg_color: "#f6e004", bold: true],
    ["Commodity", bg_color: "#f6e004", bold: true],
    ["Symbol", bg_color: "#f6e004", bold: true],
    ["Total", bg_color: "#f6e004", bold: true]
  ]

  def render("report.xlsx", %{entries: entries, report_type: "WAGON_POSITION"}) do
    gen_report_wagon_position(entries)
    |> Elixlsx.write_to_memory("report.xlsx")
    |> elem(1)
    |> elem(1)
  end

  def render("report.xlsx", %{entries: entries, report_type: "WAGON_ALLOCATION"}) do
    gen_report_wagon_allocation(entries)
    |> Elixlsx.write_to_memory("report.xlsx")
    |> elem(1)
    |> elem(1)
  end

  def render("report.xlsx", %{entries: entries, report_type: "WAGON_CONDITION"}) do
    gen_wagon_condition_report(entries)
    |> Elixlsx.write_to_memory("report.xlsx")
    |> elem(1)
    |> elem(1)
  end

  def render("report.xlsx", %{entries: entries, report_type: "WAGON_YARD_POSITION"}) do
    gen_wagon_yard_report(entries)
    |> Elixlsx.write_to_memory("report.xlsx")
    |> elem(1)
    |> elem(1)
  end

  def render("report.xlsx", %{entries: entries}) do
    report_generator(entries)
    |> Elixlsx.write_to_memory("report.xlsx")
    |> elem(1)
    |> elem(1)
  end

  def report_generator(entries) do
    rows =
      entries
      |> Enum.sort_by(& &1.condition_id)
      |> Enum.map(&row(&1))
      |> Enum.reduce([], fn row, acc -> acc ++ row end)

    %Workbook{
      sheets: [%Sheet{name: "Wagon Tracking List", rows: [@headers] ++ rows} |> set_col_width()]
    }
  end

  def gen_report_wagon_position(entries) do
    rows =
      entries
      |> Enum.sort_by(& &1.domain)
      |> Enum.map(&wagon_position_row(&1))
      |> Enum.reduce([], fn row, acc -> acc ++ row end)

    %Workbook{
      sheets: [
        %Sheet{name: "Wagon Position", rows: [@wagon_position_headers] ++ rows} |> set_col_width()
      ]
    }
  end

  def gen_report_wagon_allocation(entries) do
    rows =
      entries
      |> Enum.sort_by(& &1.customer)
      |> Enum.map(&wagon_allocation_row(&1))
      |> Enum.reduce([], fn row, acc -> acc ++ row end)

    %Workbook{
      sheets: [
        %Sheet{name: "Wagon Allocation", rows: [@wagon_alocatn_headers] ++ rows}
        |> set_col_width()
      ]
    }
  end

  def gen_wagon_condition_report(entries) do
    rows =
      entries
      |> Enum.sort_by(& &1.domain)
      |> Enum.map(&wagon_condition_row(&1))
      |> Enum.reduce([], fn row, acc -> acc ++ row end)

    %Workbook{
      sheets: [
        %Sheet{name: "Wagon Condition", rows: [@wagon_condition_headers] ++ rows}
        |> set_col_width()
      ]
    }
  end

  def gen_wagon_yard_report(entries) do
    rows =
      entries
      |> Enum.sort_by(& &1.current_location)
      |> Enum.map(&wagon_yard_row(&1))
      |> Enum.reduce([], fn row, acc -> acc ++ row end)

    %Workbook{
      sheets: [
        %Sheet{name: "Wagon Yard Position", rows: [@wagon_yard_headers] ++ rows}
        |> set_col_width()
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
  end

  def row(entry) do
    [
      [
        [
          entry.wagon_code || ""
        ],
        [
          entry.wagon_type || ""
        ],
        [
          entry.wagon_owner || ""
        ],
        [
          entry.condition || ""
        ],
        [
          entry.domain || ""
        ],
        [
          entry.region || ""
        ],
        [
          entry.bound || ""
        ],
        [
          entry.train_no || ""
        ],
        [
          entry.client_name || ""
        ],
        [
          entry.commodity || ""
        ],
        [
          entry.origin_station || ""
        ],
        [
          entry.current_location || ""
        ],
        [
          entry.dest_station || ""
        ],
        [
          entry.yard_siding || ""
        ],
        [
          to_string(entry.update_date || "")
        ],
        [
          entry.on_hire || ""
        ],
        [
          entry.days_at || ""
        ],
        [
          entry.comment || ""
        ]
      ],
      defect_row(entry.id, entry.wagon_id)
    ]
  end

  def wagon_position_row(entry) do
    [
      [
        [
          entry.domain || ""
        ],
        [
          entry.wagon_symbol || ""
        ],
        [
          entry.status || ""
        ],
        [
          entry.count || ""
        ]
      ]
    ]
  end

  def wagon_allocation_row(entry) do
    [
      [
        [
          entry.customer || ""
        ],
        [
          entry.region || ""
        ],
        [
          entry.count || ""
        ]
      ]
    ]
  end

  def wagon_condition_row(entry) do
    [
      [
        [
          entry.domain || ""
        ],
        [
          entry.condition || ""
        ],
        [
          entry.count || ""
        ]
      ]
    ]
  end

  def wagon_yard_row(entry) do
    [
      [
        [
          entry.current_location || ""
        ],
        [
          entry.owner || ""
        ],
        [
          entry.commodity || ""
        ],
        [
          entry.wagon_symbol || ""
        ],
        [
          entry.count || ""
        ]
      ]
    ]
  end

  defp defect_row(id, wagon_id) do
    defects =
      case Rms.SystemUtilities.tracker_entry_lookup(id, wagon_id) do
        nil -> []
        wagon_defect -> get_defects_list(wagon_defect)
      end

    defects
    |> Enum.map_reduce([["Wagon defects:", bg_color: "#f60424", bold: true], [:empty]], fn defect,
                                                                                           acc ->
      col = [
        [
          defect.description || :empty
        ]
      ]

      {col, acc ++ col}
    end)
    |> elem(1)
  end

  defp get_defects_list(wagon_defect) do
    case wagon_defect.defect_ids do
      "null" ->
        []

      nil ->
        []

      defect_list ->
        decode_defects(defect_list)
    end
  end

  defp decode_defects(defect_list) do
    case Poison.decode!(defect_list) do
      [""] ->
        []

      ids ->
        Rms.SystemUtilities.get_defects_by_ids(ids)
    end
  end
end
