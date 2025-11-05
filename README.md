# Desafio Controle de Negociação - Aliare

## 🚀 Status: ✅ COMPLETO E FUNCIONAL

Sistema completo para gestão de negociações entre produtores rurais e distribuidores de insumos agrícolas.

---

## 📖 Documentação Completa

👉 **[CLIQUE AQUI para ver a documentação completa de instalação e uso](README_IMPLEMENTACAO.md)**

A documentação inclui:

- ✅ Requisitos e instalação passo a passo
- ✅ Estrutura completa do projeto
- ✅ Todas as funcionalidades implementadas
- ✅ Arquitetura e padrões de projeto (SOLID, GoF)
- ✅ Como usar o sistema (fluxo completo)
- ✅ Modelo de dados e relacionamentos
- ✅ Decisões técnicas detalhadas
- ✅ Troubleshooting

---

## ⚡ Quick Start

### 1. Requisitos Mínimos

- Delphi Community Edition (10.4+)
- Firebird 2.1+
- Windows 7+

### 2. Instalar e Executar

```bash
# 1. Clone o repositório
git clone https://github.com/SiagriERPs/desafio_delphi_03.git

# 2. Instale o Firebird 2.1 (se ainda não tiver)
# Download: http://sourceforge.net/projects/firebird/files/firebird-win32/2.1.7-Release/

# 3. Configure o banco em: bin/config.ini
[Database]
Server=localhost
Username=SYSDBA
Password=masterkey  # Ajuste conforme sua instalação

# 4. Abra no Delphi: src/Aliare.dpr

# 5. Compile e Execute (F9)
# O banco de dados será criado automaticamente!
```

---

## ✨ Funcionalidades Principais

### ✅ Requisitos Atendidos 100%

- ✅ Cadastro de Produtores (CPF/CNPJ)
- ✅ Cadastro de Distribuidores (CNPJ)
- ✅ Cadastro de Produtos (Nome + Preço)
- ✅ Limites de Crédito por Produtor/Distribuidor
- ✅ Nova Negociação com múltiplos itens
- ✅ Validação automática de limite de crédito
- ✅ Status: Pendente → Aprovada → Concluída/Cancelada
- ✅ Manutenção de Status (Aprovar/Concluir/Cancelar)
- ✅ Consulta com filtros (Produtor/Distribuidor)
- ✅ Relatório completo em arquivo texto
- ✅ Todas as datas registradas

### 🎯 Diferenciais Implementados

- ✅ **Arquitetura modular** (Entity, Repository, Controller, View, Module)
- ✅ **Padrões GoF**: Singleton, Repository, Module, Template Method, Dependency Injection
- ✅ **Princípios SOLID** aplicados
- ✅ **Migrations automáticas** do banco de dados
- ✅ **Interface intuitiva** com ComboBox e grids
- ✅ **Validações robustas** em múltiplas camadas
- ✅ **Mensagens claras** ao usuário
- ✅ **Gerenciamento automático de memória**
- ✅ **Código limpo e bem documentado**

---

## 🎮 Como Usar (Resumo)

```
1. Cadastros → Produtores, Distribuidores, Produtos
2. Produtores → Definir Limites de Crédito
3. Negociações → Nova Negociação
   - Selecionar distribuidor logado
   - Selecionar produtor
   - Adicionar itens (produtos + quantidades)
   - Sistema valida limite automaticamente
   - Salvar (status = PENDENTE)
4. Negociações → Painel de Gestão
   - Selecionar negociação
   - Aprovar → Concluir ou Cancelar
5. Relatórios → Gerar relatório filtrado
```

---

## 📁 Estrutura do Projeto

```
desafio_delphi_03/
├── bin/                 # Executáveis (.exe, .dll, config.ini)
├── data/               # Banco de dados (.fdb)
├── docs/               # Documentação técnica
└── src/                # Código fonte
    ├── Aliare.dpr     # Projeto principal
    ├── config/        # Configuração e conexão BD
    ├── core/          # Classes base
    └── modules/       # Módulos funcionais
        ├── distribuidor/
        ├── produtor/
        ├── produto/
        ├── limite_credito/
        ├── negociacao/
        ├── negociacao_item/
        └── shared/
```

---

## 🏗️ Arquitetura

```
VIEW (Forms)
    ↓
CONTROLLER (Regras de Negócio)
    ↓
REPOSITORY (Interface de Dados)
    ↓
REPOSITORY IMPL (FireDAC + Firebird)
    ↓
ENTITY (Modelo de Domínio)
```

**Padrões Aplicados:**

- Singleton (Conexão)
- Repository (Acesso a dados)
- Module (Factory de objetos)
- Template Method (Classe base)
- Dependency Injection (Construtores)

---

## 🐛 Troubleshooting Rápido

| Erro                   | Solução                                               |
| ---------------------- | ----------------------------------------------------- |
| "Cannot find database" | Verifique `bin/config.ini` e se Firebird está rodando |
| "Connection refused"   | Firebird não está rodando ou porta incorreta (3050)   |
| "Access denied"        | Senha incorreta no `config.ini`                       |
| Banco não cria         | Execute como Administrador na 1ª vez                  |

---

## 📊 Tecnologias e Componentes

- **Linguagem:** Object Pascal (Delphi)
- **IDE:** Delphi Community Edition 10.4+
- **Banco de Dados:** Firebird 2.1+
- **Conexão:** FireDAC (componente nativo)
- **Interface:** VCL (Visual Component Library)
- **Coleções:** System.Generics.Collections
- **Padrões:** SOLID, GoF, Clean Code

