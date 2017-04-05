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

// const elmFpsDiv = document.getElementById('elm-fps')
//     , elmFps = Elm.Fps.embed(elmFpsDiv)

const elmFireDiv = document.getElementById('elm-fire')
    , elmFire = elmFireDiv ? Elm.Fire.embed(elmFireDiv) : null

const elmCountdownDiv = document.getElementById('elm-countdown')
    , elmCountdown = elmCountdownDiv ? Elm.Countdown.embed(elmCountdownDiv) : null

const elmEyesDiv = document.getElementById('elm-eyes')
    , elmEyes = elmEyesDiv ? Elm.Eyes.embed(elmEyesDiv) : null


if (elmFire && elmCountdown && elmEyes) {
  const showMessage = function (message, resp) {
    console.log(resp);
    elmEyes.ports.input.send(resp);
  }

  const initEyes = function (payload) {
    const eyes = payload.map(eye => {
      const position = {
        x: eye.position_x,
        y: Math.max(eye.position_y, 220)
      };
      const resp = {
        id: eye.id,
        life: eye.life,
        skin: eye.skin,
        state: eye.state,
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
    .receive("ok", resp => { initEyes(resp);})
    .receive("error", resp => { console.log("Unable to join", resp) })

  // Elm integration
  elmEyes.ports.output.subscribe(function (elmMessage) {
    const [message, body] = elmMessage;
    channel.push(message, body)
  });

  const skins = [
    "",
    "space invader",
    "shit",
    "ghost",
    "fire",
    "drops",
    "huracan",
    "empty",
    "heart"
  ];

  elmEyes.ports.outputState.subscribe(function (elmMessage) {
    const [message, body] = elmMessage;
    channel.push(message, body)

    if(ga) {
      ga('send', {
        hitType: 'event',
        eventCategory: 'change_skin',
        eventAction: skins[parseInt(JSON.stringify(body))],
        eventLabel: 'eyes'
      });
    }
  });

  channel.on("state", payload => {
    const position = {
      x: payload.position_x,
      y: Math.max(payload.position_y, 220)
    };
    const resp = {
      id: payload.id,
      life: payload.life,
      skin: payload.skin,
      state: payload.state,
      position
    }
    elmEyes.ports.input.send(resp);
  })

  channel.on("walk", payload => {
    const position = {
      x: payload.position_x,
      y: Math.max(payload.position_y, 220)
    };
    const resp = {
      id: payload.id,
      life: payload.life,
      skin: payload.skin,
      state: payload.state,
      position
    }
    elmEyes.ports.input.send(resp);
  })

  channel.on("delete_eye", payload => {
    elmEyes.ports.remove.send(payload.id);
  })
  // Elm integration

  var theElement1 = document.getElementById("elm-countdown");
  var theElement2 = document.getElementById("elm-eyes");
  var theElement3 = document.getElementById("floor");

  theElement1.addEventListener("touchmove", handlerFunction, false);
  theElement2.addEventListener("touchmove", handlerFunction, false);
  theElement3.addEventListener("touchmove", handlerFunction, false);

  function handlerFunction(event) {
    const x = Math.floor(event.changedTouches[0].pageX);
    const y = Math.floor(event.changedTouches[0].pageY);
    const position = {
      x,
      y
    }
    channel.push("walk", position)
  }
}


// Google Analytics
(function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
(i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
})(window,document,'script','https://www.google-analytics.com/analytics.js','ga');

ga('create', 'UA-96370760-1', 'auto');
ga('send', 'pageview');


export default socket
