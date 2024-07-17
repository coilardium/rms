defmodule RmsWeb.InterchangeView do
  use RmsWeb, :view

  alias Elixlsx.{Workbook, Sheet}
  alias Rms.SystemUtilities.{Wagon, Station}
  alias RmsWeb.InterchangeController

  @headers [
    ["Wagon No.", bg_color: "#f6e004", bold: true],
    ["Wagon Type", bg_color: "#f6e004", bold: true],
    ["Wagon Owner", bg_color: "#f6e004", bold: true],
    ["Wagon Condition", bg_color: "#f6e004", bold: true],
    ["Wagon Status", bg_color: "#f6e004", bold: true],
    ["Origin Station", bg_color: "#f6e004", bold: true],
    ["Destination Station", bg_color: "#f6e004", bold: true],
    ["Commodity", bg_color: "#f6e004", bold: true],
    ["Train No.", bg_color: "#f6e004", bold: true],
    ["Interchange Point", bg_color: "#f6e004", bold: true],
    ["Administrator", bg_color: "#f6e004", bold: true],
    ["Direction", bg_color: "#f6e004", bold: true],
    ["On Hire Date", bg_color: "#f6e004", bold: true],
    ["Off hire Date", bg_color: "#f6e004", bold: true],
    ["Current Station", bg_color: "#f6e004", bold: true],
    ["Region", bg_color: "#f6e004", bold: true],
    ["Domain", bg_color: "#f6e004", bold: true],
    ["Status", bg_color: "#f6e004", bold: true],
    ["Exit Date", bg_color: "#f6e004", bold: true],
    ["Entry Date", bg_color: "#f6e004", bold: true],
    ["Lease Period", bg_color: "#f6e004", bold: true],
    ["Accumulated Days", bg_color: "#f6e004", bold: true],
    ["Accumulated Amount", bg_color: "#f6e004", bold: true],
    ["Total Days", bg_color: "#f6e004", bold: true]
  ]

  @material_headers [
    ["Administrator", bg_color: "#f6e004", bold: true],
    ["Equipment", bg_color: "#f6e004", bold: true],
    ["Cost", bg_color: "#f6e004", bold: true],
    ["Direction", bg_color: "#f6e004", bold: true],
    ["Date Received", bg_color: "#f6e004", bold: true],
    ["Date Sent", bg_color: "#f6e004", bold: true],
    ["Date Created", bg_color: "#f6e004", bold: true],
    ["Date Modified", bg_color: "#f6e004", bold: true]
  ]

  @auxiliary_headers [
    ["Administrator", bg_color: "#f6e004", bold: true],
    ["Equipment", bg_color: "#f6e004", bold: true],
    ["Equipment ID", bg_color: "#f6e004", bold: true],
    ["Entry Wagon", bg_color: "#f6e004", bold: true],
    ["Interchange Point", bg_color: "#f6e004", bold: true],
    ["Current Station", bg_color: "#f6e004", bold: true],
    ["Rate Pay Day", bg_color: "#f6e004", bold: true],
    ["Accumulated days", bg_color: "#f6e004", bold: true],
    ["Total Cost", bg_color: "#f6e004", bold: true],
    ["Direction", bg_color: "#f6e004", bold: true],
    ["Date Received", bg_color: "#f6e004", bold: true],
    ["Date Sent", bg_color: "#f6e004", bold: true],
    ["Off Hire Date", bg_color: "#f6e004", bold: true],
    ["Total Accumulated days", bg_color: "#f6e004", bold: true],
    ["Date Created", bg_color: "#f6e004", bold: true],
    ["Date Modified", bg_color: "#f6e004", bold: true]
  ]

  @loco_detention_headers [
    ["Interchange Date", bg_color: "#f6e004", bold: true],
    ["Loco No.", bg_color: "#f6e004", bold: true],
    ["Train No.", bg_color: "#f6e004", bold: true],
    ["Arrival Date", bg_color: "#f6e004", bold: true],
    ["Arrival Time", bg_color: "#f6e004", bold: true],
    ["Departure Date", bg_color: "#f6e004", bold: true],
    ["Departure Time", bg_color: "#f6e004", bold: true],
    ["Actual Delay", bg_color: "#f6e004", bold: true],
    ["Grace Period", bg_color: "#f6e004", bold: true],
    ["Chargeable delay", bg_color: "#f6e004", bold: true],
    ["Rate", bg_color: "#f6e004", bold: true],
    ["Amount", bg_color: "#f6e004", bold: true],
    ["Currency", bg_color: "#f6e004", bold: true],
    ["Administrator", bg_color: "#f6e004", bold: true],
    ["Direction", bg_color: "#f6e004", bold: true],
    ["Date Created", bg_color: "#f6e004", bold: true],
    ["Date Modified", bg_color: "#f6e004", bold: true]
  ]

  @loco_detention_summary_headers [
    ["Administrator", bg_color: "#f6e004", bold: true],
    ["Direction", bg_color: "#f6e004", bold: true],
    ["Chargeable delay", bg_color: "#f6e004", bold: true],
    ["Currency", bg_color: "#f6e004", bold: true],
    ["Amount", bg_color: "#f6e004", bold: true]
  ]

  @haulage_headers [
    ["Date", bg_color: "#f6e004", bold: true],
    ["Loco No.", bg_color: "#f6e004", bold: true],
    ["Train No.", bg_color: "#f6e004", bold: true],
    ["Administrator", bg_color: "#f6e004", bold: true],
    ["Number of wagons", bg_color: "#f6e004", bold: true],
    ["Total Wagons", bg_color: "#f6e004", bold: true],
    ["Wagon Ratio", bg_color: "#f6e004", bold: true],
    ["Distance", bg_color: "#f6e004", bold: true],
    ["Rate", bg_color: "#f6e004", bold: true],
    ["Amount", bg_color: "#f6e004", bold: true],
    ["Currency", bg_color: "#f6e004", bold: true],
    ["Observations", bg_color: "#f6e004", bold: true],
    ["Remarks", bg_color: "#f6e004", bold: true],
    ["Direction", bg_color: "#f6e004", bold: true],
    ["Date Created", bg_color: "#f6e004", bold: true],
    ["Date Modified", bg_color: "#f6e004", bold: true]
  ]

  @error_headers [
    ["Wagon Code", bg_color: "#f6e004", bold: true],
    ["Station S/N", bg_color: "#f6e004", bold: true],
    ["Commodity S/N", bg_color: "#f6e004", bold: true],
    ["Train No.", bg_color: "#f6e004", bold: true],
    ["Error Message", bg_color: "#f6e004", bold: true]
  ]

  @mechanical_bill_headers [
    ["Update Date", bg_color: "#f6e004", bold: true],
    ["Wagon Type", bg_color: "#f6e004", bold: true],
    ["Wagon No.", bg_color: "#f6e004", bold: true],
    ["Nature of Defect", bg_color: "#f6e004", bold: true],
    ["Material Used", bg_color: "#f6e004", bold: true],
    ["Catalogue No.", bg_color: "#f6e004", bold: true],
    ["Time Spent", bg_color: "#f6e004", bold: true],
    ["Currency", bg_color: "#f6e004", bold: true],
    ["Cost of Material", bg_color: "#f6e004", bold: true],
    ["Administrator", bg_color: "#f6e004", bold: true]
  ]

  @demurrage_headers [
    ["Wagon No", bg_color: "#f6e004", bold: true],
    ["Wagon Owner", bg_color: "#f6e004", bold: true],
    ["Commodity In", bg_color: "#f6e004", bold: true],
    ["Date Placed", bg_color: "#f6e004", bold: true],
    ["Date Placed Over Weekend", bg_color: "#f6e004", bold: true],
    ["Date OffLoaded", bg_color: "#f6e004", bold: true],
    ["Date Loaded", bg_color: "#f6e004", bold: true],
    ["Date Cleared", bg_color: "#f6e004", bold: true],
    ["Commodity Out", bg_color: "#f6e004", bold: true],
    ["Yard", bg_color: "#f6e004", bold: true],
    ["Sidings", bg_color: "#f6e004", bold: true],
    ["Total", bg_color: "#f6e004", bold: true],
    ["Rate", bg_color: "#f6e004", bold: true],
    ["Charge", bg_color: "#f6e004", bold: true]
  ]

  @works_order_headers [
    ["Client", bg_color: "#f6e004", bold: true],
    ["Wagon No", bg_color: "#f6e004", bold: true],
    ["Wagon Owner", bg_color: "#f6e004", bold: true],
    ["Commodity", bg_color: "#f6e004", bold: true],
    ["Origin Station", bg_color: "#f6e004", bold: true],
    ["Destination Station", bg_color: "#f6e004", bold: true],
    ["Placed / Removed", bg_color: "#f6e004", bold: true],
    ["Order No.", bg_color: "#f6e004", bold: true],
    ["Left Behind/ Supplied", bg_color: "#f6e004", bold: true],
    ["Train No.", bg_color: "#f6e004", bold: true],
    ["Area Name", bg_color: "#f6e004", bold: true],
    ["Driver's Name", bg_color: "#f6e004", bold: true],
    ["Foreman's Name", bg_color: "#f6e004", bold: true],
    ["Time Arrived at Location", bg_color: "#f6e004", bold: true],
    ["Departure Date", bg_color: "#f6e004", bold: true],
    ["Departure Time", bg_color: "#f6e004", bold: true],
    ["Time Out", bg_color: "#f6e004", bold: true],
    ["load Date", bg_color: "#f6e004", bold: true],
    ["Off Loading date", bg_color: "#f6e004", bold: true],
    ["Date On Label", bg_color: "#f6e004", bold: true],
    ["Remarks", bg_color: "#f6e004", bold: true],
    ["Date Created", bg_color: "#f6e004", bold: true],
    ["Date Modified", bg_color: "#f6e004", bold: true]
  ]

  def render("report.xlsx", %{entries: entries, report_type: "MATERIALS_REPORT"}) do
    material_report_generator(entries)
    |> Elixlsx.write_to_memory("report.xlsx")
    |> elem(1)
    |> elem(1)
  end

  def render("report.xlsx", %{entries: entries, report_type: "LOCO_DETENTION_SUMMARY_REPORT"}) do
    loco_detention_summary_report_generator(entries)
    |> Elixlsx.write_to_memory("report.xlsx")
    |> elem(1)
    |> elem(1)
  end

  def render("report.xlsx", %{entries: entries, report_type: "MECHANICAL_BILLS_REPORT"}) do
    mechanical_bills_report_generator(entries)
    |> Elixlsx.write_to_memory("report.xlsx")
    |> elem(1)
    |> elem(1)
  end

  def render("report.xlsx", %{entries: entries, report_type: "DEMURRAGE_REPORT"}) do
    demurrage_report_generator(entries)
    |> Elixlsx.write_to_memory("report.xlsx")
    |> elem(1)
    |> elem(1)
  end

  def render("report.xlsx", %{entries: entries, report_type: "WORKS_ORDER_REPORT"}) do
    works_order_report_generator(entries)
    |> Elixlsx.write_to_memory("report.xlsx")
    |> elem(1)
    |> elem(1)
  end

  def render("report.xlsx", %{entries: entries, report_type: type})
      when type in ~w(INCOMING_AUXILIARY_REPORT OUTGOING_AUXILIARY_REPORT AUXILIARY_DAILY_SUMMARY_REPORT OUTGOING_AUXILIARY_ON_HIRE_REPORT INCOMING_AUXILIARY_ON_HIRE_REPORT),
      do: handle_auxiliary_report(entries, type)

  def render("report.xlsx", %{entries: entries, report_type: type})
      when type in ~w(INCOMING_LOCO_DETENTION_REPORT OUTGOING_LOCO_DETENTION_REPORT),
      do: handle_loco_detention_report(entries, type)

  def render("report.xlsx", %{entries: entries, report_type: type})
      when type in ~w(INCOMING_HAULAGE_REPORT OUTGOING_HAULAGE_REPORT),
      do: handle_haulage_report(entries, type)

  def render("report.xlsx", %{entries: entries}) do
    report_generator(entries)
    |> Elixlsx.write_to_memory("report.xlsx")
    |> elem(1)
    |> elem(1)
  end

  defp handle_auxiliary_report(entries, _type) do
    auxiliary_report_generator(entries)
    |> Elixlsx.write_to_memory("report.xlsx")
    |> elem(1)
    |> elem(1)
  end

  defp handle_loco_detention_report(entries, _type) do
    loco_detention_report_generator(entries)
    |> Elixlsx.write_to_memory("report.xlsx")
    |> elem(1)
    |> elem(1)
  end

  defp handle_haulage_report(entries, _type) do
    haulage_report_generator(entries)
    |> Elixlsx.write_to_memory("report.xlsx")
    |> elem(1)
    |> elem(1)
  end

  def gen_error_upload_excel(%{data: entries}) do
    error_upload_report_generator(entries)
    |> Elixlsx.write_to_memory("report.xlsx")
    |> elem(1)
    |> elem(1)
  end

  def error_upload_report_generator(entries) do
    rows =
      entries
      # |> Enum.sort_by(& &1.uuid)
      |> Enum.map(fn {changeset, {_, index}} -> exception_row(index, changeset) end)
      |> Enum.reduce([], fn row, acc -> acc ++ row end)

    %Workbook{
      sheets: [%Sheet{name: "Exceptions", rows: [@error_headers] ++ rows} |> set_col_width()]
    }
  end

  def report_generator(entries) do
    rows =
      entries
      |> Enum.sort_by(& &1.uuid)
      |> Enum.map(&row(&1))
      |> Enum.reduce([], fn row, acc -> acc ++ row end)

    %Workbook{
      sheets: [%Sheet{name: "Interchange List", rows: [@headers] ++ rows} |> set_col_width()]
    }
  end

  def material_report_generator(entries) do
    rows =
      entries
      |> Enum.sort_by(& &1.id)
      |> Enum.map(&mat_row(&1))
      |> Enum.reduce([], fn row, acc -> acc ++ row end)

    %Workbook{
      sheets: [
        %Sheet{name: "Material List", rows: [@material_headers] ++ rows} |> set_col_width()
      ]
    }
  end

  def loco_detention_summary_report_generator(entries) do
    rows =
      entries
      |> Enum.sort_by(& &1.admin)
      |> Enum.map(&loco_summary_row(&1))
      |> Enum.reduce([], fn row, acc -> acc ++ row end)

    %Workbook{
      sheets: [
        %Sheet{
          name: "Locomotive Detention Summary",
          rows: [@loco_detention_summary_headers] ++ rows
        }
        |> set_col_width()
      ]
    }
  end

  def auxiliary_report_generator(entries) do
    rows =
      entries
      |> Enum.sort_by(& &1.admin_id)
      |> Enum.map(&aux_row(&1))
      |> Enum.reduce([], fn row, acc -> acc ++ row end)

    %Workbook{
      sheets: [
        %Sheet{name: "Material List", rows: [@auxiliary_headers] ++ rows} |> set_col_width()
      ]
    }
  end

  def loco_detention_report_generator(entries) do
    rows =
      entries
      |> Enum.sort_by(& &1.updated_at)
      |> Enum.map(&loco_row(&1))
      |> Enum.reduce([], fn row, acc -> acc ++ row end)

    %Workbook{
      sheets: [
        %Sheet{name: "Locomotive List", rows: [@loco_detention_headers] ++ rows}
        |> set_col_width()
      ]
    }
  end

  def mechanical_bills_report_generator(entries) do
    rows =
      entries
      |> Enum.sort_by(& &1.update_date)
      |> Enum.map(&mechanical_bill_row(&1))
      |> Enum.reduce([], fn row, acc -> acc ++ row end)

    %Workbook{
      sheets: [
        %Sheet{name: "Locomotive List", rows: [@mechanical_bill_headers] ++ rows}
        |> set_col_width()
      ]
    }
  end

  def haulage_report_generator(entries) do
    rows =
      entries
      |> Enum.sort_by(& &1.updated_at)
      |> Enum.map(&haulage_row(&1))
      |> Enum.reduce([], fn row, acc -> acc ++ row end)

    %Workbook{
      sheets: [%Sheet{name: "Haulage List", rows: [@haulage_headers] ++ rows} |> set_col_width()]
    }
  end

  def demurrage_report_generator(entries) do
    rows =
      entries
      |> Enum.sort_by(& &1.id)
      |> Enum.map(&demurrage_row(&1))
      |> Enum.reduce([], fn row, acc -> acc ++ row end)

    %Workbook{
      sheets: [%Sheet{name: "Demurrage", rows: [@demurrage_headers] ++ rows} |> set_col_width()]
    }
  end

  def works_order_report_generator(entries) do
    rows =
      entries
      |> Enum.sort_by(& &1.client_id)
      |> Enum.map(&works_order_row(&1))
      |> Enum.reduce([], fn row, acc -> acc ++ row end)

    %Workbook{
      sheets: [%Sheet{name: "Works Order", rows: [@works_order_headers] ++ rows} |> set_col_width()]
    }
  end

  defp set_col_width(sheet) do
    sheet
    |> Sheet.set_col_width("A", 17.50)
    |> Sheet.set_col_width("B", 14.78)
    |> Sheet.set_col_width("C", 25.33)
    |> Sheet.set_col_width("D", 30.44)
    |> Sheet.set_col_width("E", 30.44)
    |> Sheet.set_col_width("F", 30.44)
    |> Sheet.set_col_width("G", 25.50)
    |> Sheet.set_col_width("H", 30.44)
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
          entry.wagon_condition || ""
        ],
        [
          entry.wagon_status || ""
        ],
        [
          entry.origin || ""
        ],
        [
          entry.destination || ""
        ],
        [
          entry.commodity || ""
        ],
        [
          entry.train_no || ""
        ],
        [
          entry.interchange_pt || ""
        ],
        [
          entry.administrator || ""
        ],
        [
          entry.direction || ""
        ],
        [
          to_string(entry.on_hire_date)
        ],
        [
          to_string(entry.off_hire_date)
        ],
        [
          entry.current_station || ""
        ],
        [
          entry.region || ""
        ],
        [
          entry.domain || ""
        ],
        [
          to_string(entry.status)
        ],
        [
          to_string(entry.exit_date)
        ],
        [
          to_string(entry.entry_date)
        ],
        [
          Number.Delimit.number_to_delimited(entry.lease_period || 0, precision: 0)
        ],
        [
          Number.Delimit.number_to_delimited(entry.accumulative_days || 0, precision: 0)
        ],
        [
          Number.Delimit.number_to_delimited(entry.accumulative_amount || 0, precision: 2)
        ],
        [
          Number.Delimit.number_to_delimited(entry.total_accum_days || 0, precision: 0)
        ]
      ],
      rate_row(entry)
    ]
  end

  def mat_row(entry) do
    [
      [
        [
          entry.administrator || ""
        ],
        [
          entry.equipment || ""
        ],
        [
          "#{entry.symbol} #{Number.Delimit.number_to_delimited(entry.amount || 0, precision: 2)}"
        ],
        [
          entry.direction || ""
        ],
        [
          to_string(entry.date_received)
        ],
        [
          to_string(entry.date_sent)
        ],
        [
          Timex.format!(entry.inserted_at, "%d-%m-%Y %H:%M:%S", :strftime)
        ],
        [
          Timex.format!(entry.updated_at, "%d-%m-%Y %H:%M:%S", :strftime)
        ]
      ]
    ]
  end

  def aux_row(entry) do
    [
      [
        [
          entry.administrator || ""
        ],
        [
          entry.equipment || ""
        ],
        [
          entry.equipment_code || ""
        ],
        [
          entry.wagon_code || ""
        ],
        [
          entry.interchange_point || ""
        ],
        [
          entry.current_station || ""
        ],
        [
          "#{entry.symbol} #{Number.Delimit.number_to_delimited(entry.amount || 0, precision: 2)}"
        ],
        [
          Number.Delimit.number_to_delimited(entry.accumlative_days || 0, precision: 0)
        ],
        [
          "#{entry.symbol} #{Number.Delimit.number_to_delimited(Decimal.mult(entry.amount, entry.accumlative_days), precision: 2)}"
        ],
        [
          entry.direction || ""
        ],
        [
          to_string(entry.received_date)
        ],
        [
          to_string(entry.sent_date)
        ],
        [
          to_string(entry.off_hire_date)
        ],
        [
          Number.Delimit.number_to_delimited(entry.total_accum_days || 0, precision: 0)
        ],
        [
          Timex.format!(entry.inserted_at, "%d-%m-%Y %H:%M:%S", :strftime)
        ],
        [
          Timex.format!(entry.updated_at, "%d-%m-%Y %H:%M:%S", :strftime)
        ]
      ]
    ]
  end

  def loco_row(entry) do
    [
      [
        [
          to_string(entry.interchange_date)
        ],
        [
          RmsWeb.MovementView.locomotives_list(entry)
        ],
        [
          entry.train_no || ""
        ],
        [
          to_string(entry.arrival_date)
        ],
        [
          entry.arrival_time || ""
        ],
        [
          to_string(entry.departure_date)
        ],
        [
          entry.departure_time || ""
        ],
        [
          Number.Delimit.number_to_delimited(entry.actual_delay || 0, precision: 0)
        ],
        [
          Number.Delimit.number_to_delimited(entry.grace_period || 0, precision: 0)
        ],
        [
          Number.Delimit.number_to_delimited(entry.chargeable_delay || 0, precision: 2)
        ],
        [
          Number.Delimit.number_to_delimited(entry.rate || 0, precision: 2)
        ],
        [
          Number.Delimit.number_to_delimited(entry.amount || 0, precision: 2)
        ],
        [
          entry.currency || ""
        ],
        [
          entry.admin || ""
        ],
        [
          entry.direction || ""
        ],
        [
          Timex.format!(entry.inserted_at, "%d-%m-%Y %H:%M:%S", :strftime)
        ],
        [
          Timex.format!(entry.updated_at, "%d-%m-%Y %H:%M:%S", :strftime)
        ]
      ]
    ]
  end

  def loco_summary_row(entry) do
    [
      [
        [
          entry.admin || ""
        ],
        [
          entry.direction || ""
        ],
        [
          Number.Delimit.number_to_delimited(entry.chargeable_delay || 0, precision: 2)
        ],
        [
          entry.currency || ""
        ],
        [
          Number.Delimit.number_to_delimited(entry.amount || 0, precision: 2)
        ]
      ]
    ]
  end

  def haulage_row(entry) do
    [
      [
        [
          to_string(entry.date)
        ],
        [
          RmsWeb.MovementView.locomotives_list(entry)
        ],
        [
          entry.train_no || ""
        ],
        [
          entry.admin || ""
        ],
        [
          entry.total_wagons || ""
        ],
        [
          entry.wagon_grand_total || ""
        ],
        [
          entry.wagon_ratio || ""
        ],
        [
          Number.Delimit.number_to_delimited(entry.distance || 0, precision: 2)
        ],
        [
          Number.Delimit.number_to_delimited(entry.rate || 0, precision: 2)
        ],
        [
          Number.Delimit.number_to_delimited(entry.amount || 0, precision: 2)
        ],
        [
          entry.currency || ""
        ],
        [
          entry.observation || ""
        ],
        [
          entry.comment || ""
        ],
        [
          if entry.direction == "INCOMING" do
            "Incoming Traffic"
          else
            "Outgoing Traffic"
          end
        ],
        [
          Timex.format!(entry.inserted_at, "%d-%m-%Y %H:%M:%S", :strftime)
        ],
        [
          Timex.format!(entry.updated_at, "%d-%m-%Y %H:%M:%S", :strftime)
        ]
      ]
    ]
  end

  def exception_row(_index, changeset) do
    entry = changeset.changes

    [
      [
        [
          entry[:wagon_code] || Wagon.find_by(id: entry.wagon_id).code
        ],
        [
          entry[:station_sn] || Station.find_by(id: entry.current_station_id).station_code
        ],
        [
          entry[:commodity_sn] || ""
        ],
        [
          entry.train_no || entry.train_no
        ],
        [
          "#{InterchangeController.traverse_errors(changeset.errors) |> List.first()}"
        ]
      ]
    ]
  end

  def mechanical_bill_row(entry) do
    [
      [
        [
          to_string(entry.update_date)
        ],
        [
          entry.wagon_symbol || ""
        ],
        [
          entry.wagon_code || ""
        ],
        [
          entry.defect || ""
        ],
        [
          entry.spare || ""
        ],
        [
          entry.cataloge || ""
        ],
        [
          Number.Delimit.number_to_delimited(entry.man_hours || 0, precision: 2)
        ],
        [
          entry.curreny_symbol || ""
        ],
        [
          Number.Delimit.number_to_delimited(entry.defect_cost || 0, precision: 2)
        ],
        [
          entry.admin || ""
        ]
      ]
    ]
  end

  def demurrage_row(entry) do
    [
      [
        [
          entry.wagon_code || ""
        ],
        [
          entry.wagon_owner || ""
        ],
        [
          entry.commodity_in || ""
        ],
        [
          to_string(entry.date_placed)
        ],
        [
          to_string(entry.dt_placed_over_weekend)
        ],
        [
          to_string(entry.date_offloaded)
        ],
        [
          to_string(entry.date_loaded)
        ],
        [
          to_string(entry.date_cleared)
        ],
        [
          entry.commodity_out || ""
        ],
        [
          Number.Delimit.number_to_delimited(entry.yard || 0, precision: 0)
        ],
        [
          Number.Delimit.number_to_delimited(entry.sidings || 0, precision: 0)
        ],
        [
          Number.Delimit.number_to_delimited(entry.total_days || 0, precision: 0)
        ],
        [
          Number.Delimit.number_to_delimited(entry.charge_rate || 0, precision: 2)
        ],
        [
          Number.Delimit.number_to_delimited(entry.total_charge || 0, precision: 2)
        ]
      ]
    ]
  end

  def works_order_row(entry) do
    [
      [
        [
          entry.client || ""
        ],
        [
          entry.wagon_code || ""
        ],
        [
          entry.wagon_owner || ""
        ],
        [
          entry.commodity || ""
        ],
        [
          entry.origin_station || ""
        ],
        [
          entry.destin_station || ""
        ],
        [
          entry.placed || ""
        ],
        [
          entry.order_no || ""
        ],
        [
          entry.supplied || ""
        ],
        [
          entry.train_no || ""
        ],
        [
          entry.area_name || ""
        ],
        [
          entry.driver_name || ""
        ],
        [
          entry.yard_foreman || ""
        ],
        [
          entry.time_arrival || ""
        ],
        [
          to_string(entry.departure_date)
        ],
        [
          entry.departure_time || ""
        ],
        [
          entry.time_out || ""
        ],
        [
          to_string(entry.load_date)
        ],
        [
          to_string(entry.off_loading_date)
        ],
        [
          to_string(entry.date_on_label)
        ],
        [
          entry.comment || ""
        ],
        [
          Timex.format!(entry.inserted_at, "%d-%m-%Y %H:%M:%S", :strftime)
        ],
        [
          Timex.format!(entry.updated_at, "%d-%m-%Y %H:%M:%S", :strftime)
        ]
      ]
    ]
  end

  def rate_row(entry) do
    Rms.SystemUtilities.interchange_defect_spare_lookup(entry.id, entry.adminstrator_id)
    |> Enum.reject(&(&1.amount == nil))
    |> Enum.map_reduce([["Wagon Defects:", bg_color: "#f6042c", bold: true], [:empty]], fn rate,
                                                                                           acc ->
      col = [
        [
          rate.equipment || :empty
        ],
        [
          "#{rate.currency}#{rate.amount && Number.Delimit.number_to_delimited(rate.amount, precision: 2)}"
        ]
      ]

      {col, acc ++ col}
    end)
    |> elem(1)
  end
end
