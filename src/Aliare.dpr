program Aliare;

uses
  Vcl.Forms,
  FireDAC.Phys,
  FireDAC.Phys.IBBase,
  FireDAC.Phys.FB,
  ufrmApp in 'ufrmApp.pas' {Form1},
  GsBaseEntity in 'core\GsBaseEntity.pas',
  AppConfig in 'config\AppConfig.pas',
  DatabaseMigrator in 'config\DatabaseMigrator.pas',
  ConnectionDataBase in 'config\ConnectionDataBase.pas' {dmConnection: TDataModule},
  GsValidation in 'modules\shared\utils\GsValidation.pas',
  ProdutorController in 'modules\produtor\controller\ProdutorController.pas',
  ProdutorEntity in 'modules\produtor\entities\ProdutorEntity.pas',
  ProdutorRepository.FB in 'modules\produtor\repository\ProdutorRepository.FB.pas',
  ProdutorRepository.Intf in 'modules\produtor\repository\ProdutorRepository.Intf.pas',
  ProdutorView in 'modules\produtor\view\ProdutorView.pas' {frmProdutorView},
  ProdutorModule in 'modules\produtor\ProdutorModule.pas',
  DistribuidorController in 'modules\distribuidor\controller\DistribuidorController.pas',
  DistribuidorEntity in 'modules\distribuidor\entities\DistribuidorEntity.pas',
  DistribuidorRepository.FB in 'modules\distribuidor\repository\DistribuidorRepository.FB.pas',
  DistribuidorRepository.Intf in 'modules\distribuidor\repository\DistribuidorRepository.Intf.pas',
  DistribuidorModule in 'modules\distribuidor\DistribuidorModule.pas',
  DistribuidorView in 'modules\distribuidor\view\DistribuidorView.pas' {frmDistribuidorView},
  ProdutoController in 'modules\produto\controller\ProdutoController.pas',
  ProdutoEntity in 'modules\produto\entities\ProdutoEntity.pas',
  ProdutoRepository.FB in 'modules\produto\repository\ProdutoRepository.FB.pas',
  ProdutoRepository.Intf in 'modules\produto\repository\ProdutoRepository.Intf.pas',
  ProdutoModule in 'modules\produto\ProdutoModule.pas',
  ProdutoView in 'modules\produto\view\ProdutoView.pas' {frmProdutoView},
  LimiteCreditoController in 'modules\limite_credito\controller\LimiteCreditoController.pas',
  LimiteCreditoEntity in 'modules\limite_credito\entities\LimiteCreditoEntity.pas',
  LimiteCreditoRepository.FB in 'modules\limite_credito\repository\LimiteCreditoRepository.FB.pas',
  LimiteCreditoRepository.Intf in 'modules\limite_credito\repository\LimiteCreditoRepository.Intf.pas',
  LimiteCreditoModule in 'modules\limite_credito\LimiteCreditoModule.pas',
  NegociacaoController in 'modules\negociacao\controller\NegociacaoController.pas',
  NegociacaoEntity in 'modules\negociacao\entities\NegociacaoEntity.pas',
  NegociacaoRepository.FB in 'modules\negociacao\repository\NegociacaoRepository.FB.pas',
  NegociacaoRepository.Intf in 'modules\negociacao\repository\NegociacaoRepository.Intf.pas',
  NegociacaoModule in 'modules\negociacao\NegociacaoModule.pas',
  NegociacaoView in 'modules\negociacao\view\NegociacaoView.pas' {frmNegociacaoView},
  NegociacaoManutencaoView in 'modules\negociacao\view\NegociacaoManutencaoView.pas' {frmNegociacaoManutencaoView},
  NegociacaoConsultaView in 'modules\negociacao\view\NegociacaoConsultaView.pas' {frmNegociacaoConsultaView},
  NegociacaoItemController in 'modules\negociacao_item\controller\NegociacaoItemController.pas',
  NegociacaoItemEntity in 'modules\negociacao_item\entities\NegociacaoItemEntity.pas',
  NegociacaoItemRepository.FB in 'modules\negociacao_item\repository\NegociacaoItemRepository.FB.pas',
  NegociacaoItemRepository.Intf in 'modules\negociacao_item\repository\NegociacaoItemRepository.Intf.pas',
  NegociacaoItemModule in 'modules\negociacao_item\NegociacaoItemModule.pas',
  LimiteCreditoView in 'modules\limite_credito\view\LimiteCreditoView.pas' {frmLimiteCreditoView},
  LimiteCreditoRelatorioView in 'modules\limite_credito\view\LimiteCreditoRelatorioView.pas' {frmLimiteCreditoRelatorioView};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TdmConnection, dmConnection);
  Application.CreateForm(TfrmAliare, frmAliare);
  Application.Run;
end.
