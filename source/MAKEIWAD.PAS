(*$S-,R-,V-,B-,I-*)
(*$D+,L+*)
(*$M 64512,0,655360*)

Program MakeIWAD;
Uses UWAD;

procedure Make_IWAD;
  const
    bufcnt  = 64000;
  type
    tbyte = array[1..65520] of byte;
  var
    i,j,numb  : integer;
    l,sm,Size : longint;
    Sz        : longint;
    CurrDir   : MastDir;
    WTit      : tWADTitle;
    mIn,mOut  : tName;
    Map       : tName;
    f         : file;
    q         : text;
    Pmem      : pointer;
    StartM    : array[0..3000] of longint;
    Name      : array[0..3000] of string[8];
    txt,s2    : string;

  procedure OpenFiles;
    begin
      Assign(f,'doom2my.wad'); Rewrite(f,1);
      if IOResult<>0 then begin Error:=e_DiskError; exit end;
      Assign(q,'doom2res.lst'); Reset(q);
      if IOResult<>0 then begin Error:=e_DiskError; exit end;
      WTit.Tit:='IWAD';
      WTit.Count:=WADTitle.Count;
      BlockWrite(f,WTit,SizeOf(WTit));
      NotDiskError
    end;

  procedure CopyRawFromExternalFile;
    var ff: file;
    begin
      Write(i:4,#13);
      Assign(ff,Copy(txt,25,12));
      Reset(ff,1);
      if IOResult<>0 then begin
        WriteLn(#13#10'no file!'); halt
      end;
      GetWADDir(CurrDir,i,l);
      StartM[i]:=FilePos(f);
      CurrDir.Size:=FileSize(ff);
      AddWADDir(CurrDir,i,l);
      Size:=FileSize(ff);
      while NotDiskError and (Size>0) and (Error=e_NoError) do begin
        if Size>bufcnt then Sz:=bufcnt
        else Sz:=Size;
        BlockRead(ff,PMem^,Sz);
        BlockWrite(f,PMem^,Sz);
        Dec(Size,Sz)
      end;
    end;

  procedure CopyRaw;
    var j: word;

    procedure ChangeColor(Size: word);
      var Col1,Col2: byte;
          z        : word;
      const
        Col : array['0'..'F'] of byte = (0,1,2,3,4,5,6,7,8,9,
                                         0,0,0,0,0,0,0,
                                         10,11,12,13,14,15);
      begin
        Col1:=Col[txt[25]]; Col2:=Col[txt[26]];
        if not ((Col1 in [0..15]) and (Col2 in [0..15])) then begin
          WriteLn('намудрили'); halt
        end;
        for z:=9+tbyte(pMem^)[1]*4 to Size-1 do
          if (tbyte(pMem^)[z] div 16) = Col1 then
            tbyte(pMem^)[z]:=(Col2 shl 4)+(tbyte(pMem^)[z] mod 16);
      end;

    begin
      Write(i:4,#13); txt:=txt+' ';
      for j:=i to i+numb do begin
        GetWADDir(CurrDir,j,l);
        Seek(WADFile,CurrDir.Start);
        StartM[j]:=FilePos(f);
        Size:=CurrDir.Size;
        while NotDiskError and (Size>0) and (Error=e_NoError) do begin
          if Size>bufcnt then Sz:=bufcnt
          else Sz:=Size;
          BlockRead(WADFile,PMem^,Sz);
          if txt[18]='C' then ChangeColor(Sz);
          BlockWrite(f,PMem^,Sz);
          Dec(Size,Sz)
        end;
        if Error<>e_NoError then break
      end;
    end;

  procedure MakeTable;
    var
      i,m,numb: word;
      CurrDir1: MastDir;

    function FindName(Name: string): word;
      var z: word;
      begin
        for z:=0 to WADTitle.Count-1 do begin
          GetWADDir(CurrDir1,z,l);
          if Copy(PStrZero2StrSpace(CurrDir1.Name,8),1,byte(Name[0]))=Name then begin
            FindName:=z; exit
          end;
        end;
        FindName:=MaxInt
      end;

    procedure SwitchAddr(i: word; var CD: MastDir);
      var k : word;
      begin
        k:=FindName(Name[i]);
        if k=MaxInt then begin
          WriteLn(#13#10'облом'); halt
        end;
        with CD do begin
          Start:=StartM[k];
          Size:=CurrDir1.Size
        end
      end;

    procedure Maps;
      var j: byte;
          n: word;
      begin
        if Name[i]='' then
          for j:=0 to 10 do begin
            GetWADDir(CurrDir,i+j,l);
            CurrDir.Start:=StartM[i+j];
            if Error=e_NoError then BlockWrite(f,CurrDir,SizeOf(CurrDir));
            NotDiskError
          end
        else begin
          n:=FindName(Name[i]);
          for j:=0 to 10 do begin
            GetWADDir(CurrDir1,n+j,l);
            CurrDir1.Start:=StartM[n+j];
            if j=0 then CurrDir1.Name:=CurrDir.Name;
            if Error=e_NoError then BlockWrite(f,CurrDir1,SizeOf(CurrDir1));
            NotDiskError
          end;
        end;
        inc(i,10)
      end;

    begin
      WriteLn(#13#10'Обработка смещений:');
      Sz:=FilePos(f);
      for i:=0 to WADTitle.Count-1 do
        if Error=e_NoError then begin
          Write(i:4,#13);
          GetWADDir(CurrDir,i,l);

          if Copy(PStrZero2StrSpace(CurrDir.Name,8),1,3)='MAP' then Maps
          else begin
            if Name[i]='' then CurrDir.Start:=StartM[i]
            else SwitchAddr(i,CurrDir);
            if Error=e_NoError then BlockWrite(f,CurrDir,SizeOf(CurrDir));
            NotDiskError
          end;

        end;
      if Error=e_NoError then begin
        Seek(f,8); BlockWrite(f,Sz,4)
      end;
      Close(f)
    end;

  begin
    OpenFiles;
    GetMem(Pmem,bufcnt);
    if PMem=nil then Error:=e_NoMemory
    else begin
      WriteLn('Обработка ресурсов:');
      for i:=0 to WADTitle.Count-1 do Name[i]:='';
      for i:=0 to WADTitle.Count-1 do begin
        ReadLn(q,txt);
        GetWADDir(CurrDir,i,sm);

        s2:=PStrZero2StrSpace(CurrDir.Name,8);
        if s2<>Copy(txt,1,8) then begin
          WriteLn(#13#10,'непорядок'); halt
        end;

        if Copy(PStrZero2StrSpace(CurrDir.Name,8),1,3)='MAP' then numb:=10
        else numb:=0;
        case txt[17] of
          'S' : Name[i]:=Copy(txt,25,8);
          'N' : ;
          'F' : CopyRawFromExternalFile;
          else  CopyRaw (* 'C' *)
        end;
        inc(i,numb);
        for j:=1 to Numb do ReadLn(q,txt);
      end;
      MakeTable
    end
  end;

begin
  WADName:='/games/doom/doom2/doom2.wad';
  if OpenWADFile then begin
    Make_IWAD;
    CloseWADFile
  end;
  ErrMessage
end.
