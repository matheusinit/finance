# Finance

[![forthebadge](http://forthebadge.com/images/badges/made-with-ruby.svg)](http://forthebadge.com)
[![forthebadge](http://forthebadge.com/images/badges/built-with-love.svg)](http://forthebadge.com)

<table>
<tr>
<td>

**Finance** é uma aplicação web desenvolvida em Ruby on Rails voltada para o gerenciamento de despesas. Através dela, os usuários podem adicionar e monitorar suas despesas mensais, proporcionando uma visão clara e organizada de seus gastos ao longo do tempo. Além disso, a aplicação oferece a funcionalidade de comparar os gastos e rendimentos de diferentes meses por meio de gráficos intuitivos, permitindo uma análise mais detalhada e facilitando o planejamento financeiro pessoal.
</td>
</tr>
</table>

<div align="center">
    <img src="./.github/app.png" />
</div>

## 👨‍💻 Tecnologias

Para executar a aplicação, é necessário ter essas ferramentas instaladas no sistema:

  + [Ruby 3.3.0](https://www.ruby-lang.org/pt/)
  + [Rails 7.1.3.2](https://rubyonrails.org/)
  + [Docker >= 25.0.4](https://www.docker.com/)

Aqui estão as tecnologias de alto nível utilizadas pelo **Finance**:

  + O framework web Ruby on Rails é fundamental para o desenvolvimento da aplicação. Reconhecido por sua maturidade, o Ruby on Rails permite um desenvolvimento rápido e robusto
  + Para o armazenamento de dados, é utilizado o PostgreSQL, um banco de dados conhecido por sua segurança e pela ampla gama de recursos disponíveis, proporcionando uma base sólida e confiável para a aplicação.

* Configuração

### Instalando as dependências (do projeto)

Nessa aplicação está sendo utilizado as seguintes tecnologias:
 + Docker (>= 25.0.4)
 + Ruby (3.3.0)
 + Scala (>= 3.4.2)
 + Sbt (>= 1.10.1)

Recomendo em ler sobre a [mise](https://mise.jdx.dev/) para a instalação de `tools` 

### Instalação de dependências (do Rails)

É necessário que as dependências estejam instaladas localmente para que execute alguns comandos:

```bash
bin/bundle
```

### Configuração de Rails Key

Precisamos gerar uma chave (*key*) da aplicação em Ruby on Rails:

```bash
bin/rails credentials:edit
```

Isso permite que seja criado uma credencial para executar o aplicação. Essa chave permite descriptografar credenciais que serão utilizas na aplição, ( essas credenciais não devem ser compartilhadas). Armazene o contéudo no arquivo em `config/master.key` na variável de ambiente `RAILS_MASTER_KEY`.

### Configuração de variáveis de ambiente

Configure as variáveis de ambiente necessárias para definir credenciais da aplicação utilizando o arquivo `example.env`:

```env
POSTGRES_HOST=database
POSTGRES_PORT=5432
POSTGRES_USER=dba
POSTGRES_PASSWORD=pandaninja!.
POSTGRES_DB=finance_app_rb
RAILS_MASTER_KEY=empty
```

#### Passo 1: Configure as variáveis de ambiente para containers

Copie o conteúdo do arquivo `.env.example` para `.env.container` para definir as credenciais para ser utilizada pelos os containers

#### Passo 2: Configure as variáveis de ambiente para execução local (Opcional)

Copie o conteúdo do arquivo `.env.example` para `.env` para definir as credenciais para ser utilizada pelos os containers

### Passo 3: Criação dos serviços

Para a criação de serviços está sendo utilizado `Docker` com a versão **v27.1.1**, assim como plugins como os plugins `docker compose` e `docker buildx`.

Execute o seguinte comando para a criação dos serviços necessário para executar a aplicação:

```bash
bin/start-containers
```

Os containers serão iniciados com:
 + Banco de dados PostgreSQL
 + Duas instâncias de uma aplicação de Ruby on Rails
 + Um Load Balancer com Nginx

A partir desse passo é possível acessar a aplicação através de `http://localhost:8080`

### Passo 4: Executar aplicação localmente (sem containers)

Para rodar a aplicação de Ruby on Rails sem containers, utilize o comando:

```bash
bin/dev
```

Pronto. A aplicação estará disponível em `http://localhost:4000`

<!-- * Configuration -->
<!---->
<!-- * Database creation -->
<!---->
<!-- * Database initialization -->
<!---->
<!-- * How to run the test suite -->
<!---->
<!-- * Services (job queues, cache servers, search engines, etc.) -->
<!---->
<!-- * Deployment instructions -->
<!---->
<!-- * ... -->
