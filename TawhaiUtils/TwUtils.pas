unit TwUtils;

interface

uses
  Vcl.Forms,
  FireDAC.Comp.Client,
  Winapi.Windows,
  System.Types,
  System.SysUtils,
  System.Classes;

type
  TStringMsg = class(TObject)
  private
    FMsgStr: String;
  public
    property MsgStr: string read FMsgStr write FMsgStr;
    constructor Create(AMsgStr: string);
    destructor Destroy; override;
  end;

function CopyLeft(InStr: string; Count: integer): string;
procedure ConstructFileList(AFileSpec: string; ASLFiles: TStringList; AIncFolders: Boolean = True; AClearListFirst: Boolean = True);
procedure ConstructFolderList(APath: string; ASLFolders: TStringList);
function StrToken(var InStr: string; Token: string; IgnoreTokenInQuotes: Boolean = False; CaseInsensitive: Boolean = False): string; overload;
function StrToken(var InStr: string; var TokenFound: Boolean; Token: string; IgnoreTokenInQuotes: Boolean = False; CaseInsensitive: Boolean = False): string; overload;
function MemoryStreamToString(M: TMemoryStream): string;
procedure ConfigureTFDConnection(AConnection: TFDConnection); overload;
procedure ConfigureTFDConnection(AConnection: TFDConnection; ADatabaseName: string); overload;
function GetParentFolderFromFile(FileName: string): string;
function GetParentFolderFromFolder(Folder: string): string;
function FileSize(AFileName: string): Int64;
function FileSizeDesc(AFileName: string): string;
function StrFormatByteSize(dw: DWORD; szBuf: PAnsiChar; uiBufSize: UINT): PAnsiChar; stdcall; external 'shlwapi.dll' name 'StrFormatByteSizeA';
function StrFormatKBSize(qdw: LONGLONG; szBuf: PAnsiChar; uiBufSize: UINT): PAnsiChar; stdcall; external 'shlwapi.dll' name 'StrFormatKBSizeA';
function GetFileVersion(AFileName: string = ''; ASeparator: char = '.'): string; overload;
procedure GetFileVersion(AFileName: string; out AVerA: Word; out AVerB: Word; out AVerC: Word; out AVerD: Word); overload;

implementation

uses
  TwConstants;

var
  LstStringMsgs: TList;

function GetFileVersion(AFileName: string = ''; ASeparator: char = '.'): string;
var
  VersionInfoSize,
  VersionInfoValueSize,
  Zero             : DWord;
  VersionInfo,
  VersionInfoValue : Pointer;
  LastError: Cardinal;
  ErrorMsg: string;
