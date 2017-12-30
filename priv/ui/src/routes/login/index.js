import { h, Component } from 'preact';
import LayoutGrid from 'preact-material-components/LayoutGrid';
import Button from 'preact-material-components/Button';
import TextField from 'preact-material-components/TextField';
import 'preact-material-components/LayoutGrid/style.css';
import 'preact-material-components/TextField/style.css';
import 'preact-material-components/Button/style.css';
import reduce from '../../reducers';
import store from '../../store';
import * as actions from '../../actions';
import { connect } from 'preact-redux';
import style from './style';

@connect(reduce, actions)
export default class Home extends Component {
	submit = (event) => {
		event.preventDefault();
		console.log(event);
		store.dispatch(actions.login("entone@gmail.com", "123456789"));
		return false;
	}

	render = ({ ...state }, { text }) => {
		return (
      <div className="login page" >
        <LayoutGrid>
          <LayoutGrid.Inner>
            <LayoutGrid.Cell cols="12" desktopCols="12" tabletCols="8" phoneCols="4">
							<form onsubmit={this.submit}>
								<TextField type="text" name="email" label="Email" />
								<TextField type="password" name="password" label="Password" />
								<Button>Login</Button>
							</form>
            </LayoutGrid.Cell>
          </LayoutGrid.Inner>
        </LayoutGrid>
      </div>
    );
	};
}
