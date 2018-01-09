
import * as types from './types'

export function login(email, password){
	return {
		type: types.LOGIN,
		email: email,
		password: password
	};
}

export function authenticated(token){
	return {
		type: types.AUTHENTICATED,
		token: token
	};
}

export function authError(error){
	return {
		type: types.AUTH_ERROR,
		error: error
	};
}

export function invalidToken(error){
	return {
		type: types.INVALID_TOKEN,
		error: error
	};
}

export function updateData() {
	return {
		type: types.UPDATE_DATA
	};
}

export function sendMessage(type, id, payload) {
	return {
		type: types.SEND_MESSAGE,
		id: id,
		message: type,
		payload: payload
	};
}

export function receiveAction(action, payload) {
	return {
		type: types.RECEIVE_ACTION,
		action: action,
		payload: payload
	};
}

export function receiveDataPoint(data_point) {
	return {
		type: types.RECEIVE_DATA_POINT,
		data_point: data_point
	};
}

export function receiveData(data) {
	return {
		type: types.RECEIVE_DATA,
		data: data
	};
}
