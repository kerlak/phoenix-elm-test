defmodule Pet.Eyes do
  @moduledoc """
  """

  alias Pet.Eye

  def start_link() do
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end

  def reset() do
    Agent.update(__MODULE__, fn(_) -> [] end)
  end

  def all() do
    Agent.get(__MODULE__, fn(eyes) -> eyes end)
  end

  def add(), do: add(Eye.new)

  defp add(eye) do
    Agent.update(__MODULE__, fn(eyes) -> [eye | eyes] end)
    eye
  end

  def get(id) do
    Agent.get(__MODULE__, fn(eyes) -> Enum.find(eyes, fn(eye) -> eye.id == id end) end)
  end

  def walk(id, position_x, position_y) do
    Agent.update(__MODULE__, fn(eyes) -> update_eyes(eyes, id, position_x, position_y) end)
  end

  def change_state(id, new_state) do
    Agent.update(__MODULE__, fn(eyes) -> change_state_eyes(eyes, id, new_state) end)
  end

  def remove(id) do
    Agent.update(__MODULE__, fn(eyes) -> Enum.filter(eyes, fn(eye) -> eye.id != id end) end)
  end

  def count() do
    Enum.count(all())
  end

  defp update_eyes(eyes, id, position_x, position_y) when is_integer(position_x) and is_integer(position_y) do
    Enum.map(eyes, fn(eye) ->
      if eye.id == id do
        Eye.update(eye, position_x, position_y)
      else
        eye
      end
    end)
  end

  defp change_state_eyes(eyes, id, new_state) when is_integer(new_state) do
    Enum.map(eyes, fn(eye) ->
      if eye.id == id do
        Eye.change_state(eye, new_state)
      else
        eye
      end
    end)
  end

end
