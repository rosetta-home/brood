import { h, Component } from 'preact';
import { connect } from 'preact-redux';
import * as actions from '../actions';
import reduce from '../reducers';

export function requireAuthentication(WrappedComponent) {

  class AuthenticatedComponent extends Component {

    componentWillMount() {
      this.checkAuth();
    }

    componentWillReceiveProps(nextProps) {
      this.checkAuth();
    }

    checkAuth() {
      console.log(this.props.isAuthenticated);
      if (!this.props.isAuthenticated) {
        let redirectAfterLogin = this.props.location.pathname;
        this.props.dispatch(pushState(null, `/login?next=${redirectAfterLogin}`));
      }
    }

    render() {
      return (
        <div>
          {this.props.isAuthenticated === true
            ? <WrappedComponent {...this.props}/>
            : null
          }
        </div>
      )

    }
  }
}
