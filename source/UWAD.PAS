
Unit UWAD;

Interface

Const
  MaxMastDir  = 4094;

  e_NoError   =  0;
  e_DiskError = -1;
  e_NoWAD     = -2;
  e_NoMemory  = -5;

  sPWAD       = 'PWAD';
  sIWAD       = 'IWAD';

Type
  tName    = array[0..7] of char;
  MastDir  = record
               Start,Size: longint;
               Name      : tName;
             end;

  tWADTitle= record
               Tit         : array[0..3] of char;
               Count,Start : longint
             end;

  tByte      = array [0..65534] of byte;
  tLongint   = array [0..16382] of longint;
  tArMastDir = array [0..MaxMastDir] of MastDir;

Var
  WADFile  : file;
  WADName  : string[80];

  Error    : integer;
  WADDir,
  WADDirSt : pointer;
  WADTitle : tWADTitle;

function UpStr(s: string): string;
procedure StrSpace2PStrZero(S: string; var St: tName; Count: word);
function PStrZero2StrSpace(var St; Count: word): string;
function NotDiskError: boolean;
procedure AddWADDir(var CD: MastDir; Num: integer; sm: longint);
procedure GetWADDir(var CD: MastDir; Num: integer; var sm: longint);
procedure CloseWADFile;
function OpenWADFile: boolean;
procedure ErrMessage;

Implementation

function UpStr(s: string): string;
  var i: byte;
  begin
    for i:=1 to byte(s[0]) do s[i]:=UpCase(s[i]);
    UpStr:=s
  end;

procedure StrSpace2PStrZero(S: string; var St: tName; Count: word);
  var
    i: word; e: char;
  begin
    s:=UpStr(s);
    for i:=1 to Count do begin
      if i<=byte(s[0]) then begin
        e:=S[i]; if e=#32 then e:=#0
      end
      else e:=#0;
      St[i-1]:=e
    end;
  end;

function PStrZero2StrSpace(var St; Count: word): string;
  var
    i: word; s: string; e: char;
  begin
    s:='';
    for i:=0 to Count-1 do begin
      e:=Char(tByte(St)[i]); if e=#0 then e:=#32;
      s:=s+e
    end;
    s[0]:=Char(Count);
    PStrZero2StrSpace:=UpStr(s)
  end;

function NotDiskError: boolean;
  begin
    NotDiskError:=InOutRes=0;
    if IOResult<>0 then Error:=e_DiskError
  end;

procedure AddWADDir(var CD: MastDir; Num: integer; sm: longint);
  begin
    tArMastDir(WADDir^)[Num]:=CD;
    tLongint(WADDirSt^)[Num]:=sm
  end;

procedure GetWADDir(var CD: MastDir; Num: integer; var sm: longint);
  begin
    CD:=tArMastDir(WADDir^)[Num];
    sm:=tlongint(WADDirSt^)[Num];
  end;

procedure CloseWADFile;
  begin
    Close(WADFile); InOutRes:=0
  end;

function OpenWADFile: boolean;
  var s: string[4];

  function ReadMastDir: boolean;
    var
      i  : integer;
      CD : MastDir;
      sm : longint;
    begin
      ReadMastDir:=false;
      GetMem(WADDir,WADTitle.Count*SizeOf(MastDir));
      GetMem(WADDirSt,WADTitle.Count*SizeOf(longint));
      if (WADDir = nil) or (WADDirSt = nil) or (WADTitle.Count>MaxMastDir) then Error:=e_NoMemory
      else begin
        Seek(WADFile,WADTitle.Start);
        if NotDiskError then begin
          for i:=1 to WADTitle.Count do begin
            sm:=FilePos(WADFile);
            BlockRead(WADFile,CD,SizeOf(MastDir));
            if NotDiskError then AddWADDir(CD,i-1,sm+8)
          end;
          ReadMastDir:=Error=e_NoError
        end
      end
    end;

  begin
    OpenWADFile:=false;
    Assign(WADFile,WADName);
    Reset(WADFile,1);
    if NotDiskError then begin
      BlockRead(WADFile,WADTitle,SizeOf(tWADTitle));
      if NotDiskError then begin
        s:=PStrZero2StrSpace(WADTitle.Tit,4);
        if (s=sPWAD) or (s=sIWAD) then
          if ReadMastDir then OpenWADFile:=true
          else
        else Error:=e_NoWAD
      end
      else Close(WADFile)
    end
  end;

procedure ErrMessage;
  var   s: string;
  begin
    case Error of
      e_NoError     : s:='';
      e_DiskError   : s:='Ошибка диска';
      e_NoWAD       : s:='Это не PWAD/IWAD файл';
      e_NoMemory    : s:='Нет памяти';
      else            s:='Глюки'
    end;
    WriteLn(s+#13#10);
  end;

end.
