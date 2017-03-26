// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "web/static/js/app.js".

// To use Phoenix channels, the first step is to import Socket
// and connect at the socket path in "lib/my_app/endpoint.ex":
import {Socket} from "phoenix"

let socket = new Socket("/socket", {params: {token: window.userToken}})

// When you connect, you'll often need to authenticate the client.
// For example, imagine you have an authentication plug, `MyAuth`,
// which authenticates the session and assigns a `:current_user`.
// If the current user exists you can assign the user's token in
// the connection for use in the layout.
//
// In your "web/router.ex":
//
//     pipeline :browser do
//       ...
//       plug MyAuth
//       plug :put_user_token
//     end
//
//     defp put_user_token(conn, _) do
//       if current_user = conn.assigns[:current_user] do
//         token = Phoenix.Token.sign(conn, "user socket", current_user.id)
//         assign(conn, :user_token, token)
//       else
//         conn
//       end
//     end
//
// Now you need to pass this token to JavaScript. You can do so
// inside a script tag in "web/templates/layout/app.html.eex":
//
//     <script>window.userToken = "<%= assigns[:user_token] %>";</script>
//
// You will need to verify the user token in the "connect/2" function
// in "web/channels/user_socket.ex":
//
//     def connect(%{"token" => token}, socket) do
//       # max_age: 1209600 is equivalent to two weeks in seconds
//       case Phoenix.Token.verify(socket, "user socket", token, max_age: 1209600) do
//         {:ok, user_id} ->
//           {:ok, assign(socket, :user, user_id)}
//         {:error, reason} ->
//           :error
//       end
//     end
//
// Finally, pass the token on connect as below. Or remove it
// from connect if you don't care about authentication.

// Elm integration

const elmFpsDiv = document.getElementById('elm-fps')
    , elmFps = Elm.Fps.embed(elmFpsDiv)

const elmFireDiv = document.getElementById('elm-fire')
    , elmFire = Elm.Fire.embed(elmFireDiv)

const elmCountdownDiv = document.getElementById('elm-countdown')
    , elmCountdown = Elm.Countdown.embed(elmCountdownDiv)

const elmEyesDiv = document.getElementById('elm-eyes')
    , elmEyes = Elm.Eyes.embed(elmEyesDiv)

const showMessage = function (message, resp) {
  console.log(resp);
  elmEyes.ports.input.send(resp);
}

const initEyes = function (payload) {
  const eyes = payload.map(eye => {
    const position = {
      x: eye.position_x,
      y: Math.max(eye.position_y, 400)
    };
    const resp = {
      id: eye.id,
      life: eye.life,
      skin: eye.skin,
      position
    }
    return resp;
  })
  elmEyes.ports.init.send({items: eyes});
}
// Elm integration
socket.connect()

// Now that you are connected, you can join channels with a topic:
let channel = socket.channel("room:lobby", {})
channel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp); initEyes(resp);})
  .receive("error", resp => { console.log("Unable to join", resp) })

// Elm integration
elmEyes.ports.output.subscribe(function (elmMessage) {
  const [message, body] = elmMessage;
  channel.push(message, body)
});

channel.on("walk", payload => {
  const position = {
    x: payload.position_x,
    y: Math.max(payload.position_y, 400)
  };
  const resp = {
    id: payload.id,
    life: payload.life,
    skin: payload.skin,
    position
  }
  elmEyes.ports.input.send(resp);
})

channel.on("delete_eye", payload => {
  elmEyes.ports.remove.send(payload.id);
})
// Elm integration

export default socket
