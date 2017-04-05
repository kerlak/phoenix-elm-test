defmodule Pet.User do
  use Pet.Web, :model

  schema "users" do
    field :team, :string
    field :name, :string
    field :email, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:team, :name, :email])
    # |> unique_constraint(:email)
  end
end
