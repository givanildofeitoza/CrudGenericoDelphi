unit Models;

interface

uses System.TypInfo;

type

{$SCOPEDENUMS ON}
EnumModel =(TProduct,TCustomer);

RecordModelEnum = record helper for EnumModel
  public
     function GetName : string;
end;

TModal = class
   AutoIncremment : boolean;
   key : string;
end;


 TCustomer = class(TModal)
  private
    FId         : integer;
    FNome       : string;
    FTelefone   : string;
    FNascimento : TDate;
    FAtivo      : Boolean;
   public
    property  Id         : integer  read  FId         write  FId;
    property  Nome       : string   read  FNome       write  FNome;
    property  Telefone   : string   read  FTelefone   write  FTelefone;
    property  Nascimento : TDate    read  FNascimento write  FNascimento;
    property  Ativo      : Boolean  read  FAtivo      write  FAtivo;
    constructor Create();
end;

type
 TProduct = class(TModal)
  private
    Fcodigo   : integer;
    FDescricao: string;
    FValor    : Currency;
    FAtivo    : Boolean;
   public
    property  Codigo    : integer  read  FCodigo     write  FCodigo;
    property  Descricao : string   read  FDescricao  write  FDescricao;
    property  Valor     : Currency read  FValor      write  FValor;
    property  Ativo     : Boolean  read  FAtivo      write  FAtivo;

    constructor Create();
end;

implementation

{ TCustomer }

constructor TCustomer.Create();
begin
    Key := 'Id';
end;


{ TProduct }

constructor TProduct.Create();
begin
    Key := 'codigo';
end;

{ RecordModelEnum }

function RecordModelEnum.GetName: string;
begin
  Result := GetEnumName(TypeInfo(EnumModel),Ord(Self));

end;

end.
