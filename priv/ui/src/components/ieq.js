import Sensor from './sensor';
import store from '../store';
import * as actions from '../actions'

export default class IEQ extends Sensor {

  click = (color) => {
    console.log("set color: "+ color);
    var pid = this.get_value().interface_pid
    store.dispatch(
      actions.sendMessage("configure_touchstone", pid, {id: pid, color: color})
    )
  }

  light = (color) => (
    <div className={"color-button "+ color} onclick={ () => this.click(color) }></div>
  )

  render_title = () => (
    <div>
      <span>
        {this.props.title + " | " + this.get_value().interface_pid}
      </span>
      <ul className="color-control">
        <li>{this.light("red")}</li>
        <li>{this.light("blue")}</li>
        <li>{this.light("white")}</li>
        <li>{this.light("green")}</li>
        <li>{this.light("yellow")}</li>
        <li>{this.light("off")}</li>
      </ul>
    </div>
  )

}
