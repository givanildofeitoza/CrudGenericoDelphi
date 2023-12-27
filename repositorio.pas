unit repositorio;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, DbxDevartMySql, Data.DB, Data.SqlExpr,
  Vcl.StdCtrls, Vcl.Buttons, URepositoy, UORM, Models;



type TForm1 = class(TForm)
    Connection: TSQLConnection;
    BitBtn1: TBitBtn;
    btn1: TBitBtn;
    procedure BitBtn1Click(Sender: TObject);
    procedure btn1Click(Sender: TObject);
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



procedure TForm1.BitBtn1Click(Sender: TObject);
var
  ORM: TORM;
  Customer : TCustomer;
  Product  : TProduct;
begin
   //CREATE OBJECT COSTUMER
   Customer          := TCustomer.Create();
   Customer.Id       := 10;
   Customer.Nome     := 'D. Jos� I';
   Customer.Telefone := '87 99188-9853';
   Customer.Nascimento := Now;
   Customer.Ativo := True;

   //CREATE OBJECT PRODUCT
   Product  := TProduct.Create();
   Product.codigo := 4;
   Product.Ativo := True;
   Product.Descricao:='notebook Dell core I3';
   Product.Valor := 5500.00;

   //ACTIONS'S  CRUD GENERIC PRODUCT
   ORM := TORM.Create(Connection);
  // ORM.Add(Product);
   //ORM.Update(Product);
  // ORM.Remove(Product);

   //ACTIONS'S  CRUD GENERIC CUSTOMER
  // ORM.Add(Customer);
  // ORM.Update(Customer);
  // ORM.Remove(Customer);

   ORM.SaveChange;
end;

procedure TForm1.btn1Click(Sender: TObject);
var
  ORM: TORM;
  Customer : TCustomer;
begin
      Customer          := TCustomer.Create();
      ORM := TORM.Create(Connection);
     // ORM.GetAll<TProduct>(TPaginate.Create(0,10,1,1));
      ORM.GetById<TCustomer>(2);
end;

end.
