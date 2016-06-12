var nxt = require('nodejs-nxt');
var nxt0 = new nxt.NXT('/dev/tty.SohansNXt-DevB', true);
var Firebase = require("firebase");
var ref = new Firebase("https://project-6533194313020070507.firebaseio.com/");
var app = require('express')();
var http = require('http').Server(app);
var io = require('socket.io')(http);

app.get('/', function(req, res){
  res.sendfile('index.html');
});
app.get('/s.js', function(req, res){
  res.sendfile('s.js');
});


nxt0.Connect(function(error) {
  if (error) {
    console.log('Could not connect to the device!');
  } else {
    ref.on("child_changed", function(data) {
      console.log("called")
      if (data.key() == "directions"){
        if (data.val() == "forward") {
          forward()
        }
        if (data.val() == "backward") {
          backward()
        }
        if (data.val() == "left") {
          left()
        }
        if (data.val() == "right") {
          right()
        }
        if (data.val() == "stop") {
          stop()
        }
      }
    });
    io.on('connection', function(socket){
      socket.on('direction', function(data){
        if (data == "forward") {
          console.log("socket f")
          forward()
        }
        if (data == "backward" || data == "back") {
          console.log("socket b")
          backward()
        }
        if (data == "stop") {
          console.log("socket s")
          stop()
        }
        if (data == "left") {
          console.log("socket l")
          left()
        }
        if (data == "right") {
          console.log("socket r")
          right()
        }
      });
    });
  }
});

function forward() {
  nxt0.SetOutputState(nxt.MotorPort.B, -75, nxt.Mode.MotorOn, nxt.RegulationMode.MotorSpeed, 0x00, nxt.RunState.Running, 0x00, function(error) {
    if (error) {
      console.log('Could not run motors!');
    } else {
      nxt0.SetOutputState(nxt.MotorPort.C, -75, nxt.Mode.MotorOn, nxt.RegulationMode.MotorSpeed, 0x00, nxt.RunState.Running, 0x00, function(error) {
        if (error) {
          console.log('Could not run motors!');
        } else {
        }
      });
    }
  });
}

function backward() {
  nxt0.SetOutputState(nxt.MotorPort.B, 75, nxt.Mode.MotorOn, nxt.RegulationMode.MotorSpeed, 0x00, nxt.RunState.Running, 0x00, function(error) {
    if (error) {
      console.log('Could not run motors!');
    } else {
      nxt0.SetOutputState(nxt.MotorPort.C, 75, nxt.Mode.MotorOn, nxt.RegulationMode.MotorSpeed, 0x00, nxt.RunState.Running, 0x00, function(error) {
        if (error) {
          console.log('Could not run motors!');
        } else {
        }
      });
    }
  });
}

function right() {
  nxt0.SetOutputState(nxt.MotorPort.B, 75, nxt.Mode.MotorOn, nxt.RegulationMode.MotorSpeed, 0x00, nxt.RunState.Running, 0x00, function(error) {
    if (error) {
      console.log('Could not run motors!');
    } else {
      nxt0.SetOutputState(nxt.MotorPort.C, -75, nxt.Mode.MotorOn, nxt.RegulationMode.MotorSpeed, 0x00, nxt.RunState.Running, 0x00, function(error) {
        if (error) {
          console.log('Could not run motors!');
        } else {
        }
      });
    }
  });
}

function left() {
  nxt0.SetOutputState(nxt.MotorPort.B, -75, nxt.Mode.MotorOn, nxt.RegulationMode.MotorSpeed, 0x00, nxt.RunState.Running, 0x00, function(error) {
    if (error) {
      console.log('Could not run motors!');
    } else {
      nxt0.SetOutputState(nxt.MotorPort.C, 75, nxt.Mode.MotorOn, nxt.RegulationMode.MotorSpeed, 0x00, nxt.RunState.Running, 0x00, function(error) {
        if (error) {
          console.log('Could not run motors!');
        } else {
        }
      });
    }
  });
}

function stop() {
  nxt0.SetOutputState(nxt.MotorPort.B, 0, nxt.Mode.Brake, nxt.RegulationMode.Idle, 0x00, nxt.RunState.Idle, 0x00, function(error) {
    if (error) {
      console.log('Could not run motors!');
    } else {
      nxt0.SetOutputState(nxt.MotorPort.C, 0, nxt.Mode.Brake, nxt.RegulationMode.Idle, 0x00, nxt.RunState.Idle, 0x00, function(error) {
        if (error) {
          console.log('Could not run motors!');
        } else {
        }
      });
    }
  });
}

http.listen(3000, function(){
  console.log('listening on *:3000');
});
