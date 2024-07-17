defmodule RmsWeb.MovementView do
  use RmsWeb, :view
  alias Rms.Accounts.RailwayAdministrator, as: Operator
  alias Elixlsx.{Workbook, Sheet}

  @headers [
    ["Train List No", bg_color: "#f6e004", bold: true],
    ["Train No.", bg_color: "#f6e004", bold: true],
    ["Reporting Station", bg_color: "#f6e004", bold: true],
    ["Reporting DateTime", bg_color: "#f6e004", bold: true],
    ["Wagon No.", bg_color: "#f6e004", bold: true],
    ["Wagon Type", bg_color: "#f6e004", bold: true],
    ["Wagon Owner", bg_color: "#f6e004", bold: true],
    ["Origin", bg_color: "#f6e004", bold: true],
    ["Destination", bg_color: "#f6e004", bold: true],
    ["Commodity", bg_color: "#f6e004", bold: true],
    ["Customer", bg_color: "#f6e004", bold: true],
    ["Consingner", bg_color: "#f6e004", bold: true],
    ["Consignee", bg_color: "#f6e004", bold: true],
    ["Payer", bg_color: "#f6e004", bold: true],
    ["Consignment Date", bg_color: "#f6e004", bold: true],
    ["Station Code", bg_color: "#f6e004", bold: true],
    ["Tariff Origin", bg_color: "#f6e004", bold: true],
    ["Tariff Destination", bg_color: "#f6e004", bold: true],
    ["Transport type", bg_color: "#f6e004", bold: true],
    ["Distance", bg_color: "#f6e004", bold: true],
    ["Currency Code", bg_color: "#f6e004", bold: true],
    ["Invoice No.", bg_color: "#f6e004", bold: true],
    ["Invoice Amount", bg_color: "#f6e004", bold: true],
    ["Invoice Date", bg_color: "#f6e004", bold: true],
    ["Actual Tonnages", bg_color: "#f6e004", bold: true],
    ["Container No.", bg_color: "#f6e004", bold: true],
    ["Sales Order", bg_color: "#f6e004", bold: true]
  ]

  @customer_based_headers [
    ["Customer", bg_color: "#00b0f0", bold: true],
    ["Customer Ref", bg_color: "#00b0f0", bold: true],
    ["Wagon No.", bg_color: "#00b0f0", bold: true],
    ["Capture Date", bg_color: "#00b0f0", bold: true],
    ["Document Date", bg_color: "#00b0f0", bold: true],
    ["Commodity", bg_color: "#00b0f0", bold: true],
    ["Origin", bg_color: "#00b0f0", bold: true],
    ["Destination", bg_color: "#00b0f0", bold: true],
    ["Actual Tonnages", bg_color: "#00b0f0", bold: true],
    ["Tarriff Tonnage", bg_color: "#00b0f0", bold: true],
    ["Distance", bg_color: "#00b0f0", bold: true],
    ["NTK", bg_color: "#00b0f0", bold: true],
    ["CTKM", bg_color: "#00b0f0", bold: true],
    ["Transport Type", bg_color: "#00b0f0", bold: true],
    ["Currency Code", bg_color: "#00b0f0", bold: true],
    ["Rate", bg_color: "#00b0f0", bold: true],
    ["Amount", bg_color: "#00b0f0", bold: true],
    ["Payee", bg_color: "#00b0f0", bold: true],
    ["Train No.", bg_color: "#00b0f0", bold: true],
    ["Reporting Date", bg_color: "#00b0f0", bold: true],
    ["Locomotive No.", bg_color: "#00b0f0", bold: true]
  ]

  @haulage_based_headers [
    ["Wagon Number", bg_color: "#00b0f0", bold: true],
    ["Origin", bg_color: "#00b0f0", bold: true],
    ["Destination", bg_color: "#00b0f0", bold: true],
    ["Actual Tonnages", bg_color: "#00b0f0", bold: true],
    ["Tarriff Tonnage", bg_color: "#00b0f0", bold: true],
    ["Distance", bg_color: "#00b0f0", bold: true],
    ["NTK", bg_color: "#00b0f0", bold: true],
    ["CTKM", bg_color: "#00b0f0", bold: true],
    ["Commodity", bg_color: "#00b0f0", bold: true],
    ["Transport Type", bg_color: "#00b0f0", bold: true],
    ["Currency Code", bg_color: "#00b0f0", bold: true],
    ["Rate", bg_color: "#00b0f0", bold: true],
    ["Amount", bg_color: "#00b0f0", bold: true],
    ["Train No.", bg_color: "#00b0f0", bold: true],
    ["Reporting Date", bg_color: "#00b0f0", bold: true],
    ["Locomotive No.", bg_color: "#00b0f0", bold: true]
  ]

  def render("report.xlsx", %{entries: entries, report_type: "CUSTOMER_BASED_MOVEMENT_REPORT"}) do
    report_generator_cust_based(entries)
    |> Elixlsx.write_to_memory("report.xlsx")
    |> elem(1)
    |> elem(1)
  end

  def render("report.xlsx", %{entries: entries, report_type: "HAULAGE_EXPORT_MOVEMENT_REPORT"}) do
    report_generator_haulage(entries)
    |> Elixlsx.write_to_memory("report.xlsx")
    |> elem(1)
    |> elem(1)
  end

  def render("report.xlsx", %{entries: entries, report_type: "MOVEMENT_RECONCILIATION_REPORT"}) do
    report_generator_recon(entries)
    |> Elixlsx.write_to_memory("report.xlsx")
    |> elem(1)
    |> elem(1)
  end

  def render("report.xlsx", %{entries: entries, report_type: "MOVEMENT_WAGON_QUERRY_REPORT"}) do
    report_generator_wagon_querry(entries)
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
    operators = Operator.all()
    headers = rate_headers(operators)

    rows =
      entries
      |> Enum.sort_by(& &1.batch_id, :asc)
      |> Enum.map(&row(&1, operators))
      |> Enum.reduce([], fn row, acc -> acc ++ row end)

    %Workbook{sheets: [%Sheet{name: "Train List", rows: [headers] ++ rows} |> set_col_width()]}
  end

  def report_generator_recon(entries) do
    operators = Operator.all()
    headers = rate_headers(operators)

    rows =
      entries
      |> Enum.sort_by(& &1.customer_name, :asc)
      |> Enum.map(&row(&1, operators))
      |> Enum.reduce([], fn row, acc -> acc ++ row end)

    %Workbook{
      sheets: [
        %Sheet{name: "Reconciliation report", rows: [headers] ++ rows} |> set_col_width()
      ]
    }
  end

  def report_generator_wagon_querry(entries) do
    operators = Operator.all()
    headers = rate_headers(operators)

    rows =
      entries
      |> Enum.sort_by(& &1.wagon_code, :asc)
      |> Enum.map(&row(&1, operators))
      |> Enum.reduce([], fn row, acc -> acc ++ row end)

    %Workbook{
      sheets: [
        %Sheet{name: "Wagon Querry report", rows: [headers] ++ rows} |> set_col_width()
      ]
    }
  end

  def report_generator_cust_based(entries) do
    rows = entries |> Enum.sort_by(& &1.customer_name, :asc) |> Enum.map(&customer_based_row(&1))

    %Workbook{
      sheets: [
        %Sheet{name: "Customer Based", rows: [@customer_based_headers] ++ rows} |> set_col_width()
      ]
    }
  end

  def report_generator_haulage(entries) do
    rows = entries |> Enum.sort_by(& &1.transport_type, :asc) |> Enum.map(&haulage_row(&1))

    %Workbook{
      sheets: [
        %Sheet{name: "Haulage Export", rows: [@haulage_based_headers] ++ rows} |> set_col_width()
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

  def row(entry, operators) do
    rate_cols = rate_cols(entry.tarrif_id, operators)

    entry_cols = [
      [
        entry.train_list_no || ""
      ],
      [
        entry.train_no || ""
      ],
      [
        entry.reporting_stat || ""
      ],
      [
        "#{to_string(entry.movement_date || "")} #{entry.movement_time || ""}"
      ],
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
        entry.origin_name || ""
      ],
      [
        entry.destination_name || ""
      ],
      [
        entry.commodity_name || ""
      ],
      [
        entry.customer_name || ""
      ],
      [
        entry.consigner_name || ""
      ],
      [
        entry.consignee_name || ""
      ],
      [
        entry.payer || ""
      ],
      [
        to_string(entry.consignment_date || "")
      ],
      [
        entry.station_code || ""
      ],
      [
        entry.tariff_origin || ""
      ],
      [
        entry.tariff_destination || ""
      ],
      [
        entry.transport_type || ""
      ],
      [
        Number.Delimit.number_to_delimited(entry.distance || 0, precision: 2)
      ],
      [
        entry.currency || ""
      ],
      [
        entry.invoice_no || ""
      ],
      [
        Number.Delimit.number_to_delimited(entry.invoice_amount || 0, precision: 2)
      ],
      [
        to_string(entry.invoice_date || "")
      ],
      [
        Number.Delimit.number_to_delimited(entry.tonnages || 0, precision: 2)
      ],
      [
        to_string(entry.containers)
      ],
      [
        entry.sales_order || ""
      ]
    ]

    [entry_cols ++ rate_cols]
  end

  defp rate_cols(tarrif_id, operators) do
    rates =
      case tarrif_id do
        nil -> []
        _ -> Rms.Order.tarrif_rates(tarrif_id)
      end

    operators =
      Enum.reject(operators, &Enum.any?(rates, fn rate -> &1.id == rate.admin_id end))
      |> Enum.map(&%{admin_id: &1.id, rate: 0, admin: &1.code})

    rates
    |> Enum.concat(operators)
    |> Enum.sort(&(&1.admin_id >= &2.admin_id))
    |> Enum.map(fn rate ->
      [
        Number.Delimit.number_to_delimited(rate.rate || 0, precision: 2),
        bg_color: "#D9D9D9",
        bold: true
      ]
    end)
  end

  defp rate_headers(operators) do
    rate_headers =
      operators
      |> Enum.sort(&(&1.id >= &2.id))
      |> Enum.map(&[String.upcase(&1.code), bg_color: "#f6e004", bold: true])

    @headers ++ rate_headers
  end

  def customer_based_row(entry) do
    [
      [
        entry.customer_name || ""
      ],
      [
        entry.station_code || ""
      ],
      [
        entry.wagon_code || ""
      ],
      [
        to_string(entry.capture_date || "")
      ],
      [
        to_string(entry.document_date || "")
      ],
      [
        entry.commodity_name || ""
      ],
      [
        entry.origin_name || ""
      ],
      [
        entry.destination_name || ""
      ],
      [
        Number.Delimit.number_to_delimited(entry.actual_tonnes || 0, precision: 2)
      ],
      [
        Number.Delimit.number_to_delimited(entry.tariff_tonnage || 0, precision: 2)
      ],
      [
        Number.Delimit.number_to_delimited(entry.distance || 0, precision: 2)
      ],
      # [
      #   tonnage_per_km(entry)
      # ],
      [
        tonnage_per_km(entry)
      ],
      [
        ctkm(entry)
      ],
      [
        entry.transport_type || ""
      ],
      [
        entry.rate_ccy || ""
      ],
      [
        Number.Delimit.number_to_delimited(entry.avg_rate || 0, precision: 2)
      ],
      [
        amount(entry)
      ],
      [
        entry.consignee_name || ""
      ],
      [
        entry.train_no || ""
      ],
      [
        "#{entry.movement_date}"
      ],
      [
        locomotives_list(entry)
      ]
    ]
  end

  def haulage_row(entry) do
    [
      [
        entry.wagon_code || ""
      ],
      [
        entry.origin_name || ""
      ],
      [
        entry.destination_name || ""
      ],
      [
        Number.Delimit.number_to_delimited(entry.actual_tonnes || 0, precision: 2)
      ],
      [
        Number.Delimit.number_to_delimited(entry.tariff_tonnage || 0, precision: 2)
      ],
      [
        Number.Delimit.number_to_delimited(entry.distance || 0, precision: 2)
      ],
      # [
      #   tonnage_per_km(entry)
      # ],
      [
        tonnage_per_km(entry)
      ],
      [
        ctkm(entry)
      ],
      [
        entry.commodity_name || ""
      ],
      [
        entry.transport_type || ""
      ],
      [
        entry.rate_ccy || ""
      ],
      [
        Number.Delimit.number_to_delimited(entry.avg_rate || 0, precision: 2)
      ],
      [
        amount(entry)
      ],
      [
        entry.train_no || ""
      ],
      [
        "#{entry.movement_date}"
      ],
      [
        locomotives_list(entry)
      ]
    ]
  end

  defp tonnage_per_km(entry) do
    tonnage =
      cond do
        is_nil(entry.tariff_tonnage) ->
          entry.actual_tonnes || 0

        Decimal.cmp(entry.tariff_tonnage, 0) in [:lt, :eq] ->
          entry.actual_tonnes || 0

        true ->
          entry.tariff_tonnage || 0
      end

    distance = entry.distance || 0
    Decimal.mult(tonnage, distance) |> Number.Delimit.number_to_delimited(precision: 2)
  end

  defp amount(entry) do
    tonnage =
      cond do
        is_nil(entry.tariff_tonnage) ->
          entry.actual_tonnes || 0

        Decimal.cmp(entry.tariff_tonnage, 0) in [:lt, :eq] ->
          entry.actual_tonnes || 0

        true ->
          entry.tariff_tonnage || 0
      end

    rate = entry.avg_rate || 0
    Decimal.mult(tonnage, rate) |> Number.Delimit.number_to_delimited(precision: 2)
  end

  defp ctkm(entry) do
    tonnage =
      cond do
        is_nil(entry.tariff_tonnage) ->
          entry.actual_tonnes || 0

        Decimal.cmp(entry.tariff_tonnage, 0) in [:lt, :eq] ->
          entry.actual_tonnes || 0

        true ->
          entry.tariff_tonnage || 0
      end

    distance = entry.distance || 0
    ntk = Decimal.mult(tonnage, distance)

    case Number.Delimit.number_to_delimited(ntk, precision: 0) do
      "0" -> "0"
      _ -> Decimal.div(entry.amount, ntk) |> Number.Delimit.number_to_delimited(precision: 2)
    end
  end

  def locomotives_list(entry) do
    case entry.loco_no do
      nil ->
        ""

      _ ->
        Poison.decode!(entry.loco_no)
        |> Rms.Locomotives.locomotives_lookup()
        |> Enum.join(" / ")
    end
  end
end
