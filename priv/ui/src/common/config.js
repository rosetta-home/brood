export const host = () => {
  if(process.env.NODE_ENV == 'development'){
    return 'ws://localhost:8080/ws';
  }else{
    return null;
  }
}

export const account = () => {
  if(process.env.NODE_ENV == 'development'){
    return 'http://localhost:8080';
  }else{
    return "";
  }
}

export const num_data_points = 120;
