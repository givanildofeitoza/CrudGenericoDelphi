unit repositorio;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, DbxDevartMySql, Data.DB, Data.SqlExpr,
  Vcl.StdCtrls, Vcl.Buttons, URepositoy, UORM;

type
 TCustomer = class(TModal)
  private
    Id   : integer;
    Nome     : string;
    Telefone : string;
    Nascimento : TDate;
    Ativo      : boolean;
   public
    property  PId         : integer  read  Id         write  Id;
    property  PNome       : string   read  Nome       write  Nome;
    property  PTelefone   : string   read  Telefone   write  Telefone;
    property  PNascimento : TDate    read  Nascimento write Nascimento;
    property  PAtivo      : boolean  read  Ativo      write Ativo;
    constructor Create();
end;

type
 TProduct = class(TModal)
  private
    codigo   : integer;
    Descricao:  string;
    Valor    : Currency;
    Ativo    : boolean;
   public
    property  PCodigo    : integer  read  Codigo     write  Codigo;
    property  PDescricao : string   read  Descricao  write  Descricao;
    property  PValor: Currency      read  Valor      write Valor;
    property  PAtivo: boolean       read  Ativo      write Ativo;

    constructor Create();
end;

 TForm1 = class(TForm)
    Connection: TSQLConnection;
    BitBtn1: TBitBtn;
    procedure BitBtn1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;


var
  Form1: TForm1;
  valor : string ='0';

implementation

{$R *.dfm}

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

procedure TForm1.BitBtn1Click(Sender: TObject);
var
  ORM: TORM;
  Customer : TCustomer;
  Product  : TProduct;
begin
   //CREATE OBJECT COSTUMER
   Customer          := TCustomer.Create();
   Customer.Id       := 10;
   Customer.Nome     := 'John Snow';
   Customer.Telefone := '87 99188-9853';
   Customer.Nascimento := Now;
   Customer.Ativo := True;

   //CREATE OBJECT PRODUCT
   Product  := TProduct.Create();
   Product.codigo := 5;
   Product.Descricao:='notebook Dell core I7';
   Product.Valor := 5500.00;

   //ACTIONS'S  CRUD GENERIC PRODUCT
   ORM := TORM.Create(Connection);
   ORM.Add(Product);
   ORM.SaveChange(Product);
   ORM.Remove(Product);

   //ACTIONS'S  CRUD GENERIC CUSTOMER
   ORM.Add(Customer);
   ORM.SaveChange(Customer);
   ORM.Remove(Customer);
end;

end.
