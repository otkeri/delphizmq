program benchmark_server;

{$APPTYPE CONSOLE}

uses
    SysUtils
  , Windows
  , zmq
  ;

var
  context,
  responder: Pointer;

  request,
  reply: zmq_msg_t;

begin
  context := zmq_init(1);

  //  Socket to talk to clients
  responder := zmq_socket( context, ZMQ_REP );
  zmq_bind( responder, 'tcp://*:5555' );

  while true do
  begin
    //  Wait for next request from client
    zmq_msg_init( request );
    zmq_recv( responder, request, 0 );
    zmq_msg_close( request );

    //  Send reply back to client
    zmq_msg_init( reply );
    zmq_msg_init_size( reply, 5 );
    CopyMemory( zmq_msg_data( reply ), @'World'[1], 5 );
    zmq_send( responder, reply, 0 );
    zmq_msg_close( reply );

  end;

  //  We never get here but if we did, this would be how we end
  zmq_close( responder );
  zmq_term( context );
end.