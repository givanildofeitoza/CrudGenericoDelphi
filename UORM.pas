unit UORM;

interface

uses
  Data.SqlExpr,SysUtils, classes, System.Rtti, System.TypInfo, System.Generics.Collections, Models;

type
TPaginate = class
  public
     Skip : Integer;
     Take : Integer;
     Total: Integer;
     CurrentPage : Integer;

     constructor Create(pSkip,pTake,pTotal,pCurrentPage : integer);
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
     procedure  Add(pObject : TModal);
     procedure  Remove(pObject: TModal);
     procedure  Update(pObject : TModal);
     procedure  SaveChange();
     class function CreateInstance<T:class,constructor>: T;
     function PropertyNameFormat(pProp : string):string;
     function GetAll<T:class,constructor>(pPaginate : TPaginate): TObjectList<T>;
     function GetById<T:class,constructor>(pId : integer): T;
     function GetPropertyValue(pProp : string; ArrayFields : TArray<TRttiField>; pObject: TObject) : string;
     constructor Create(PConexao : TSQLConnection);
end;



implementation

{ TORM }

function TORM.GetAll<T>(pPaginate : TPaginate): TObjectList<T>;
var
  modelList : TObjectList<T>;
  model,modelAdd : T;
  ArrayFields : TArray<TRttiField>;
  I : integer;
  vPropriedade: TRttiProperty;
begin
   try
       modelList   := TObjectList<T>.Create();
       model       := CreateInstance<T>;

       TypeObject  := FCtx.GetType(model.ClassType);
       ArrayFields := TypeObject.GetFields;
       FClassName  := Copy(TypeObject.Name,2,length(TypeObject.Name)-1);

       FQuery.SQL.Clear;
       FQuery.SQL.Add('SELECT * FROM '+FClassName+' LIMIT '+pPaginate.Skip.ToString+','+pPaginate.Take.ToString());
       FQuery.Open;

       FQuery.First;
       while not FQuery.Eof do
       begin
           modelAdd     := CreateInstance<T>;
           for I := 0 to length(ArrayFields)-1 do
           begin

              if not((ArrayFields[I].Name = 'key') or (ArrayFields[I].Name = 'AutoIncremment'))then
              begin

                 vPropriedade := TypeObject.GetProperty(Copy(ArrayFields[I].Name,2,ArrayFields[I].Name.Length-1));

                 if (ArrayFields[I].FieldType.ToString = 'Currency')
                   or(ArrayFields[I].FieldType.ToString = 'Float')
                   or(ArrayFields[I].FieldType.ToString = 'Decimal')
                   or(ArrayFields[I].FieldType.ToString = 'Real')
                 then
                    vPropriedade.SetValue(Pointer(modelAdd), FQuery.FindField(Copy(ArrayFields[I].Name,2,ArrayFields[I].Name.Length-1)).AsCurrency)

                 else if ArrayFields[I].FieldType.ToString = 'string' then
                   vPropriedade.SetValue(Pointer(modelAdd), FQuery.FindField(Copy(ArrayFields[I].Name,2,ArrayFields[I].Name.Length-1)).AsString)

                 else if ArrayFields[I].FieldType.ToString = 'Boolean' then
                 begin
                     if FQuery.FindField(Copy(ArrayFields[I].Name,2,ArrayFields[I].Name.Length-1)).AsInteger = 0 then
                         vPropriedade.SetValue(Pointer(modelAdd), False )
                     else
                         vPropriedade.SetValue(Pointer(modelAdd), True )
                 end
                 else if (ArrayFields[I].FieldType.ToString = 'TDate') or (ArrayFields[I].FieldType.ToString = 'TDateTime') then
                    vPropriedade.SetValue(Pointer(modelAdd), FQuery.FindField(Copy(ArrayFields[I].Name,2,ArrayFields[I].Name.Length-1)).AsDateTime)

                 else if ArrayFields[I].FieldType.ToString = 'Integer' then
                    vPropriedade.SetValue(Pointer(modelAdd), FQuery.FindField(Copy(ArrayFields[I].Name,2,ArrayFields[I].Name.Length-1)).AsInteger);
              end;

           end;

          modelList.Add(modelAdd);
          FQuery.Next;
       end;
   finally
       model.free;
   end;

   Result :=  modelList;
