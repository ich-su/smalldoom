uses crt;
var
  f: file;
  s: byte absolute $b800:0;
  i: byte;
begin
  textattr:=$0F;
  assign(f,'endoom.raw'); reset(f,1);
  blockread(f,s,4000);
  close(f);
  GotoXY(1,4);
  for i:=1 to 13 do DelLine;
  GotoXY(1,1);
  InsLine; InsLine; InsLine;
  Window(8,16,73,22); TextAttr:=$1E; clrscr;
  TextAttr:=$1F;
  GotoXY(23,2); WriteLn('Small DeathMatch DOOM'); TextAttr:=$1E;
  WriteLn(' 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴');
  WriteLn(#13#10'                       DOOM skiped by ICH');
  WriteLn('                     Kostroma, Russia, 1997');
  readkey;
  assign(f,'endoom.my'); rewrite(f,1);
  blockwrite(f,s,4000);
  close(f)
end.
