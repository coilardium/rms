defmodule RmsWeb.LocomotiveControllerTest do
  use RmsWeb.ConnCase

  alias Rms.Locomotives

  @create_attrs %{
    description: "some description",
    loco_number: "some loco_number",
    model: "some model",
    status: "some status",
    type_id: "some type_id",
    weight: 120.5
  }
  @update_attrs %{
    description: "some updated description",
    loco_number: "some updated loco_number",
    model: "some updated model",
    status: "some updated status",
    type_id: "some updated type_id",
    weight: 456.7
  }
  @invalid_attrs %{
    description: nil,
    loco_number: nil,
    model: nil,
    status: nil,
    type_id: nil,
    weight: nil
  }

  def fixture(:locomotive) do
    {:ok, locomotive} = Locomotives.create_locomotive(@create_attrs)
    locomotive
  end

  describe "index" do
    test "lists all tbl_locomotive", %{conn: conn} do
      conn = get(conn, Routes.locomotive_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Tbl locomotive"
    end
  end

  describe "new locomotive" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.locomotive_path(conn, :new))
      assert html_response(conn, 200) =~ "New Locomotive"
    end
  end

  describe "create locomotive" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.locomotive_path(conn, :create), locomotive: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.locomotive_path(conn, :show, id)

      conn = get(conn, Routes.locomotive_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Locomotive"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.locomotive_path(conn, :create), locomotive: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Locomotive"
    end
  end

  describe "edit locomotive" do
    setup [:create_locomotive]

    test "renders form for editing chosen locomotive", %{conn: conn, locomotive: locomotive} do
      conn = get(conn, Routes.locomotive_path(conn, :edit, locomotive))
      assert html_response(conn, 200) =~ "Edit Locomotive"
    end
  end

  describe "update locomotive" do
    setup [:create_locomotive]

    test "redirects when data is valid", %{conn: conn, locomotive: locomotive} do
      conn =
        put(conn, Routes.locomotive_path(conn, :update, locomotive), locomotive: @update_attrs)

      assert redirected_to(conn) == Routes.locomotive_path(conn, :show, locomotive)

      conn = get(conn, Routes.locomotive_path(conn, :show, locomotive))
      assert html_response(conn, 200) =~ "some updated description"
    end

    test "renders errors when data is invalid", %{conn: conn, locomotive: locomotive} do
      conn =
        put(conn, Routes.locomotive_path(conn, :update, locomotive), locomotive: @invalid_attrs)

      assert html_response(conn, 200) =~ "Edit Locomotive"
    end
  end

  describe "delete locomotive" do
    setup [:create_locomotive]

    test "deletes chosen locomotive", %{conn: conn, locomotive: locomotive} do
      conn = delete(conn, Routes.locomotive_path(conn, :delete, locomotive))
      assert redirected_to(conn) == Routes.locomotive_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.locomotive_path(conn, :show, locomotive))
      end
    end
  end

  defp create_locomotive(_) do
    locomotive = fixture(:locomotive)
    %{locomotive: locomotive}
  end
end
