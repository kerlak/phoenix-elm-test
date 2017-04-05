defmodule Pet.UserController do
  use Pet.Web, :controller

  alias Pet.User

  def index(conn, _params) do
    users = Repo.all(User)
    changeset = User.changeset(%User{})
    render(conn, "index.html", users: users, changeset: changeset)
  end

  def new(conn, _params) do
    changeset = User.changeset(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  defp insert_or_update(team, email, name) do
    changeset = User.changeset(%User{}, %{team: team, email: email, name: name})
    user = Repo.get_by(User, email: email)
    case user do
      nil ->
        Repo.insert changeset
      _ ->
        user = Ecto.Changeset.change(user, team: team)
        user = Ecto.Changeset.change(user, name: name)
        Repo.update user
    end
  end

  def create(conn, user_params) do
    user = user_params["user"]

    team = user["team"]

    name_1 = user["name_1"]
    name_2 = user["name_2"]
    name_3 = user["name_3"]
    name_4 = user["name_4"]
    name_5 = user["name_5"]

    email_1 = user["email_1"]
    email_2 = user["email_2"]
    email_3 = user["email_3"]
    email_4 = user["email_4"]
    email_5 = user["email_5"]

    if (email_1 != nil and email_1 != "" and String.ends_with?(email_1, "@bluetab.net")) do
      insert_or_update(team, email_1, name_1)
    end

    if (email_2 != nil and email_2 != "" and String.ends_with?(email_2, "@bluetab.net")) do
      insert_or_update(team, email_2, name_2)
    end

    if (email_3 != nil and email_3 != "" and String.ends_with?(email_3, "@bluetab.net")) do
      insert_or_update(team, email_3, name_3)
    end

    if (email_4 != nil and email_4 != "" and String.ends_with?(email_4, "@bluetab.net")) do
      insert_or_update(team, email_4, name_4)
    end

    if (email_5 != nil and email_5 != "" and String.ends_with?(email_5, "@bluetab.net")) do
      insert_or_update(team, email_5, name_5)
    end
    conn
    |> redirect(to: (user_path(conn, :index) <> "#inscritos"))
  end
  #
  # def show(conn, %{"id" => id}) do
  #   user = Repo.get!(User, id)
  #   render(conn, "show.html", user: user)
  # end
  #
  # def edit(conn, %{"id" => id}) do
  #   user = Repo.get!(User, id)
  #   changeset = User.changeset(user)
  #   render(conn, "edit.html", user: user, changeset: changeset)
  # end
  #
  # def update(conn, %{"id" => id, "user" => user_params}) do
  #   user = Repo.get!(User, id)
  #   changeset = User.changeset(user, user_params)
  #
  #   case Repo.update(changeset) do
  #     {:ok, user} ->
  #       conn
  #       |> put_flash(:info, "User updated successfully.")
  #       |> redirect(to: user_path(conn, :show, user))
  #     {:error, changeset} ->
  #       render(conn, "edit.html", user: user, changeset: changeset)
  #   end
  # end
  #
  # def delete(conn, %{"id" => id}) do
  #   user = Repo.get!(User, id)
  #
  #   # Here we use delete! (with a bang) because we expect
  #   # it to always work (and if it does not, it will raise).
  #   Repo.delete!(user)
  #
  #   conn
  #   |> put_flash(:info, "User deleted successfully.")
  #   |> redirect(to: user_path(conn, :index))
  # end
end
