defmodule Pet.RoomChannel do
  use Pet.Web, :channel

  alias Pet.Eyes

  def join("room:lobby", payload, socket) do
    if authorized?(payload) do
      [socket, eyes, _] = add_new_eye(socket)
      {:ok, eyes, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def add_new_eye(socket) do
    eyes = Eyes.all()
    eye = Eyes.add()
    socket = assign(socket, :user, eye.id)
    send(self, {:after_join, eye})
    [socket, eyes, eye]
  end

  def handle_info({:after_join, eye}, socket) do
    broadcast! socket, "walk", eye
    {:noreply, socket}
  end

  def terminate(reason, socket) do
    remove_by_socket(socket)
    broadcast socket, "delete_eye", %{id: socket.assigns[:user]}
  end

  def remove_by_socket(socket) do
    id = socket.assigns[:user]
    Eyes.remove(id)
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (room:lobby).
  def handle_in("shout", payload, socket) do
    broadcast socket, "shout", payload
    {:noreply, socket}
  end


  def handle_in("walk", %{"x" => position_x, "y" => position_y}, socket) do
      id = socket.assigns[:user]
      Eyes.walk(id, position_x, position_y)
      eye = Eyes.get(id)
      broadcast socket, "walk", eye
      {:noreply, socket}
    end
  # def handle_in("wave", payload, socket) do
  #   broadcast socket, "wave", payload
  #   {:noreply, socket}
  # end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
