import { h, Component } from 'preact';
import Card from 'preact-material-components/Card';
import 'preact-material-components/Card/style.css';
import List from 'preact-material-components/List';
import 'preact-material-components/List/style.css';
import RealtimeGraph from './realtime-graph'

export default class Sensor extends Component {

  get_value = () => {
    var list = this.props.list;
    return list.length ? list[list.length-1].data_point : 0;
  }

  render_title = () => (
    this.props.title + " | " + this.get_value().interface_pid
  )

  render_tags = () => {
    var value = this.get_value();
    var out = [];
    for(var k in value.state){
      if(this.props.graph_var.indexOf(k) != -1){
        var tag = k.split("_").map((word) => word.charAt().toUpperCase() + word.substr(1))
        out.push(
          <List.Item>
            <List.PrimaryText>{tag.join(" ")}: &nbsp;</List.PrimaryText>
            <List.SecondaryText>{value.state[k]}</List.SecondaryText>
          </List.Item>
        );
      }
    }
    return out;
  }

  render_primary = () => (
    <Card.Primary style={{"background-color": this.props.color(.5)}}>
      <Card.Title style={{"color": this.props.color(0)}}>
        {this.render_title()}
      </Card.Title>
    </Card.Primary>
  )

  render_media = () => {
    var value = this.get_value();
    return (<Card.Media className='card-media' style={{"padding": "0px", "padding-top": "10px"}}>
      <div id={value.interface_pid}>
        <RealtimeGraph list={this.props.list} type={this.props.name} name={value.interface_pid} color={this.props.color} graph_var={this.props.graph_var} />
      </div>
    </Card.Media>);
  }

  render_card = () => (
    <Card style={{"background-color": this.props.color(.2)}}>
      {this.render_primary()}
      {this.render_media()}
      <Card.HorizontalBlock style={{"background-color": this.props.color(.1)}}>
        <Card.Primary style={{"color": this.props.color(1)}}>
        <List className={"mdc-list--dense"}>
          {this.render_tags().map((span) => span)}
        </List>
        </Card.Primary>
      </Card.HorizontalBlock>
    </Card>
  )

  render = ({ title, list, name, graph_var, color}, state) => {
    return this.render_card()
  }
}
