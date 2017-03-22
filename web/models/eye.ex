defmodule Pet.Eye do
  @moduledoc """
  """

  defstruct id: 0, life: 1, position_x: 0, position_y: 0, skin: 0

  def new() do
    %__MODULE__{id: generate_id, skin: random_skin}
  end

  def update(eye, position_x, position_y) do
    %{eye | position_x: position_x, position_y: position_y}
  end

  def generate_id() do
    UUID.uuid4
  end

  def random_skin() do
    :rand.uniform(3)
  end
end
