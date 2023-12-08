unit UORM;

interface

uses
  Data.SqlExpr, classes, System.Rtti, System.TypInfo;

type

TModal = class
   key : string;
   AutoIncremment : boolean;
end;


TORM = class
   private
      FQuery : TSQLQuery;
      FPpropInfo : PPropInfo;
      FCtx : TRttiContext;
      FTypeInfo : PTypeInfo;
      FProp: TRttiProperty;
      TypeObject : TRttiType;
      FClassName : String;
      FKey : string;
      FAutoIncremment : boolean;
   public
     procedure  Add(pObject : TObject);
     procedure  Remove(pObject: TObject);
     procedure  Update(pObject : TObject);
     procedure  SaveChange();
     function GetPropertyValue(pProp : string; ArrayFields : TArray<TRttiField>; pObject: TObject) : string;
     constructor Create(PConexao : TSQLConnection);
end;

implementation

uses
  System.SysUtils, System.Generics.Collections;

{ TORM }

function TORM.GetPropertyValue(pProp : string; ArrayFields : TArray<TRttiField>; pObject: TObject) : string;
var
    I: Integer;
    propResult : string;
begin
   propResult := string.empty;
   for I := 0 to length(ArrayFields)-1 do
      if ArrayFields[I].Name = pProp then
      begin
         propResult := ArrayFields[I].GetValue(pObject).ToString;
         Break;
      end;

   Result := propResult;
end;

constructor TORM.Create(PConexao: TSQLConnection);
begin
   FQuery := TSQLQuery.Create(nil);
   FQuery.SQLConnection := PConexao;
   FQuery.SQL.Clear;
   FCtx   := TRttiContext.Create;
end;

procedure TORM.Remove(pObject: TObject);
var
  ArrayFields : TArray<TRttiField>;
  I: Integer;
begin
   TypeObject  := FCtx.GetType(pObject.ClassType);
   FTypeInfo   := TypeObject.Handle;
   ArrayFields := TypeObject.GetFields;
   FClassName  := Copy(TypeObject.Name,2,length(TypeObject.Name)-1);
   FPpropInfo  := GetPropInfo(pObject.ClassType,ArrayFields[0].Name);

   FQuery.SQL.Add('DELETE FROM '+FClassName);

   for I := 0 to length(ArrayFields)-1 do
   begin
      if ArrayFields[I].Name = 'key' then
      FQuery.SQL.Add(' WHERE '+ArrayFields[I].GetValue(pObject).ToString+
      ' = "'+GetPropertyValue(ArrayFields[I].GetValue(pObject).ToString,ArrayFields,pObject)+'";');
   end;
end;

procedure TORM.SaveChange;
begin
    FQuery.ExecSQL();
    FQuery.SQL.Clear;
end;

procedure TORM.Update(pObject: TObject);
var
  ArrayFields : TArray<TRttiField>;
  I : Integer;
  SqlFields, SqlValues : string;
begin
    TypeObject  := FCtx.GetType(pObject.ClassType);
    FTypeInfo   := TypeObject.Handle;
    ArrayFields := TypeObject.GetFields;
    FClassName  := Copy(TypeObject.Name,2,length(TypeObject.Name)-1);
    SqlValues   := string.empty;
    SqlFields   := string.empty;

    FQuery.SQL.Add(' UPDATE '+FClassName+' SET ');
    for I := 0 to length(ArrayFields)-1 do
    begin
       if(ArrayFields[I].Name = 'AutoIncremment')then
       begin
         FAutoIncremment := strToBool(ArrayFields[I].GetValue(pObject).ToString);
         continue;
       end;

       if(ArrayFields[I].Name = 'key')then
       begin
         FKey := ArrayFields[I].GetValue(pObject).ToString;
         continue;
       end;
       if(ArrayFields[I].FieldType.ToString = 'string') then
          SqlValues := SqlValues+ArrayFields[I].Name+'='+QuotedStr(ArrayFields[I].GetValue(pObject).ToString)+','
       else if((ArrayFields[I].FieldType.ToString = 'Boolean'))then
       begin
           if(ArrayFields[I].GetValue(pObject).ToString = 'True')then
             SqlValues := SqlValues+ArrayFields[I].Name+'='+'1,'
           else
           SqlValues := SqlValues+ArrayFields[I].Name+'='+'0,'
       end
       else if(ArrayFields[I].FieldType.ToString = 'Currency')
       or(ArrayFields[I].FieldType.ToString = 'Float')
       or(ArrayFields[I].FieldType.ToString = 'Decimal')
       or(ArrayFields[I].FieldType.ToString = 'Real')
       then
       begin
           SqlValues := SqlValues+ArrayFields[I].Name+'='+ArrayFields[I].GetValue(pObject).ToString.Replace(',','.')+','
       end
       else if(ArrayFields[I].FieldType.ToString = 'TDateTime')or(ArrayFields[I].FieldType.ToString = 'TDate')then
       begin
          SqlValues := SqlValues+ArrayFields[I].Name+
          '='+QuotedStr(formatDateTime('yyyy-mm-dd',StrToDate(ArrayFields[I].GetValue(pObject).ToString)))+','
       end
       else
           SqlValues := SqlValues+ArrayFields[I].Name+'='+ArrayFields[I].GetValue(pObject).ToString+','

    end;
    FQuery.SQL.Add(copy(SqlValues,1,SqlValues.Length-1));
    for I := 0 to length(ArrayFields)-1 do
    begin
      if ArrayFields[I].Name = 'key' then
      FQuery.SQL.Add(' WHERE '+ArrayFields[I].GetValue(pObject).ToString+' = "'+GetPropertyValue(ArrayFields[I].GetValue(pObject).ToString,ArrayFields,pObject)+'";');
   end;

