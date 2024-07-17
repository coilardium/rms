defmodule RmsWeb.InterchangeFeeControllerTest do
  use RmsWeb.ConnCase

  alias Rms.SystemUtilities

  @create_attrs %{amount: "120.5", year: "some year"}
  @update_attrs %{amount: "456.7", year: "some updated year"}
  @invalid_attrs %{amount: nil, year: nil}

  def fixture(:interchange_fee) do
    {:ok, interchange_fee} = SystemUtilities.create_interchange_fee(@create_attrs)
    interchange_fee
  end

  describe "index" do
    test "lists all tbl_interchange_fees", %{conn: conn} do
      conn = get(conn, Routes.interchange_fee_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Tbl interchange fees"
    end
  end

  describe "new interchange_fee" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.interchange_fee_path(conn, :new))
      assert html_response(conn, 200) =~ "New Interchange fee"
    end
  end

  describe "create interchange_fee" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn =
        post(conn, Routes.interchange_fee_path(conn, :create), interchange_fee: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.interchange_fee_path(conn, :show, id)

      conn = get(conn, Routes.interchange_fee_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Interchange fee"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn =
        post(conn, Routes.interchange_fee_path(conn, :create), interchange_fee: @invalid_attrs)

      assert html_response(conn, 200) =~ "New Interchange fee"
    end
  end

  describe "edit interchange_fee" do
    setup [:create_interchange_fee]

    test "renders form for editing chosen interchange_fee", %{
      conn: conn,
      interchange_fee: interchange_fee
    } do
      conn = get(conn, Routes.interchange_fee_path(conn, :edit, interchange_fee))
      assert html_response(conn, 200) =~ "Edit Interchange fee"
    end
  end

  describe "update interchange_fee" do
    setup [:create_interchange_fee]

    test "redirects when data is valid", %{conn: conn, interchange_fee: interchange_fee} do
      conn =
        put(conn, Routes.interchange_fee_path(conn, :update, interchange_fee),
          interchange_fee: @update_attrs
        )

      assert redirected_to(conn) == Routes.interchange_fee_path(conn, :show, interchange_fee)

      conn = get(conn, Routes.interchange_fee_path(conn, :show, interchange_fee))
      assert html_response(conn, 200) =~ "some updated year"
    end

    test "renders errors when data is invalid", %{conn: conn, interchange_fee: interchange_fee} do
      conn =
        put(conn, Routes.interchange_fee_path(conn, :update, interchange_fee),
          interchange_fee: @invalid_attrs
        )

      assert html_response(conn, 200) =~ "Edit Interchange fee"
    end
  end

  describe "delete interchange_fee" do
    setup [:create_interchange_fee]

    test "deletes chosen interchange_fee", %{conn: conn, interchange_fee: interchange_fee} do
      conn = delete(conn, Routes.interchange_fee_path(conn, :delete, interchange_fee))
      assert redirected_to(conn) == Routes.interchange_fee_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.interchange_fee_path(conn, :show, interchange_fee))
      end
    end
  end

  defp create_interchange_fee(_) do
    interchange_fee = fixture(:interchange_fee)
    %{interchange_fee: interchange_fee}
  end
end
