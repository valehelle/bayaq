defmodule BayaqWeb.PageControllerTest do
  use BayaqWeb.ConnCase
  alias BayaqWeb.PageController
  
  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Welcome to Phoenix!"
  end
  test "GET TNB BALANCE", %{conn: conn} do
    PageController.get_tnb_balance()
  end
  @tag wip: true
  test "GET INDAH WATER BALANCE", %{conn: conn} do
    PageController.get_indah_water_balance()
  end
end