end;

function TORM.GetById<T>(pId: integer): T;
var
  model : T;
  ArrayFields : TArray<TRttiField>;
  I : integer;
  vPropriedade: TRttiProperty;
begin
  try
     model       := CreateInstance<T>;
     TypeObject  := FCtx.GetType(model.ClassType);
     ArrayFields := TypeObject.GetFields;
     FClassName  := Copy(TypeObject.Name,2,length(TypeObject.Name)-1);

     for I := length(ArrayFields)-1 downto 0 do
     begin
          if ArrayFields[I].Name = 'key' then
          begin
             FKey := ArrayFields[I].GetValue(Pointer(model)).ToString;
             FQuery.SQL.Clear;
             FQuery.SQL.Add('SELECT * FROM '+FClassName+' WHERE '+FKey);
             FQuery.SQL.Add(' = "'+pId.ToString+'" LIMIT 1;');
             break;
          end;
     end;
     FQuery.Open;
     FQuery.First;
       while not FQuery.Eof do
       begin

           for I := 0 to length(ArrayFields)-1 do
           begin

              if not((ArrayFields[I].Name = 'key') or (ArrayFields[I].Name = 'AutoIncremment'))then
              begin

                 vPropriedade := TypeObject.GetProperty(Copy(ArrayFields[I].Name,2,ArrayFields[I].Name.Length-1));

                 if (ArrayFields[I].FieldType.ToString = 'Currency')
                   or(ArrayFields[I].FieldType.ToString = 'Float')
                   or(ArrayFields[I].FieldType.ToString = 'Decimal')
                   or(ArrayFields[I].FieldType.ToString = 'Real')
                 then
                    vPropriedade.SetValue(Pointer(model), FQuery.FindField(Copy(ArrayFields[I].Name,2,ArrayFields[I].Name.Length-1)).AsCurrency)

                 else if ArrayFields[I].FieldType.ToString = 'string' then
                   vPropriedade.SetValue(Pointer(model), FQuery.FindField(Copy(ArrayFields[I].Name,2,ArrayFields[I].Name.Length-1)).AsString)

                 else if ArrayFields[I].FieldType.ToString = 'Boolean' then
                 begin
                     if FQuery.FindField(Copy(ArrayFields[I].Name,2,ArrayFields[I].Name.Length-1)).AsInteger = 0 then
                         vPropriedade.SetValue(Pointer(model), False )
                     else
                         vPropriedade.SetValue(Pointer(model), True )
                 end
                 else if (ArrayFields[I].FieldType.ToString = 'TDate') or (ArrayFields[I].FieldType.ToString = 'TDateTime') then
                    vPropriedade.SetValue(Pointer(model), FQuery.FindField(Copy(ArrayFields[I].Name,2,ArrayFields[I].Name.Length-1)).AsDateTime)

                 else if ArrayFields[I].FieldType.ToString = 'Integer' then
                    vPropriedade.SetValue(Pointer(model), FQuery.FindField(Copy(ArrayFields[I].Name,2,ArrayFields[I].Name.Length-1)).AsInteger);
              end;

           end;

          FQuery.Next;
       end;

       Result := model;
  finally

  end;
end;

function TORM.GetPropertyValue(pProp : string; ArrayFields : TArray<TRttiField>; pObject: TObject) : string;
var
    I: Integer;
    propResult : string;
begin
   propResult := string.empty;
   for I := 0 to length(ArrayFields)-1 do
      if PropertyNameFormat(ArrayFields[I].Name) = pProp then
      begin
         propResult := ArrayFields[I].GetValue(pObject).ToString;
         Break;
      end;

   Result := propResult;
end;

