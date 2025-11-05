unit ufrmApp;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.ComCtrls;

type
  TfrmAliare = class(TForm)
    pnlSidebar: TPanel;
    pnlSidebarHeader: TPanel;
    lblLogo: TLabel;
    pnlMenuContainer: TPanel;
    btnCadastros: TButton;
    btnProdutores: TButton;
    btnDistribuidores: TButton;
    btnProdutos: TButton;
    btnLimites: TButton;
    btnNegociacoes: TButton;
    btnNovaNeg: TButton;
    btnGestaoNeg: TButton;
    btnConsultaNeg: TButton;
    btnRelatorios: TButton;
    btnRelLimites: TButton;
    btnRelNegociacoes: TButton;
    pnlMain: TPanel;
    pnlHeader: TPanel;
    lblHeaderTitle: TLabel;
    pnlContent: TPanel;
    pnlWelcome: TPanel;
    lblWelcomeTitle: TLabel;
    lblWelcomeText: TLabel;
    lblFeature1: TLabel;
    lblFeature2: TLabel;
    lblFeature3: TLabel;
    lblFeature4: TLabel;
    btnGetStarted: TButton;
    StatusBar: TStatusBar;
    procedure FormCreate(Sender: TObject);
    procedure btnAbrirProdutoresClick(Sender: TObject);
    procedure btnAbrirDistribuidoresClick(Sender: TObject);
    procedure btnAbrirProdutosClick(Sender: TObject);
    procedure btnAbrirLimitesClick(Sender: TObject);
    procedure btnAbrirNovaNegClick(Sender: TObject);
    procedure btnAbrirManutencaoClick(Sender: TObject);
    procedure btnAbrirConsultaClick(Sender: TObject);
    procedure btnRelLimitesClick(Sender: TObject);
    procedure btnRelNegociacoesClick(Sender: TObject);
    procedure btnGetStartedClick(Sender: TObject);
    procedure btnCadastrosClick(Sender: TObject);
    procedure btnNegociacoesClick(Sender: TObject);
    procedure btnRelatoriosClick(Sender: TObject);
  private
    procedure AbrirCadastroProdutores;
    procedure AbrirCadastroDistribuidores;
    procedure AbrirCadastroProdutos;
    procedure AbrirCadastroLimites;
    procedure AbrirNovaNegociacao;
    procedure AbrirManutencaoNegociacoes;
    procedure AbrirConsultaNegociacoes;
    procedure AtualizarTituloHeader(const ATitulo: string);
  public
  end;

var
  frmAliare: TfrmAliare;

implementation

uses
  ProdutorView,
  DistribuidorView,
  ProdutoView,
  LimiteCreditoView,
  LimiteCreditoRelatorioView,
  NegociacaoView,
  NegociacaoManutencaoView,
  NegociacaoConsultaView;

{$R *.dfm}

{ TfrmAliare }

procedure TfrmAliare.FormCreate(Sender: TObject);
begin
  StatusBar.SimplePanel := True;
  StatusBar.SimpleText := 'Bem-vindo ao Aliare - Sistema de Crédito e Negociações';
  AtualizarTituloHeader('Bem-vindo ao Aliare');
end;

procedure TfrmAliare.AtualizarTituloHeader(const ATitulo: string);
begin
  lblHeaderTitle.Caption := ATitulo;
end;

procedure TfrmAliare.AbrirCadastroProdutores;
begin
  if not Assigned(frmProdutorView) then
    frmProdutorView := TfrmProdutorView.Create(Self);

  frmProdutorView.Show;
  frmProdutorView.BringToFront;
  AtualizarTituloHeader('Gestão de Produtores');
end;

procedure TfrmAliare.AbrirCadastroDistribuidores;
begin
  if not Assigned(frmDistribuidorView) then
    frmDistribuidorView := TfrmDistribuidorView.Create(Self);

  frmDistribuidorView.Show;
  frmDistribuidorView.BringToFront;
  AtualizarTituloHeader('Gestão de Distribuidores');
