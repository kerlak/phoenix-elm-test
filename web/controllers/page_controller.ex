defmodule Pet.PageController do
  use Pet.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