function TORM.PropertyNameFormat(pProp: string): string;
begin
    Result := Copy(pProp,2,pProp.Length-1);
end;

constructor TORM.Create(PConexao: TSQLConnection);
begin
   FQuery := TSQLQuery.Create(nil);
   FQuery.SQLConnection := PConexao;
   FQuery.SQL.Clear;
   FCtx   := TRttiContext.Create;
end;

class function TORM.CreateInstance<T>: T;
begin
   Result := T.Create();
end;

procedure TORM.Remove(pObject: TModal);
var
  ArrayFields : TArray<TRttiField>;
  I: Integer;
begin
   TypeObject  := FCtx.GetType(pObject.ClassType);
   FTypeInfo   := TypeObject.Handle;
   ArrayFields := TypeObject.GetFields;
   FClassName  := Copy(TypeObject.Name,2,length(TypeObject.Name)-1);
   FPpropInfo  := GetPropInfo(pObject.ClassType,ArrayFields[0].Name);

  for I := 0 to length(ArrayFields)-1 do
   begin
      if ArrayFields[I].Name = 'key' then
      begin
         FKey := ArrayFields[I].GetValue(pObject).ToString;
         if (FKey <> string.Empty) and (GetPropertyValue(ArrayFields[I].GetValue(pObject).ToString,ArrayFields,pObject)<>string.empty)then
             FQuery.SQL.Add('DELETE FROM '+FClassName+' WHERE ');

         FQuery.SQL.Add(ArrayFields[I].GetValue(pObject).ToString+
         ' = "'+GetPropertyValue(ArrayFields[I].GetValue(pObject).ToString,ArrayFields,pObject)+'";');
      end;
   end;

   if FKey = string.Empty then
   begin
      FQuery.SQL.Clear;
      raise Exception.Create('Erro de exclus�o: Nenhuma key informada!');
   end;
   if(FQuery.SQL.Text.Replace(' ',string.empty) = ('DELETE FROM '+FClassName).Replace(' ',string.empty))then
   begin
      FQuery.SQL.Clear;
      raise Exception.Create('Erro de exclus�o: Clausula WHERE deve ser informada com uma chave prim�ria (key)!');
   end;

end;

procedure TORM.SaveChange;
begin
   try
     FQuery.ExecSQL();
     FQuery.SQL.Clear;
   except
      raise Exception.Create('Erro ao persistir no DB !');
   end;
end;

procedure TORM.Update(pObject: TModal);
var
  ArrayFields : TArray<TRttiField>;
  I : Integer;
  SqlFields, SqlValues : string;
  ClausulaWhereGerada : Boolean;
