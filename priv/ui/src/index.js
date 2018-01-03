import { Provider } from 'preact-redux';
import store from './store';
import App from './components/app';
import * as actions from './actions';
import './style';

const user = JSON.parse(localStorage.getItem('user'));

if (user && user.token) {
  store.dispatch(
		actions.authenticated(user.token)
	);
}

export default () => (
	<div id="outer">
		<Provider store={store}>
			<App />
		</Provider>
	</div>
);