end;

procedure TORM.Add(pObject: TObject);
var
  ArrayFields : TArray<TRttiField>;
  I: Integer;
  SqlFields,SqlValues : string;
begin
   TypeObject := FCtx.GetType(pObject.ClassType);
   FTypeInfo  := TypeObject.Handle;
   ArrayFields:= TypeObject.GetFields;
   FClassName := Copy(TypeObject.Name,2,length(TypeObject.Name)-1);
   SqlValues  := string.empty;
   SqlFields  := string.empty;

   FQuery.SQL.Clear();
   FQuery.SQL.Add('INSERT INTO '+FClassName+'(');

   for I := 0 to length(ArrayFields)-1 do
   begin
      if(ArrayFields[I].Name = 'AutoIncremment')then
      begin
         FAutoIncremment := strToBool(ArrayFields[I].GetValue(pObject).ToString);
         continue;
      end;

      if(ArrayFields[I].Name = 'key')then
      begin
         FKey := ArrayFields[I].GetValue(pObject).ToString;
         continue;
      end;
      SqlFields := SqlFields + ArrayFields[I].Name+',';
   end;

   FQuery.SQL.Add(copy(SqlFields,1,SqlFields.Length -1)+')');
   FQuery.SQL.Add(' VALUES (');

   for I := 0 to length(ArrayFields)-1 do
   begin
       if(ArrayFields[I].Name = 'key') or (ArrayFields[I].Name = 'AutoIncremment')then
          continue;

       if(ArrayFields[I].FieldType.ToString = 'string') then
           SqlValues := SqlValues + QuotedStr(ArrayFields[I].GetValue(pObject).ToString)+','

       else if((ArrayFields[I].FieldType.ToString = 'Boolean'))then
       begin
           if(ArrayFields[I].GetValue(pObject).ToString = 'True')then
             SqlValues := SqlValues +'1,'
           else
              SqlValues := SqlValues +'0,'
       end
       else if(ArrayFields[I].FieldType.ToString = 'Currency')
       or(ArrayFields[I].FieldType.ToString = 'Float')
       or(ArrayFields[I].FieldType.ToString = 'Decimal')
       or(ArrayFields[I].FieldType.ToString = 'Real')
       then
       begin
           SqlValues := SqlValues + (ArrayFields[I].GetValue(pObject).ToString).Replace(',','.')+','
       end
       else if(ArrayFields[I].FieldType.ToString = 'TDateTime')or(ArrayFields[I].FieldType.ToString = 'TDate')then
       begin
           SqlValues := SqlValues + QuotedStr(formatDateTime('yyyy-mm-dd',strTodate(ArrayFields[I].GetValue(pObject).ToString)))+','
       end
       else
           SqlValues := SqlValues + ArrayFields[I].GetValue(pObject).ToString+','
   end;
   FQuery.SQL.Add(copy(SqlValues,1,SqlValues.Length -1)+');');
   //comentário para commit





end;

end.
