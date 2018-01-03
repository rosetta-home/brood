import { h, Component } from 'preact';
import { Router, route } from 'preact-router';
import Header from './header';
import Home from '../routes/home';
import Login from '../routes/login';
import Register from '../routes/register';
import Profile from '../routes/profile';
import { updateData } from '../actions';
import store from '../store';

class Redirect extends Component {
  componentWillMount() {
    route(this.props.to, true);
  }

  render() {
    return null;
  }
}

const ProtectedRoute = ({ component: Component, ...rest }) => (
  store.getState().authenticated
		? (<Component {...rest} />)
		: (<Redirect to='/login' />)
)

export default class App extends Component {
	/** Gets fired when the route changes.
	 *	@param {Object} event		"change" event from [preact-router](http://git.io/preact-router)
	 *	@param {string} event.url	The newly routed URL
	 */
	handleRoute = e => {
		this.currentUrl = e.url;
	};

	componentDidMount = () => {
		this.interval = setInterval(() => {
			store.dispatch(updateData());
		}, 500);
	};

	componentWillUnmount = () => {
		clearInterval(this.interval);
	}

	render = () => {
		return (
			<div id="app">
				<Header />
				<Router>
					<ProtectedRoute component={Home} path="/" />
					<Login path="/login" />
					<Register path="/register" />
				</Router>
			</div>
		);
	}
}