begin
    TypeObject  := FCtx.GetType(pObject.ClassType);
    FTypeInfo   := TypeObject.Handle;
    ArrayFields := TypeObject.GetFields;
    FClassName  := Copy(TypeObject.Name,2,length(TypeObject.Name)-1);
    SqlValues   := string.empty;
    SqlFields   := string.empty;
    FQuery.SQL.Clear;
    ClausulaWhereGerada := False;

    for I := length(ArrayFields)-1 downto 0  do
    begin
       if(ArrayFields[I].Name = 'AutoIncremment')then
       begin
         FAutoIncremment := strToBool(ArrayFields[I].GetValue(pObject).ToString);
         continue;
       end;

       if(ArrayFields[I].Name = 'key')then
       begin
         FKey := ArrayFields[I].GetValue(pObject).ToString;
         if (FKey <> string.empty) and (GetPropertyValue(FKey,ArrayFields,pObject) <> string.empty) then
             FQuery.SQL.Add(' UPDATE '+FClassName+' SET ')
         else
             raise Exception.Create('Erro de atualiza��o do DB: Nenhuma Key informada!');

         continue;
       end;

       if PropertyNameFormat(ArrayFields[I].Name) <> FKey then
       begin
             if(ArrayFields[I].FieldType.ToString = 'string') then
                SqlValues := SqlValues+PropertyNameFormat(ArrayFields[I].Name)+'='+QuotedStr(ArrayFields[I].GetValue(pObject).ToString)+','
             else if((ArrayFields[I].FieldType.ToString = 'Boolean'))then
             begin
                 if(ArrayFields[I].GetValue(pObject).ToString = 'True')then
                   SqlValues := SqlValues+PropertyNameFormat(ArrayFields[I].Name)+'='+'1,'
                 else
                 SqlValues := SqlValues+PropertyNameFormat(ArrayFields[I].Name)+'='+'0,'
             end
             else if(ArrayFields[I].FieldType.ToString = 'Currency')
             or(ArrayFields[I].FieldType.ToString = 'Float')
             or(ArrayFields[I].FieldType.ToString = 'Decimal')
             or(ArrayFields[I].FieldType.ToString = 'Real')
             then
             begin
                 SqlValues := SqlValues+PropertyNameFormat(ArrayFields[I].Name)+'='+ArrayFields[I].GetValue(pObject).ToString.Replace(',','.')+','
             end
             else if(ArrayFields[I].FieldType.ToString = 'TDateTime')or(ArrayFields[I].FieldType.ToString = 'TDate')then
             begin
                SqlValues := SqlValues+PropertyNameFormat(ArrayFields[I].Name)+
                '='+QuotedStr(formatDateTime('yyyy-mm-dd',StrToDate(ArrayFields[I].GetValue(pObject).ToString)))+','
             end
             else
                 SqlValues := SqlValues+PropertyNameFormat(ArrayFields[I].Name)+'='+ArrayFields[I].GetValue(pObject).ToString+','

       end

    end;

    FQuery.SQL.Add(copy(SqlValues,1,SqlValues.Length-1));

    for I := 0 to length(ArrayFields)-1 do
    begin
      if ArrayFields[I].Name = 'key' then
      begin
         FQuery.SQL.Add(' WHERE '+ArrayFields[I].GetValue(pObject).ToString+' = "'
         +GetPropertyValue(ArrayFields[I].GetValue(pObject).ToString,ArrayFields,pObject)+'";');

         ClausulaWhereGerada := True;
      end;
   end;

   if not ClausulaWhereGerada then
   begin
      FQuery.SQL.Clear;
      raise Exception.Create('Erro na atualiza��o do Db: Clausula WHERE n�o gerada.');
   end;

end;

procedure TORM.Add(pObject: TModal);
var
  ArrayFields : TArray<TRttiField>;
  I: Integer;
  SqlFields,SqlValues,campo : string;
begin
   TypeObject := FCtx.GetType(pObject.ClassType);
   FTypeInfo  := TypeObject.Handle;
   ArrayFields:= TypeObject.GetFields;
   FClassName := Copy(TypeObject.Name,2,length(TypeObject.Name)-1);
   SqlValues  := string.empty;
   SqlFields  := string.empty;

   FQuery.SQL.Clear();
   FQuery.SQL.Add('INSERT INTO '+FClassName+'(');

   for I:= length(ArrayFields)-1 downto  0  do
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

      if PropertyNameFormat(ArrayFields[I].Name) <> FKey then
      begin
         campo := ArrayFields[I].Name;
         SqlFields := SqlFields + PropertyNameFormat(ArrayFields[I].Name)+',';
      end;

   end;

   FQuery.SQL.Add(copy(SqlFields,1,SqlFields.Length -1)+')');
   FQuery.SQL.Add(' VALUES (');

   for I := length(ArrayFields)-1 downto 0 do
   begin
       if PropertyNameFormat(ArrayFields[I].Name) <> FKey then
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
   end;
   FQuery.SQL.Add(copy(SqlValues,1,SqlValues.Length -1)+');');
   //coment�rio para commit

end;


{ TPaginate }

constructor TPaginate.Create(pSkip, pTake, pTotal, pCurrentPage: integer);
begin
   Skip := pSkip;
   Take := pTake;
   Total := pTotal;
   CurrentPage :=  pCurrentPage;
end;

end.
