import { h, Component } from 'preact';
import LayoutGrid from 'preact-material-components/LayoutGrid';
import 'preact-material-components/LayoutGrid/style.css';
import { connect } from 'preact-redux';
import reduce from '../../reducers';
import * as actions from '../../actions';
import style from './style';

@connect(reduce, actions)
export default class Home extends Component {
	render = ({ ...state }, { text }) => {
		return (
      <div className="login page" >
        <LayoutGrid>
          <LayoutGrid.Inner>
            <LayoutGrid.Cell cols="12" desktopCols="12" tabletCols="8" phoneCols="4">
              <div>Register</div>
            </LayoutGrid.Cell>
          </LayoutGrid.Inner>
        </LayoutGrid>
      </div>
    );
	};
}
