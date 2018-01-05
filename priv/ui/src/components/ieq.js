import Sensor from './sensor';

export default class IEQ extends Sensor {

  render_title = () => (
    <div>
      <span>
        {this.props.title + " | " + this.get_value().interface_pid}
      </span>
      <ul>
        <li>{this.light("red")}</li>
        <li>{this.light("blue")}</li>
        <li>{this.light("white")}</li>
        <li>{this.light("green")}</li>
        <li>{this.light("yellow")}</li>
        <li>{this.light("off")}</li>
      </ul>
      <span style={{"text-align": "right"}}>

      </span>
    var title = ;
    var lights = ()

  )

}
