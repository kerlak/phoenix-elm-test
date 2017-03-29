// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

import socket from "./socket"

const elixir_css = "background-color: #762ca7; color: white; font-size: 1.2em;";
const phoenix_css = "background-color: #ef4734; color: white; font-size: 1.2em;";
const elm_css = "background-color: #60B5CC; color: white; font-size: 1.2em;";
const unicorn_css = "background: linear-gradient(rgba(255, 0, 0, 1), rgba(255, 255, 0, 1), rgba(0, 255, 0, 1), rgba(0, 255, 255, 1), rgba(0, 0, 255, 1), rgba(255, 0, 255, 1), rgba(255, 0, 0, 1)); color: white; font-size: 1.2em;";
const secrets_css = "font-size:0.3em;";
const super_secrets_css = "font-size:0.1em;";
const hyper_secrets_css = "font-size:0.0em;";

console.log("Made with:");
console.log("%c     * Elixir", elixir_css);
console.log("%c     * Phoenix", phoenix_css);
console.log("%c     * Elm-lang", elm_css);
console.log("   and");
console.log("%c     * Unicorn powder", unicorn_css);

console.log("%cDiscover all the secrets…", secrets_css);
console.log("%cCongrats! Please tell us how did you find this text sending an email to: undercover@bluetab.net", super_secrets_css);

console.log("%cvariable_secreta", hyper_secrets_css);

const showNewTitle = function() {
  const title = document.title.replace("/", "");
  let position = document.title.split("/")[0].length;
  position = (position + 1) % (title.length + 1);
  const newTitle = title.substr(0,position) + "/" + title.substr(position);
  document.title = newTitle;
}
// setInterval(function(){ showNewTitle() }, 300);