end;

procedure TfrmAliare.AbrirCadastroProdutos;
begin
  if not Assigned(frmProdutoView) then
    frmProdutoView := TfrmProdutoView.Create(Self);

  frmProdutoView.Show;
  frmProdutoView.BringToFront;
  AtualizarTituloHeader('Gestão de Produtos');
end;

procedure TfrmAliare.AbrirCadastroLimites;
begin
  if not Assigned(frmLimiteCreditoView) then
    frmLimiteCreditoView := TfrmLimiteCreditoView.Create(Self);

  frmLimiteCreditoView.Show;
  frmLimiteCreditoView.BringToFront;
  AtualizarTituloHeader('Limites de Crédito');
end;

procedure TfrmAliare.AbrirNovaNegociacao;
begin
  if not Assigned(frmNegociacaoView) then
    frmNegociacaoView := TfrmNegociacaoView.Create(Self);

  frmNegociacaoView.Show;
  frmNegociacaoView.BringToFront;
  AtualizarTituloHeader('Nova Negociação');
end;

procedure TfrmAliare.AbrirManutencaoNegociacoes;
begin
  if not Assigned(frmNegociacaoManutencaoView) then
    frmNegociacaoManutencaoView := TfrmNegociacaoManutencaoView.Create(Self);

  frmNegociacaoManutencaoView.Show;
  frmNegociacaoManutencaoView.BringToFront;
  AtualizarTituloHeader('Gestão de Negociações');
end;

procedure TfrmAliare.AbrirConsultaNegociacoes;
begin
  if not Assigned(frmNegociacaoConsultaView) then
    frmNegociacaoConsultaView := TfrmNegociacaoConsultaView.Create(Self);

  frmNegociacaoConsultaView.Show;
  frmNegociacaoConsultaView.BringToFront;
  AtualizarTituloHeader('Consulta de Negociações');
end;

procedure TfrmAliare.btnAbrirProdutoresClick(Sender: TObject);
begin
  AbrirCadastroProdutores;
end;

procedure TfrmAliare.btnAbrirDistribuidoresClick(Sender: TObject);
begin
  AbrirCadastroDistribuidores;
end;

procedure TfrmAliare.btnAbrirProdutosClick(Sender: TObject);
begin
  AbrirCadastroProdutos;
end;

procedure TfrmAliare.btnAbrirLimitesClick(Sender: TObject);
begin
  AbrirCadastroLimites;
end;

procedure TfrmAliare.btnAbrirNovaNegClick(Sender: TObject);
begin
  AbrirNovaNegociacao;
end;

procedure TfrmAliare.btnAbrirManutencaoClick(Sender: TObject);
begin
  AbrirManutencaoNegociacoes;
end;

procedure TfrmAliare.btnAbrirConsultaClick(Sender: TObject);
begin
  AbrirConsultaNegociacoes;
end;

procedure TfrmAliare.btnRelLimitesClick(Sender: TObject);
begin
  if not Assigned(frmLimiteCreditoRelatorioView) then
    frmLimiteCreditoRelatorioView := TfrmLimiteCreditoRelatorioView.Create(Self);

  frmLimiteCreditoRelatorioView.Show;
  frmLimiteCreditoRelatorioView.BringToFront;
  AtualizarTituloHeader('Relatório - Limites por Cliente');
end;

procedure TfrmAliare.btnRelNegociacoesClick(Sender: TObject);
begin
  AbrirConsultaNegociacoes;
end;

procedure TfrmAliare.btnGetStartedClick(Sender: TObject);
begin
  AbrirNovaNegociacao;
end;

procedure TfrmAliare.btnCadastrosClick(Sender: TObject);
begin
  // Apenas para navegação visual
end;

procedure TfrmAliare.btnNegociacoesClick(Sender: TObject);
begin
  // Apenas para navegação visual
end;

procedure TfrmAliare.btnRelatoriosClick(Sender: TObject);
begin
  // Apenas para navegação visual
end;

end.
