(*$S-,R-,V-,B-,D-,L-,I-*)

Program MakeList;
Uses UWAD;

procedure CreateList(ListName: string);
  var
    i       : integer;
    sm      : longint;
    CurrDir : MastDir;
    sn      : string[8];
    f       : Text;
  begin
    Assign(f,ListName); Rewrite(f);
    if NotDiskError then begin
      for i:=0 to WADTitle.Count-1 do begin
        GetWADDir(CurrDir,i,sm);
        sn:=pStrZero2StrSpace(CurrDir.Name,8);
        WriteLn(f,sn);
        if not NotDiskError then break;
      end;
      Close(f)
    end
  end;

begin
  if ParamCount=2 then begin
    WADName:=ParamStr(1);
    if OpenWADFile then begin
      CreateList(ParamStr(2));
      CloseWADFile
    end;
    ErrMessage
  end
  else WriteLn('makelist <file.wad> <outfile.ext>')
end.
