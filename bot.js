https://gist.github.com/derzorngottes/3b57edc1f996dddcab25

const tmi = require('tmi.js');
var osc = require("osc");

var bot = config.BOT_NAME;
var auth = config.OAUTH_TOKEN;
var chan = config.CHANNEL_NAME;

// Define configuration options
const opts = {
  identity: {
    username: "" + bot, // BOT_USERNAME
    password: "" + auth // OAUTH_TOKEN
  },
  channels: [
    "" + chan // CHANNEL_NAME
  ]
};

var udpPort = new osc.UDPPort({
    // This is the port we're listening on.
    localAddress: "127.0.0.1",
    localPort: 57121,

    // This is where sclang is listening for OSC messages.
    remoteAddress: "127.0.0.1",
    remotePort: 57120,
    metadata: true
});


// Create a client with our options
const client = new tmi.client(opts);

// Register our event handlers (defined below)
client.on('message', onMessageHandler);
client.on('connected', onConnectedHandler);

// Connect to Twitch:
client.connect();

// Open the socket.
udpPort.open();

function onMessageHandler (target, context, msg, self) {
  if (self) { return; }

  const commandName = msg;

  if (commandName === 'bells') {
    var msg = {
        address: "/1/samples",
        args: [{
            type: "f",
            value: 1
        },
        {
            type: "f",
            value: 0
        }]
    };
    udpPort.send(msg);
    client.say(target, 'a falling star on the Porthaven Marshes, (try catching it using the Seven-League Boots)');
  } else if (commandName === 'kick') {
    var msg = {
        address: "/1/samples",
        args: [{
            type: "f",
            value: 1
        },
        {
            type: "f",
            value: 1
        }]
    };
    udpPort.send(msg);
  } else if (commandName === 'snare') {
    var msg = {
        address: "/1/samples",
        args: [{
            type: "f",
            value: 1
        },
        {
            type: "f",
            value: 2
        }]
    };
    udpPort.send(msg);
  } else if (commandName === 'scape') {
    var msg = {
        address: "/1/samples",
        args: [{
            type: "f",
            value: 0
        },
        {
            type: "f",
            value: 3
        }]
    };
    udpPort.send(msg);
    client.say(target, 'the flowers grow with Howl\'s aid');
  } else if (commandName === 'stop scape') {
    var msg = {
        address: "/1/samples",
        args: [{
            type: "f",
            value: 0
        },
        {
            type: "f",
            value: 0
        }]
    };
    udpPort.send(msg);
    client.say(target, 'Markl curses');
  } else if (commandName === 'boeing') {
    var msg = {
        address: "/1/samples",
        args: [{
            type: "f",
            value: 1
        },
        {
            type: "f",
            value: 4
        }]
    };
    udpPort.send(msg);
    client.say(target, 'loud the 747 roars -11111zzz');
  } else if (commandName === 'donder') {
    var msg = {
        address: "/1/samples",
        args: [{
            type: "f",
            value: 1
        },
        {
            type: "f",
            value: 5
        }]
    };
    udpPort.send(msg);
    client.say(target, 'thunderclaps rend the air');
  } else if (commandName.slice(0,6) === 'reverb') {
    var msg = {
      address: "/2/effects",
      args: [{
        type: "f",
        value: 0
      }, {
        type: "f",
        value: commandName.slice(6)
      }]
    };
    udpPort.send(msg);
  } else if (commandName.slice(0,5) === 'delay') {
    var msg = {
      address: "/2/effects",
      args: [{
        type: "f",
        value: 1
      }, {
        type: "f",
        value: commandName.slice(5)
      }]
    };
    udpPort.send(msg);
  } else {
    client.say(target, '?‰???•Œ?„??');
    console.log(`* Unknown command ${commandName}`);
  }
}
//
// function onMessageHandler (target, context, msg, self) {
//   if (self) { return; }
//
//   const commandName = msg.trim();
//
//   if (commandName.slice(0,6) === 'reverb') {
//     var msg = {
//       address: "/2/effects",
//       args: [{
//         type: "f",
//         value: 0
//       }, {
//         type: "f",
//         value: commandName.slice(6)
//       }]
//     };
//     udpPort.send(msg);
//   } else if (commandName.slice(0,10) === 'delay') {
//     var msg = {
//       address: "/2/effects",
//       args: [{
//         type: "f",
//         value: 1
//       }, {
//         type: "f",
//         value: commandName.slice(10)
//       }]
//     };
//     udpPort.send(msg);
//   } else {
//     client.say(target, '?*??Å?ï??∏Å|¿??');
//     console.log(`* Unknown effectscommand ${commandName}`);
//   }
// }

// Called every time the bot connects to Twitch chat
function onConnectedHandler (addr, port) {
  console.log(`* Connected to ${addr}:${port}`);
}