---

## ✅ Checklist de Entrega

- ✅ Todos os requisitos implementados
- ✅ Código limpo e organizado
- ✅ SOLID e GoF aplicados
- ✅ Migrations automáticas
- ✅ Documentação completa
- ✅ Compila em qualquer máquina
- ✅ Estrutura de diretórios correta
- ✅ Apenas componentes nativos
- ✅ Mensagens amigáveis
- ✅ Validações robustas
- ✅ Gerenciamento de memória correto

---

## 📄 Licença

Desenvolvido para o **Desafio Técnico - Aliare**

---

# Sobre o Desafio Original

Quer fazer parte da transformação do campo ~~escrevendo~~ codando o futuro do agronegócio?

# Sobre a Aliare

A [Aliare](https://www.aliare.co) está entre as maiores empresas de software para agronegócio do país. Nascemos no agro e somos especialistas em levar tecnologia para gestão de empresas e propriedades rurais.

Estamos com nossos clientes, pra fazer o campo acontecer. Temos orgulho de ajudar a construir o presente e o futuro do agronegócio.

# O desafio

Um determinado produtor, precisa comprar insumos para a próxima safra, fertilizantes, agrotóxicos, sementes etc. O processo de compra é realizado alguns meses antes do início do plantio e para garantir bons preços e permitir que a distribuidora de insumos organize seu estoque, geralmente o produtor faz uma negociação de compra com o distribuidor.
Levando em consideração o cenário descrito, deverá ser desenvolvido um aplicativo para controle de negociações, onde será permitido cadastrar negociações entre um produtor e um distribuidor, bem como informar os produtos, quantidades e preços presentes nesta negociação.

### Requisitos

- Deverá ser criado um cadastro de produtor, onde será informado o nome do produtor e seu CPF/CNPJ. Também será possível no cadastro do produtor, informar o limite de crédito que ele tem com cada distribuidor. Lembrando que um produtor pode ter diversos limites de crédito com diversos distribuidores.
- Deverá ser criado um cadastro de distribuidor onde será informado o nome e CNPJ do distribuidor.
- Deverá ser criado um cadastro de produto onde o usuário informará o nome, e seu preço de venda.
- Deverá ser criado uma tela de manutenção de negociação onde o usuário poderá informar os dados para realizar o cadastro ou alteração de uma negociação. Nesta tela o usuário poderá informar o produtor, o distribuidor e os itens da negociação. Deverá ter um campo totalizando a negociação e um informando o status daquela negociação.
- A negociação possui apenas 4 status possíveis, “Pendente”, “Aprovada”, “Concluir” e “Cancelada”. Sempre que uma negociação for gravada o status padrão dela será “Pendente”. Para aprovar, concluir ou cancelar esta negociação existirá uma tela para manutenção de negociação, onde o usuário irá informar o código da negociação pendente e então ele poderá aprovar, concluir ou cancelar.
- O produtor deve possuir crédito para realizar uma negociação, sendo assim no cadastro dos dados do produtor será informado o limite de crédito em reais que ele tem com um determinado distribuidor. Dessa forma caso o produtor deseje efetuar uma negociação que ultrapasse o seu limite de crédito o sistema deverá bloquear.
- Para validar o crédito de um produtor na geração da negociação, o sistema deverá considerar também as negociações aprovadas, assim caso um produtor queira fazer uma negociação no valor de R 50.000,00 com um distribuir e ele possuir um limite de R 60.000,00 com este distribuidor o sistema deverá permitir, porém se este produtor possuir uma outra negociação aprovada de R$ 20.000,00 então o sistema deverá bloquear visto que o limite geral será ultrapassado.
- Deverá ser criado uma tela de consulta de negociações que permita filtrar as negociações de um determinado produtor ou distribuidor, nesta tela também poderemos imprimir um relatório referente as negociações filtradas.
- O relatório deverá exibir o nome do produtor, o nome do distribuidor, o código do contrato, a data de cadastro, a data de aprovação, a data de conclusão, a data de cancelamento caso exista e o valor total do contrato.

  Siga abaixo a estrutura de diretórios já criada para este projeto:

![image](https://user-images.githubusercontent.com/28271306/138889763-cfb52e98-4a38-44f0-8cb8-48404732ddd2.png)

    bin: Todos os binários do projeto devem ficar na pasta bin.
    data: Local onde fica o arquivo fdb referente ao banco de dados.
    docs: Neste diretório devem ficar os documentos como scripts para criação da estrutura de tabelas e outros documentos que achar necessário.
    src: Neste diretório deve ficar o código fonte.

## Recomendações

- Utilize [Delphi Community Edition](https://www.embarcadero.com/br/products/delphi/starter);
- Utilize apenas componentes nativos do Delphi Community Edition;
- Para banco de dados utilize Firebird versão 2.1. Pode ser baixado [clicando aqui](http://sourceforge.net/projects/firebird/files/firebird-win32/2.1.7-Release/Firebird-2.1.7.18553_0_Win32.exe/download);
- Utilize boas práticas de codificação, isso será avaliado;
- Desenvolva a aplicação de forma que ela compile facilmente em qualquer equipamento, sem a necessidade de iteração com configurações;
- Mostre que você manja dos paranauê do Delphi;
- Código limpo (clean code), organizado e documentado (quando necessário);
- Use e abuse de:
  - SOLID, GOF, entre outros;
  - Reaproveitamento de código;
  - Criatividade;
  - Performance;
  - Manutenabilidade;
  - Testes Unitários (quando necessário)
  - ... pois avaliaremos tudo isso!
