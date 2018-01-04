import { h, Component } from 'preact';
import { route } from 'preact-router';
import LayoutGrid from 'preact-material-components/LayoutGrid';
import Button from 'preact-material-components/Button';
import TextField from 'preact-material-components/TextField';
import Card from 'preact-material-components/Card';
import 'preact-material-components/LayoutGrid/style.css';
import 'preact-material-components/TextField/style.css';
import 'preact-material-components/Button/style.css';
import 'preact-material-components/Card/style.css';
import reduce from '../../reducers';
import store from '../../store';
import * as actions from '../../actions';
import { connect } from 'preact-redux';
import { account } from '../../common/config'
import style from './style';

function register(){
	var fd = new FormData(document.getElementById("register"));
	fetch(account()+"/account/register", {
		method: "PUT",
		body: fd,
		cors: true,
	}).then((resp) => {
		return resp.json();
	}).then((data) => {
		localStorage.setItem("user", JSON.stringify({token: data.success}));
		store.dispatch(
			actions.authenticated(data.success)
		)
		route("/", true);
	}).catch((error) => {
		console.log(error);
	})
}

@connect(reduce, actions)
export default class Register extends Component {
	submit = (event) => {
		event.preventDefault();
		register();
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
            			<Card.Title>Register</Card.Title>
          			</Card.Primary>
          			<Card.Media className='card-media'>
									<form id="register" onsubmit={this.submit}>
										<TextField type="text" name="email" label="Email" fullwidth={true} />
										<TextField type="password" name="password" label="Password" fullwidth={true} />
										<TextField type="password" name="password_conf" label="Confirm Password" fullwidth={true} />
										<TextField type="text" name="location_name" label="Location" fullwidth={true} />
										<TextField type="text" name="kit_id" label="Kit ID" fullwidth={true} />
										<TextField type="text" name="zipcode" label="Zip Code" fullwidth={true} />
										<br />
										<Button raised={true}>Register</Button>
									</form>
								</Card.Media>
								<Card.Actions>
									<Card.Action onclick={() => ( route("/login", true) ) }>
										Already have an account?
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
