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

## Preparação

### Instalando as dependências (do projeto)

Nessa aplicação está sendo utilizado as seguintes tecnologias:
 + Docker (>= 25.0.4)
 + Ruby (3.3.0)
 + Scala (>= 3.4.2)
 + Sbt (>= 1.10.1)
 + Yarn (>= 1.22.22)

Recomendo em ler sobre a [mise](https://mise.jdx.dev/) para a instalação de `tools` 

### Instalação de dependências (do Rails)

É necessário que as dependências estejam instaladas localmente para que execute alguns comandos:

```bash
bin/bundle
```

### Compilar assets

Precisamos configurar recursos do front-end para executar a aplicação, como as dependências do front-end, imagens, fontes, e é esses mesmos arquivos são comprimidos e otimizados para o ambiente de produção. Para executar:

```bash
bin/rails assets:precompile
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

## Execução da aplicação

### Passo 1:  Configure as variáveis de ambiente

 - Usando containers

Copie o conteúdo do arquivo `.env.example` para `.env.container` para definir as credenciais para ser utilizada pelos os containers

 - Usando execução local (localhost)

Copie o conteúdo do arquivo `.env.example` para `.env` para definir as credenciais para ser utilizada pelos os containers

> Use `0.0.0.0` para a variável `POSTGRES_HOST`

### Passo 2: Criação dos serviços

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

### Passo 3: Executar aplicação localmente (sem containers)

Para rodar a aplicação de Ruby on Rails sem containers, utilize o comando:

```bash
bin/dev
```

Pronto. A aplicação estará disponível em `http://localhost:4000`

## Testes de carga

Foi configurado um conjunto de testes de cargas usando Gatling para especionar o comportamento e performance da aplicação em condições de estresse.

### Passo 1 - Instalar dependências para o teste de carga

Como citado anteriormente, é utilizado *Scala*, *Sbt* e *Go* nesse projeto, eles são utilizados para executar os testes de carga.

Eu instalo essas ferramentas utilizando *mise*. Verifique a [documentação](https://mise.jdx.dev/getting-started.html) para saber mais.

### Passo 2 - Executar testes de carga

Para executar, confirme se todos os containers estão rodando. Se não estiver, execute:

```bash
bin/start-containers
```

Em seguida, execute os testes de carga com o seguinte comando:

```bash
bin/load-test
```

Pronto! O teste de carga se iniciará com os resultados sendo escrito em arquivo `.html` em `/test/load/gatling/target/gatling-it/`

## Implantação em nuvem

Para a preparação e configuração de um ambiente em nuvem, foi utilizado **Terraform** como ferramenta de *Infrastructure as Code* para versionamento e declaração da arquitetura de implantação. Para o projeto está sendo utilizado Terraform na versão 1.9.4.

Para ambiente de nuvem, foi escolhido a *Amazon Web Services* (AWS) devido a sua popularidade e adoção no mercado, assim como, a minha familiaridade com as soluções AWS.

Para implantar a aplicação na AWS, é necessário credenciais de uma conta AWS (pode ser uma *Free Tier*, como foi atualizada por mim) e a instalação da ferramenta **aws-cli**.

### Preparação da AWS

É necessário configurar as **Access keys** usando a conta AWS que será utilizada. Para obter as Access keys, acesse a seguinte [documentação da AWS](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html).

Com as credenciais obtidas, precisamos somente informar-las e definir o nome para o perfil.

```bash
aws configure --profile myprofile

AWS Access Key ID [None]: [...]
AWS Secret Access Key [None]: [...]
Default region name [None]: us-east-1
Default output format [None]: yaml
```

> Obs.: Garanta que aws-cli está instalada

Para definir o perfil a ser utilizado, define a variável de ambiente:

```bash
export AWS_PROFILE=myprofile
```

> Mude o `myprofile` por o nome do perfil escolhido, use um nome descritivo

### Inicializar a infrastrutura na AWS

Precisamos configurar o gerenciamento de dependências do Terraform antes da aplicação ser implantada. Isso é feito com o seguinte comando:

```bash
terraform init
```

Com isso todas as dependências necessárias estarão instaladas

> Obs.: Garanta que o Terraform esteja instalado

#### Aplicar a configuração na AWS

Precisamos agora aplicar a configuração de infrastructura na AWS com o seguinte comando:

```bash
terraform apply
```

Uma descrição do que será criado vai aparecer, pedindo confirmarção da ação. Se quiser aplicar a configuração sem necessidade de confirmação, execute:

#### Aplicar a configuração na AWS (sem confirmação)

```bash
terraform apply --auto-approve
```

### Destruir a infrastrutura

Para que todos os recuros na AWS sejam deletados, basta executar:

```bash
terraform destroy --auto-approve
```

> Obs.: O `--auto-approve` foi especificado para não pedir a confirmação, mas caso precise de confirmação não especifique

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
