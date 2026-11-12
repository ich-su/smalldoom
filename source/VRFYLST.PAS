(*$S-,R-,V-,I-,B-,D-,L-*)
const
  maxtxt = 3000;
  Err    : boolean = false;
var
  f      : text;
  txt    : array[1..maxtxt] of string[18];
  maxi,j : word;
  s      : string;

function Verify: boolean;
  var
    i: word;
    n: string[8];
  begin
    Verify:=true;
    n:=''; i:=0;
    while (s[25+i]<>' ') and (25+i<=byte(s[0])) do inc(i);
    n:=Copy(s,25,i);
    for i:=1 to maxi do
      if (Copy(txt[i],1,byte(n[0]))=n) and (
        (txt[i,17]='C') or (txt[i,17]='F')) then exit;
    Verify:=false; Err:=true
  end;

begin
  Assign(f,'doom2res.lst'); Reset(f); maxi:=0;
  while not eof(f) do begin
    inc(maxi);
    ReadLn(f,txt[maxi])
  end;
  Close(f);
  Reset(f);
  WriteLn('Errors:'); j:=0;
  while not eof(f) do begin
    inc(j);
    ReadLn(f,s); Write(j,#13);
    if s[17]='S' then
      if not Verify then WriteLn(s)
  end;
  Close(f);
  if not Err then WriteLn('All OK')
  else WriteLn('    ');
end.
