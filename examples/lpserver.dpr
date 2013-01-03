program lpserver;
//
//  Lazy Pirate server
//  Binds REQ socket to tcp://*:5555
//  Like hwserver except:
//   - echoes request as-is
//   - randomly runs slowly, or exits to simulate a crash.
//
{$APPTYPE CONSOLE}

uses
    SysUtils
  , zmqapi
  ;

var
  context: TZMQContext;
  server: TZMQSocket;
  cycles: Integer;
  request: String;
begin
  Randomize;

  context := TZMQContext.create;
  server := context.socket( stRep );
  server.bind( 'tcp://*:5555' );

  cycles := 0;
  while not context.Terminated do
  begin
    server.recv( request );
    inc( cycles );

    //  Simulate various problems, after a few cycles
    if ( cycles > 3 ) and ( random(3) = 0) then
    begin
      Writeln( 'I: simulating a crash' );
      break;
    end else
    if ( cycles > 3 ) and ( random(3) = 0 ) then
    begin
      Writeln( 'I: simulating CPU overload' );
      sleep (2);
    end;

    Writeln( Format( 'I: normal request (%s)', [request] ) );
    sleep (1);              //  Do some heavy work
    server.send( request );
  end;
  server.Free;
  context.Free;
end.