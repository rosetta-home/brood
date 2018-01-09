import { h, Component } from 'preact';
import { route } from 'preact-router';
import LayoutGrid from 'preact-material-components/LayoutGrid';
import Button from 'preact-material-components/Button';
import TextField from 'preact-material-components/TextField';
import FormField from 'preact-material-components/FormField';
import Card from 'preact-material-components/Card';
import 'preact-material-components/LayoutGrid/style.css';
import 'preact-material-components/TextField/style.css';
import 'preact-material-components/FormField/style.css';
import 'preact-material-components/Button/style.css';
import 'preact-material-components/Card/style.css';
import reduce from '../../reducers';
import store from '../../store';
import * as actions from '../../actions';
import { connect } from 'preact-redux';
import { account } from '../../common/config'
import style from './style';

function login(){
	var fd = new FormData(document.getElementById("login"));
	fetch(account()+"/account/login", {
		method: "POST",
		body: fd,
		cors: true,
	}).then((resp) => {
		return resp.json();
	}).then((data) => {
		store.dispatch(
			actions.authenticated(data.success)
		)
	}).catch((error) => {
		console.log(error);
	})
}

@connect(reduce, actions)
export default class Login extends Component {
	submit = (event) => {
		event.preventDefault();
		login();
		return false;
	}

	render = ({ ...state }, { text }) => {
		return (
      <div className="login page">
        <LayoutGrid>
          <LayoutGrid.Inner>
            <LayoutGrid.Cell cols="6" desktopCols="6" tabletCols="8" phoneCols="4">
        			<Card style={{"background-color": "#FFFFFF"}}>
          			<Card.Primary>
            			<Card.Title>Login</Card.Title>
          			</Card.Primary>
          			<Card.Media className='card-media'>
									<form id="login" onsubmit={this.submit}>
										<TextField type="text" name="email" placeholder="Email" fullwidth={true} />
										<TextField type="password" name="password" placeholder="Password" fullwidth={true}/>
										<br />
										<Button raised={true}>Login</Button>
									</form>
								</Card.Media>
								<Card.Actions>
									<Card.Action onclick={() => ( route("/register", true) ) }>
										Register a new account
									</Card.Action>
								</Card.Actions>
        			</Card>
            </LayoutGrid.Cell>
          </LayoutGrid.Inner>
        </LayoutGrid>
      </div>
    );
	};
}
