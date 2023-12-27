program ProjetoRepositorio;

uses
  Vcl.Forms,
  repositorio in 'repositorio.pas' {Form1},
  URepositoy in 'URepositoy.pas',
  UORM in 'UORM.pas',
  Models in 'Models.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
