
## 🚀 Características Principais

✅ **Validação Automática de Crédito** - O sistema bloqueia negociações que extrapolam o limite de crédito, considerando negociações já aprovadas

✅ **Banco de Dados Automático** - Não precisa criar banco na mão! O sistema cria tudo na primeira execução

✅ **Migrations Automáticas** - Todas as tabelas e índices são criados automaticamente quando você inicia o sistema

✅ **Interface Moderna** - Menu lateral interativo, dashboard informativo e navegação intuitiva

✅ **Testes Unitários** - Suite completa de testes para validar a lógica de crédito

## 🔧 Configuração Inicial

### 1. Arquivo `config.ini`

O arquivo `bin/config.ini` define onde o banco de dados vai ficar e como conectar:

```ini
[Database]
Server=localhost
Port=3050
DatabaseName=D:\projects\desafio_delphi_03\data\aliaredb.fdb
Username=SYSDBA
Password=masterkey
Charset=UTF8

[Application]
Title=Sistema Aliare
Version=1.0.0
```

**Importante**: Você pode mudar o caminho `DatabaseName` para qualquer lugar que preferir. Na primeira execução, o sistema vai:
1. Verificar se o arquivo existe
2. Se não existir, **cria o diretório automaticamente**
3. **Cria o banco de dados vazio** via Firebird
4. **Executa todas as migrations** (tabelas, índices, constraints)

### 2. Primeiro Acesso

Quando você abre o Aliare pela primeira vez:
- O sistema detecta que não tem banco
- Cria o diretório `data/` 
- Cria o arquivo `aliaredb.fdb` (banco vazio)
- Rodas as migrations automáticas
- E pronto! Tá tudo pronto pra usar

Não precisa ficar rodando scripts SQL na mão! 🎉

## 🧪 Como Rodar os Testes

O Aliare tem testes unitários completos para validar a lógica de crédito. Aqui tá como rodar:

### Pré-requisitos
- DUnitX instalado no seu Delphi
- Compilador Delphi (version 10.3+)

### Rodando os Testes

**Opção 1: Via IDE do Delphi**
```
1. Abra o projeto tests/TestAliare.dproj
2. Menu: Project → Build (ou F9)
3. Clique em Run para executar
```

**Opção 2: Via Batch**
```powershell
cd d:\projects\desafio_delphi_03\tests
.\RunTests.bat              # Resultado em console
# ou
.\RunTestsXML.bat           # Resultado em XML (arquivo dunitx-results.xml)
```

### O que os Testes Validam

Os testes em `TestNegociacaoController.pas` cobrem:

✅ **Negociação SEM aprovadas** - Consegue criar uma negociação normalmente quando não tem aprovadas anteriores

✅ **Negociação COM aprovadas** - O sistema calcula corretamente o total de aprovadas e bloqueia se ultrapassar o limite

✅ **Limite exato** - Testa quando a negociação usa exatamente o limite restante

✅ **Bloqueio de limite** - Valida que o sistema bloqueia quando ultrapassa

**Exemplo prático:**
- Produtor: João Silva
- Distribuidor: Distribuidora XYZ
- Limite: R$ 60.000,00
- Negociação Aprovada: R$ 20.000,00 (ja está no sistema)
- Tenta criar nova: R$ 50.000,00 → **BLOQUEADO** (20 + 50 = 70 > 60)

## 🗄️ Banco de Dados - Como Funciona

### Criação Automática

O arquivo `DatabaseMigrator.pas` define todas as migrations. Cada migração é um "passo" de criação:

1. **001_CREATE_PRODUTOR** - Tabela de produtores
2. **002_CREATE_DISTRIBUIDOR** - Tabela de distribuidores
3. **003_CREATE_PRODUTO** - Tabela de produtos
4. **004_CREATE_LIMITE_CREDITO** - Tabela de limites (chave: Produtor + Distribuidor)
5. **005_CREATE_NEGOCIACAO** - Tabela de negociações
6. **006_CREATE_NEGOC_ITEM** - Itens da negociação

### Scripts Automáticos

Toda vez que você inicia o sistema:
1. Verifica se a tabela `SCRIPTS` existe (controla quais migrations já rodaram)
2. Roda apenas as migrations que ainda não foram executadas
3. Registra na tabela `SCRIPTS` que foram rodadas
4. **Nunca** roda de novo a mesma migration

Isso significa que você pode dar update no sistema, adicionar novas migrations, e elas rodam automaticamente! 🔄