//  VerInfo: TJvVersionInfo;
begin
  Result := '';

  if AFileName.IsEmpty then
    AFileName := Application.ExeName;

  { Obtain size of version info structure }
  VersionInfoSize := GetFileVersionInfoSize(PChar(AFileName), Zero);
  if VersionInfoSize = 0 then
  begin
    LastError := GetLastError;
    ErrorMsg := Format('GetFileVersionInfo failed: (%d) %s', [LastError, SysErrorMessage(LastError)]);
    //SendDebug(ErrorMsg);
    Result := 'unknown';
  end
  else
  begin
    { Allocate memory for the version info structure }
    { This could raise an EOutOfMemory exception }
    GetMem(VersionInfo, VersionInfoSize);
    try
      if GetFileVersionInfo(PChar(AFileName), 0, VersionInfoSize, VersionInfo) and
        VerQueryValue(VersionInfo, '\' { root block }, VersionInfoValue, VersionInfoValueSize) and
         (0 <> LongInt(VersionInfoValueSize)) then
      begin
        with TVSFixedFileInfo(VersionInfoValue^) do
        begin
          Result :=                IntToStr(HiWord(dwFileVersionMS));
          Result := Result + ASeparator + IntToStr(LoWord(dwFileVersionMS));
          Result := Result + ASeparator + IntToStr(HiWord(dwFileVersionLS));
          Result := Result + ASeparator + IntToStr(LoWord(dwFileVersionLS));
        end; { with }
      end; { then }
    finally
      FreeMem(VersionInfo);
    end; { try }
  end;
end;

procedure GetFileVersion(AFileName: string; out AVerA: Word; out AVerB: Word; out AVerC: Word; out AVerD: Word);
var
  VersionInfoSize,
  VersionInfoValueSize,
  Zero             : DWord;
  VersionInfo,
  VersionInfoValue : Pointer;
begin
  AVerA := 0;
  AVerB := 0;
  AVerC := 0;
  AVerD := 0;

  if AFileName = '' then
    AFileName := Application.ExeName;

  { Obtain size of version info structure }
  VersionInfoSize := GetFileVersionInfoSize(PChar(AFileName), Zero);
  if VersionInfoSize = 0 then Exit;
  { Allocate memory for the version info structure }
  { This could raise an EOutOfMemory exception }
  GetMem(VersionInfo, VersionInfoSize);
  try
    if GetFileVersionInfo(PChar(AFileName), 0, VersionInfoSize, VersionInfo) and
      VerQueryValue(VersionInfo, '\' { root block }, VersionInfoValue, VersionInfoValueSize) and
       (0 <> LongInt(VersionInfoValueSize)) then
    begin
      with TVSFixedFileInfo(VersionInfoValue^) do
      begin
        AVerA := HiWord(dwFileVersionMS);
        AVerB := LoWord(dwFileVersionMS);
        AVerC := HiWord(dwFileVersionLS);
        AVerD := LoWord(dwFileVersionLS);
      end; { with }
    end; { then }
  finally
    FreeMem(VersionInfo);
  end; { try }
end;

function FileSize(AFileName: string): Int64;
var
  SearchRec: TSearchRec;
begin
  if FindFirst(AFileName, faAnyFile, SearchRec) = 0 then
    Result := SearchRec.Size
  else
    Result := 0;
  FindClose(SearchRec);
end;

function FileSizeDesc(AFileName: string): string;
var
  arrSize: array[0..255] of AnsiChar;
begin
  {same formatting as in statusbar of Explorer}
  StrFormatByteSize(FileSize(AFileName), arrSize, Length(arrSize)-1);
  Result := string(arrSize);
  Result := Trim(Result);
end;

function GetParentFolderFromFolder(Folder: string): string;
//pass a path to a folder - returns the last folder
var
  i: integer;
  Done: Boolean;
begin
  i := Length(Folder);
  Result := Folder;

  Done := False;
  while not Done and (i > 0) do
    if Result[i] = '\' then Done := True else Dec(i);

  Result := Copy(Result, i+1, Length(Result)-i+1);
end;

function GetParentFolderFromFile(FileName: string): string;
//pass a path to a file - returns the folder that it is in
begin
  Result := ExtractFileDir(FileName);
  Result := GetParentFolderFromFolder(Result);
end;

procedure ConfigureTFDConnection(AConnection: TFDConnection; ADatabaseName: string);
begin
  ConfigureTFDConnection(AConnection);
  AConnection.Params.Values['Database'] := ADatabaseName;
end;

procedure ConfigureTFDConnection(AConnection: TFDConnection);
begin
  //Connection.Params.Values['Database'] := DataMod.Connection.DatabaseName;

  AConnection.DriverName := 'FB';
  AConnection.LoginPrompt := False;
  AConnection.Params.Values['User_Name'] := FIREBIRD_USERNAME;
  AConnection.Params.Values['Password'] := FIREBIRD_PASSWORD;
  AConnection.Params.Values['CharacterSet'] := 'UTF8';
  AConnection.Params.Values['SQLDialect'] := '3';
  //AConnection.Params.Values['ExtendedMetadata'] := 'True';
end;

function MemoryStreamToString(M: TMemoryStream): string;
begin
  SetString(Result, PAnsiChar(M.Memory), M.Size);
end;

function CopyLeft(InStr: string; Count: integer): string;
begin
  //LeftStr()
  Result := Copy(InStr, 1, Count);
end;

procedure ConstructFileList(AFileSpec: string; ASLFiles: TStringList; AIncFolders: Boolean = True; AClearListFirst: Boolean = True);
var
  SearchRec: TSearchRec;
  Done: Boolean;
  FilePath: string;
begin
  //adds to the list all the files that meet FileSpec (eg d:\temp\*.tmp)
  //caller is responsible for creating and destroying the string list
  if AClearListFirst then
    ASLFiles.Clear;

  FilePath := ExtractFileDir(AFileSpec);
  if FindFirst(AFileSpec, faAnyFile, SearchRec) = 0 then
  begin
    Done := False;
    if SearchRec.Name <> '.' then
    begin
      if ASLFiles.IndexOf(FilePath + '\' + SearchRec.Name) = -1 then
        ASLFiles.Add(FilePath + '\' + SearchRec.Name);
    end;
    repeat
      if FindNext(SearchRec) = 0 then
      begin
        if (SearchRec.Attr and faDirectory = faDirectory) and AIncFolders then
          ASLFiles.Add(FilePath + '\' + SearchRec.Name);
        if (SearchRec.Attr and faDirectory <> faDirectory) then
          if SearchRec.Name <> '.' then
          begin
            if ASLFiles.IndexOf(FilePath + '\' + SearchRec.Name) = -1 then
              ASLFiles.Add(FilePath + '\' + SearchRec.Name);
          end;
      end
      else
        Done := True;
    until Done;
  end;
  FindClose(SearchRec);
end;

procedure ConstructFolderList(APath: string; ASLFolders: TStringList);
var
  SearchRec: TSearchRec;
  Done: Boolean;
begin
  //adds to the list all the subfolders that exist in the specified Path
  //(one level only - ie does not find subfolders in any of the subfolders)
  //caller is responsible for creating and destroying the string list
  ASLFolders.Clear;
  APath := IncludeTrailingPathDelimiter(APath);
  APath := CopyLeft(APath, Length(APath) - 1);
  if FindFirst(APath + '\*.*', faDirectory, SearchRec) = 0 then
  begin
    Done := False;
    if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
      ASLFolders.Add(APath + '\' + SearchRec.Name);
    repeat
      if FindNext(SearchRec) = 0 then
      begin
        if (SearchRec.Attr and faDirectory > 0) then
          if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
            ASLFolders.Add(APath + '\' + SearchRec.Name)
      end
      else
        Done := True;
    until Done;
  end;
  FindClose(SearchRec);
end;

function StrToken(var InStr: string; Token: string; IgnoreTokenInQuotes: Boolean = False; CaseInsensitive: Boolean = False): string;
var
  i: Integer;
  InQuotes: Boolean;
begin
  //returns InStr up to the first occurrence of Token and chops the returned
  //characters and the token from InStr

  if IgnoreTokenInQuotes then
  begin
    InQuotes := False;
    for i := 1 to Length(InStr) do
    begin
      if Copy(InStr, i, 1) = '"' then
        InQuotes := not InQuotes;
      if CaseInsensitive then
      begin
        if (Copy(UpperCase(InStr), i, Length(Token)) = UpperCase(Token)) and not InQuotes then
          Break;
      end
      else
      begin
        if (Copy(InStr, i, Length(Token)) = Token) and not InQuotes then
          Break;
      end;
    end;
  end
  else
  begin
    if CaseInsensitive then
      i := Pos(UpperCase(Token), UpperCase(InStr))
    else
      i := Pos(Token, InStr);
  end;

  if i = 0 then
  begin
    Result := InStr;
    InStr := '';
  end
  else
  begin
    Result := Copy(InStr, 1, i-1);
    //InStr := Copy(InStr, i+1, Length(InStr)-i);
    InStr := Copy(InStr, i+Length(Token), Length(InStr)-i-Length(Token)+1);
  end;
end;

function StrToken(var InStr: string; var TokenFound: Boolean; Token: string; IgnoreTokenInQuotes,
  CaseInsensitive: Boolean): string;
var
  i: integer;
  InQuotes: Boolean;
begin
  //returns InStr up to the first occurrence of Token and chops the returned
  //characters and the token from InStr

  if InStr = '' then Exit;

  if CaseInsensitive then
    TokenFound := (Pos(UpperCase(Token), UpperCase(InStr)) > 0)
  else
    TokenFound := (Pos(Token, InStr) > 0);

  if IgnoreTokenInQuotes then
  begin
    InQuotes := False;
    for i := 1 to Length(InStr) do
    begin
      if Copy(InStr, i, 1) = '"' then
        InQuotes := not InQuotes;
      if CaseInsensitive then
      begin
        if (Copy(UpperCase(InStr), i, Length(Token)) = UpperCase(Token)) and not InQuotes then
          break;
      end
      else
      begin
        if (Copy(InStr, i, Length(Token)) = Token) and not InQuotes then
          break;
      end;
    end;
  end
  else
  begin
    if CaseInsensitive then
      i := Pos(UpperCase(Token), UpperCase(InStr))
    else
      i := Pos(Token, InStr);
  end;

  if i = 0 then
  begin
    Result := InStr;
    InStr := '';
  end
  else
  begin
    Result := Copy(InStr, 1, i-1);
    //InStr := Copy(InStr, i+1, Length(InStr)-i);
    InStr := Copy(InStr, i+Length(Token), Length(InStr)-i-Length(Token)+1);
  end;
end;

{ TStringMsg }

constructor TStringMsg.Create(AMsgStr: string);
begin
  inherited Create;
  FMsgStr := AMsgStr;
  //SendDebug('TLogMsg created ' + AMsgStr);
  LstStringMsgs.Add(Self);
end;

destructor TStringMsg.Destroy;
begin
  //SendDebug('TLogMsg destroyed ' + FMsgStr);
  LstStringMsgs.Remove(Self);
  inherited;
end;

initialization
  LstStringMsgs := TList.Create;

finalization
  //free any messages that were posted but not processed before the app terminated
  while LstStringMsgs.Count > 0 do
    TStringMsg(LstStringMsgs[0]).Free;

  LstStringMsgs.Free;
end.
