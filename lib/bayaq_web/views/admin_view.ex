defmodule BayaqWeb.AdminView do
  use BayaqWeb, :view
  def format_timestamp(time) do
    {:ok, datetime} = DateTime.from_naive(time, "Etc/UTC") 
    DateTime.add(datetime, 28800, :second)
  end

end
