# Design de Banco de Dados

Banco de dados em vários arquivos. Aumenta a eficiência

- Definição clássica: Um banco de dados é uma coleção de tabelas estruturadas que armazena um conjunto de dados....

- O que interessa para esse treinamento: Os dados as aplicações ficam armazenadas em arquivos em disco.

- Cada banco de dados no SQL Server tem no minimo dois arquivos. Um arquivo de dados conhecido com arquivo Primário e tem a
  extensão MDF e outro arquivo de log com a extensão LDF para registrar os logs da transação (vamos tratar somente de
  arquivo de dados nesse treinamento).


- Cada arquivo tem um FILE ID que é o número de identificação do arquivo. Importante.
- A coluna DATA_SPACE_ID é a identificação desse arquivo dentro de um grupo de arquivo.
- A coluna Name é o nome lógico do arquivo
- A coluna SIZE é o tamanho alocado do arquivo em páginas de dados
- A coluna GROWTH é a taxa de crescimento do arquivo em Bytes

- No arquivo Primário ou MDF além de termos os dados da aplicação, temos também as informações sobre:

   - Inicialização de banco de dados;
   - A referência para outros arquivos de dados do banco;
   - Metadados de todos os objetos de banco de dados criados pelos desenvolvedores.
 
Todo e qualquer comando que tenha alguma referência a objetos como tabela, colunas, views, etc.,
sempre consulta os metadados desses objetos no arquivo primário.

Um simples SELECT Coluna FROM Tabela, faz com que o SQL Server consulte nos metadados se a COLUNA existe e se a 
TABELA existe tambem.

- Existe um outro tipo de arquivo que podemos (e devemos) associar ao banco de dados que é conhecido como
  Secundário de dados. Ele tem a extensão NDF.

  Cada arquivo de dados deve possuir algumas caracteristicas como:

   - Será agrupado junto com outros arquivos de dados em um grupo lógico chamado de FILEGROUP (FG). Se
     não especificado o FG, o arquivo fica no grupo de arquivos PRIMARY.

   - Deve ter um nome lógico que será utilizado em instruções T-SQL;
 
   - Deve ter um nome físico onde consta o local o arquivo no sistema operacional;
 
   - Deve ter um tamanho inicial para atender a carga de dados atual e uma previsão futura;
 
   - Deve ter uma taxa de crescimento definida. Ela será utilizada para aumentar o tamanho do arquivo
     de dados quando o mesmo estiver cheio;

   - Deve ter um limite máximo de crescimento. Isso é importante para evitar que arquivos crescem e ocupem
     todo o espaço em disco.

- FILEGROUP é um agrupamento lógico de arquivos de dados para distribuir melhor a alocação de dados entre discos, agrupar dados
  de acordo com contextos ou arquivamentos como também permitir ao DBA uma melhor forma de administração.

  No nosso caso, vamos focar em melhorar o desempenho das consultas.

👇  Consulte todas as queries utilizadas

<div> 
<p><a href="https://github.com/JosiTubaroski/Design-de-Banco-de-Dados/blob/main/03%20-%20Design%20da%20Banco%20de%20Dados.sql"> Design da Banco de Dados.sql </a></p>
</div> 

# Armazenamento e tipos de dados.

Tipos de Dados no SQL Server;

Quando criamos uma tabela, temos que definir as colunas onde os dados ficarão armazenados.

Essas colunas devem ser definidas com um conjunto de caracteristicas que permite armazenar o dado correto, com o tamanho ideal e com as regras de restrições.

Vamos focar nos tipos de dados, o seu domínio e principalmente quantos bytes serão armazenados.

No final dessa aula, voce será capaz de identificar corretamente o tamanho que será utilizado em cada coluna com o objetivo de armazenar o maior numero possivel 
de caracteres em uma pagina de dados.

Para esse treinamento, vamos agrupar os tipos de dados em tamanho fixo e tamnho variavel considerando o aspecto de armazenagem física dos dados.

FIXO

São os tipos de dados que armazenam o tamanho que foi declarado ou definido para o tipo de dado, sem aumentar ou diminuir o número de bytes
de acordo com o dado inserido.

Abaixo a relação dos tipos, domínios e dicas de onde utilizar.

Exemplo:

INT     - Tipo de dados número exato, ele armazena sempre 4 bytes para representar numero inteiro entre -2.147.483.648 até 2.147.833.647.
          Muito utilizada para a chave primária, permite identificar uma tabela com mais de 2 bilhoes de linhas (2.147.483.647 linhas)

     
SMALLINT - Dados de número exato, ele armazena sempre 2 bytes para representar números inteiros entre -32.768 até 32.767
           Utilize para identificar linhas em tabelas que voce tenha certeza não ultrapassar 30.000 linhas. Ou utilizado para
           armazenar e pequenas quantidade.

TINYINT - Tipo de dado de numero exato, armazena 1 byte para representar números inteiros positivos entre 0 e 255.

