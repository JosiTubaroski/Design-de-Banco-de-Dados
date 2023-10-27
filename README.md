# Design de Banco de Dados

Banco de dados em vários arquivos. Aumenta a eficiência

- Definição clássica: Um banco de dados é uma coleção de tabelas estruturadas que armazena um conjunto de dados....

- O que interessa para esse treinamento: Os dados as aplicações ficam armazenadas em arquivos em disco.

- Cada banco de dados no SQL Server tem no minimo dois arquivos. Um arquivo de dados conhecido com arquivo Primário e tem a
  extensão MDF e outro arquivo de log com a extensão LDF para registrar os logs da transação (vamos tratar somente de
  arquivo de dados nesse treinamento).

Drop Database if exists DBTeste
go

Create Database DBTeste
go

Use DBTeste
go

select * from sys.database_files

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

Exemplos de criação de banco de dados:

*/
Drop Database if exists DBDemo_01
go

CREATE DATABASE DBDemo_01
GO

USE DBDemo_01
GO

Select size*8 as TamanhoKb , growth as CrescimentoKB , *  
  From sys.database_files

use Master
go

DROP DATABASE DBDemo_01
GO

/*

*/
DROP DATABASE if exists DBDemoA
GO

CREATE DATABASE DBDemoA                      -- Instrução par criar o banco de dados.
ON PRIMARY                                   -- FG PRIMARY. 
 ( NAME = 'Primario',                        -- Nome lógico do arquivo.
   FILENAME = 'D:\DBDemoA_Primario.mdf' ,    -- Nome físico do arquivo.
   SIZE = 256MB                              -- Tamanho inicial do arquivo.
 ) 
LOG ON 
 ( NAME = 'Log', 
   FILENAME = 'F:\DBDemoA_Log.ldf' , 
   SIZE = 12MB 
  )
GO

- FILEGROUP é um agrupamento lógico de arquivos de dados para distribuir melhor a alocação de dados entre discos, agrupar dados
  de acordo com contextos ou arquivamentos como também permitir ao DBA uma melhor forma de administração.

  No nosso caso, vamos focar em melhorar o desempenho das consultas.

  Consulte todas as queries utilizadas


     
