defmodule RmsWeb.TariffLineView do
  use RmsWeb, :view
  alias Rms.Accounts.RailwayAdministrator, as: Operator
  alias Elixlsx.{Workbook, Sheet}

  @headers [
    ["Customer", bg_color: "#00b0f0", bold: true],
    ["Origin", bg_color: "#00b0f0", bold: true],
    ["Destination", bg_color: "#00b0f0", bold: true],
    ["Commodity", bg_color: "#00b0f0", bold: true],
    ["Payment Type", bg_color: "#00b0f0", bold: true],
    ["Currency", bg_color: "#00b0f0", bold: true],
    ["Surcharge", bg_color: "#00b0f0", bold: true],
    ["Active From", bg_color: "#00b0f0", bold: true],
    ["Category", bg_color: "#00b0f0", bold: true],
    ["Maker", bg_color: "#00b0f0", bold: true],
    ["Checker", bg_color: "#00b0f0", bold: true],
    ["Date Created", bg_color: "#00b0f0", bold: true],
    ["Date Updated", bg_color: "#00b0f0", bold: true]
  ]

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
      |> Enum.sort_by(& &1.client_id)
      |> Enum.map(&row(&1, operators))
      |> Enum.reduce([], fn row, acc -> acc ++ row end)

    %Workbook{
      sheets: [%Sheet{name: "Tarriff List", rows: [headers] ++ rows} |> set_col_width()]
    }
  end

  defp set_col_width(sheet) do
    sheet
    |> Sheet.set_col_width("A", 30.00)
    |> Sheet.set_col_width("B", 30.00)
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
  end

  def row(entry, operators) do
    rate_cols = rate_cols(entry.id, operators)

    entry_cols = [
      gen_cell(entry.client_name),
      gen_cell(entry.origin_station),
      gen_cell(entry.destin_station),
      gen_cell(entry.commodity),
      gen_cell(entry.payment_type),
      gen_cell(entry.currency),
      gen_cell(entry.surcharge),
      gen_cell(to_string(entry.start_dt)),
      gen_cell(entry.category),
      gen_cell("#{entry.maker_ft_name} #{entry.maker_lt_name}"),
      gen_cell("#{entry.checker_ft_name} #{entry.checker_lt_name}"),
      gen_cell(Timex.format!(entry.inserted_at, "%d/%m/%Y %H:%M:%S", :strftime)),
      gen_cell(Timex.format!(entry.updated_at, "%d/%m/%Y %H:%M:%S", :strftime))
    ]

    [entry_cols ++ rate_cols]
  end

  defp gen_cell(val) when not is_nil(val), do: [val]
  defp gen_cell(_val), do: [:empty]

  defp rate_cols(tarrif_id, operators) do
    rates = Rms.Order.tarrif_rates(tarrif_id)

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
      |> Enum.map(&[String.upcase(&1.code), bg_color: "#00b0f0", bold: true])

    @headers ++ rate_headers
  end
end