BIGINT  - Tipo de dados de número exato, armazena 8 bytes para representar números entre -9.223.372.036.854.775.808 até 9.223.372.036.854.775.807. 

CHAR(n) - Tipo de dado caracter que aceita 'n' bytes. O total de bytes declarado no tipo do dados será o mesmo para o armazenamento,
          independente da quantidade de caracteres associado.
          Em char (10), por exemplo, mesmo que você inclua a palavra 'Jose' (4 Bytes) o SQL grava 10 bytes.

NChar(n) - Tipo de dado UNICODE que aceita 'n' bytes, mas armazena 2*n bytes.
           ele utiliza 2 bytes para representar um caracter.
           A palavra 'JOSE' em um tipo NCHAR(10) será gravado com 20 bytes de armazenamento.
           O dados deve ser representado com o N maiúsculo na frente do litera.

👇 Para saber mais:

 <div> 
<p><a href="https://github.com/JosiTubaroski/Design-de-Banco-de-Dados/edit/main/04%20-%20Tipos%20de%20Dados%2C%20Dom%C3%ADnio%20e%20armazenamento.sql"> Tipos de Dados, Domínio e armazenamento</a></p>
</div> 

<div> 
<p><a href="https://github.com/JosiTubaroski/Design-de-Banco-de-Dados/blob/main/05%20-%20Design%20da%20tabelas.sql"> Criando as melhores tabelas </a></p>
</div> 

<div> 
<p><a href="https://github.com/JosiTubaroski/Design-de-Banco-de-Dados/blob/main/06%20-%20Colunas%20Calculadas.sql"> Colunas calculadas </a></p>
</div> 


 # Gestão de desempenho com visões de gerenciamento dinâmicos - DMV

 DMV ou Exibições de Gerenciamento Dinâmico

 - As DMVs são objetos que informam o estado de diversos componentes de uma instancia do SQL Server, retornando um conjunto de
   informações úteis que irão nos ajudar por exemplo em entender o armazenamento ou a utilização de recursos. Claro, ajudar a identificar
   as querys mais lentas.

- Elas são acessadas pela instrução SELECT  e podem fazer parte de JOIN com outras DMVs. Apesar do nome ser exibição, as DMVs podem
  ser views ou functions.

- As informações apresentadas podem ser dados armazenados ou capturados do ambiente da Instância, sistema operacional ou banco de dados.

- Elas são divididas em grupos.

- São do eschema SYS e, na grande maioria dos casos, começam do prefixo DM.

Ref.: https://docs.microsoft.com/pt-br/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views

Obs: Alguns momentos iremos apresentar exibições do sistema que não são classificadas como DMVs.

👇 Para saber mais acesse:

<div> 
<p><a href="https://github.com/JosiTubaroski/Design-de-Banco-de-Dados/blob/main/09%20-%20Breve%20introdu%C3%A7%C3%A3o%20a%20DMVs.sql"> Gestão de desempenho com visões de gerenciamento dinâmico - DMV.</a></p>
</div> 

# Conceitos de Arvore Balanceada

## Introdução

Uma das técnicas mais eficientes para organizar dados para uma pesquisa rápida é a utilização de ordenação utilizando uma estrutura de dados conhecido como arvore binária.

 - Essa estrutura é capaz de organizar os dados a partir do nó raiz com um unico valor (ou uma única chave) e com dois ponteiros referenciando os próximos nós
 - Existe somente um nó raiz (root) onde começa a pesquisa.
 - Os nós intermediários onde se navega pela árvore.
 - Nós folhas (leaf) onde eles não possuem referência para outro nós.

  Ref.: https://pt.wikipedia.org/wiki/%C3%81rvore_bin%C3%A1ria

  - Devido a algumas dificuldades em incluir, alterar ou excluir dados dentro dessa árvore, foi criando uma estrutura semelhante que é conhecida como
    b-tree.

 Ref.: https://pt.wikipedia.org/wiki/%C3%81rvore_B

   - A diferença entre a árvore binária e a b-tree, é que a primeira é restrita a uma única chave de pesquisa em um determinado nó e tem dois ponteiros
     no máximo saindo de um nó.
     A segunda já permite um número maior de chaves em um nó e o número máximo de ponteiros saindo do será de total de chaves mais 1.

   - E temos uma outra variação da b-tree que é conhecido com b-tree+ (b-tree plus) que entre suas caracteristicas, a mais significativa é o encadeamento
     entre os nos de folhas

Ref.: https://pt.wikipedia.org/wiki/%C3%81rvore_B%2B

👇 Para saber mais:

<div> 
<p><a href="https://github.com/JosiTubaroski/Design-de-Banco-de-Dados/blob/main/10%20-%20Conceitos%20de%20Arvore%20Balanceada.sql"> Conhecendo arvores balanceadas.</a></p>
</div> 



         
    
 
           
