import { receiveAction, receiveDataPoint, receiveData, invalidToken,  authError} from '../actions';
import * as types from '../types';
import store from '../store';
import { host } from '../common/config'
const ReconnectingWebSocket = require('reconnecting-websocket');

var loc = window.location, uri;
var h = host();
if(!h){
  if (loc.protocol === "https:") {
      uri = "wss:";
  } else {
      uri = "ws:";
  }
  uri += "//" + loc.host;
  uri += "/ws";
}else{
  uri = h
}

const socket = new ReconnectingWebSocket(uri);
var interval = null;
socket.onmessage = message_handler;
socket.onopen = connect_handler;
socket.onclose = close_handler;
socket.onerror = error_handler;

export const emit = (action) => socket.send(JSON.stringify(action));

function message_handler(message){
  var data_p, action;
  try{
    data_p = JSON.parse(message.data);
  }catch(e){
    data_p = {_type: "error", type: "NULL"};
  }
  switch(data_p._type){
    case types.MESSAGE:
      action = handle_message(data_p);
      break;
    case types.ERROR:
      action = handle_error(data_p);
      break;
  }
  if(action) store.dispatch(action);
}

function handle_error(data_p){
  var action;
  switch(data_p.message){
    case types.INVALID_TOKEN:
      action = invalidToken(data_p);
      break;
    case types.AUTH_ERROR:
      action = authError(data_p);
      break
  }
  return action;
}

function handle_message(data_p){
  var action;
  switch(data_p.type){
    case types.RECEIVE_DATA_POINT:
      action = receiveDataPoint(data_p.data_point);
      break;
    case types.RECEIVE_DATA:
      action = receiveData(data_p.data);
      break;
    case types.RECEIVE_ACTION:
      action = receiveAction(data_p.action, data_p.payload);
      break;
  }
  return action;
}

function error_handler(e){
  console.log("WS Error");
  console.log(e);
}

function connect_handler(e){
  interval = setInterval(function(){
    socket.send("ping");
  }, 23000);
  console.log("WS connected");
  console.log(e);
  authorize()
}

function close_handler(e){
  clearInterval(interval);
  console.log("WS closed");
  console.log(e);
}

function authorize(){
  var user = localStorage.getItem('user');
  if(user){
    var token = JSON.parse(user).token;
    socket.send("Bearer "+ token);
  }else{
    socket.close();
  }
}