## 🎮 Usando o Sistema

### Tela Principal
- Menu lateral com 3 seções: Cadastros, Negociações, Relatórios
- Dashboard informativo no meio
- Navegação intuitiva

### Fluxo Típico

1. **Cadastre Produtores** (Cadastros → Produtores)
2. **Cadastre Distribuidores** (Cadastros → Distribuidores)
3. **Cadastre Produtos** (Cadastros → Produtos)
4. **Defina Limites de Crédito** (Cadastros → Limites de Crédito)
5. **Crie Negociações** (Negociações → Nova Negociação)
   - Sistema bloqueia automaticamente se ultrapassar limite (considerando aprovadas!)
6. **Aprove Negociações** (Negociações → Gestão de Negociações)
7. **Consulte Relatórios** (Relatórios → ...)

## 🔐 Validação de Crédito - O Algoritmo

Quando você tenta criar uma negociação:

```
1. Busca o limite de crédito (Produtor + Distribuidor)
2. Calcula o TOTAL DE APROVADAS anteriores (apenas APROVADA!)
3. Calcula: Total Aprovado + Nova Negociação = Total Projetado
4. Se Total Projetado > Limite → BLOQUEIA com mensagem clara
5. Se OK → SALVA a negociação como PENDENTE
```

**Exemplo:**
- Limite: R$ 100.000
- Aprovadas: R$ 60.000
- Tenta: R$ 50.000
- Cálculo: 60.000 + 50.000 = 110.000 > 100.000
- **Resultado: BLOQUEADO!** ❌

## 📊 Relatórios

O sistema gera relatórios em **FastReport** (arquivo `.fr3`):

- **Limites por Cliente** - Mostra limite e total aprovado por cliente
- **Negociações Aprovadas** - Lista todas as negociações aprovadas

## 🛠️ Desenvolvimento

### Estrutura de Código

**Controllers** - Lógica de negócio
```objectpascal
TNegociacaoController = class
  function Salvar(ANegociacao: TNegociacaoEntity): TNegociacaoEntity;
  // Aqui acontece a validação de crédito!
end;
```

**Views** - Interface com usuário (VCL)
```objectpascal
TfrmNegociacaoView = class(TForm)
  // Tela de entrada de dados
end;
```

**Repositories** - Acesso a dados (FireDAC + Firebird)
```objectpascal
TNegociacaoRepository = class
  function ObterTotalAprovado(...): Currency;
  // Query que filtra APENAS negociações com status = 'APROVADA'
end;
```

**Entities** - Objetos de domínio
```objectpascal
TNegociacaoEntity = class
  ProdutorId: string;
  DistribuidorId: string;
  ValorTotal: Currency;
  Status: string; // 'PENDENTE', 'APROVADA', 'CONCLUIDA', 'CANCELADA'
end;
```

## 📝 Documentação Extra

Confira os docs completos em `docs/`:

- `VALIDACAO_CREDITO_NEGOCIACOES_APROVADAS.md` - Explicação detalhada da validação
- `EXEMPLO_VALIDACAO_PASO_A_PASO.md` - Exemplos passo a passo
- `TESTES_VALIDACAO_CREDITO.md` - Detalhes dos testes unitários
- `CLASSES_UTILITARIAS.md` - Classe de utilidades
- `RELATORIO_CENTRALIZACAO.md` - Análise de arquitetura
- `GUIA_REFATORACAO.md` - Guia de refatoração

## 🐛 Troubleshooting

### "Arquivo não encontrado aliaredb.fdb"
- Confirme que o caminho em `config.ini` está correto
- O sistema vai criar automaticamente na primeira execução
- Certifique-se que o diretório tem permissão de escrita

### "Erro ao conectar ao banco"
- Verifique credenciais em `config.ini` (padrão: SYSDBA / masterkey)
- Firebird precisa estar instalado (fbclient.dll)
- Veja se o arquivo `bin/fbclient.dll` existe

### Testes falhando
- Certifique-se que DUnitX está instalado
- Execute `RunTests.bat` no PowerShell (admin)
- Veja o arquivo `tests/dunitx-results.xml` para detalhes

## 🎯 Próximos Passos

Ideias para melhorias futuras:
- [ ] Integração com sistema de pagamentos
- [ ] Dashboard com gráficos de negociações
- [ ] Exportação de dados em Excel
- [ ] Suporte a múltiplas moedas
- [ ] API REST para integração
- [ ] App mobile para consultas

