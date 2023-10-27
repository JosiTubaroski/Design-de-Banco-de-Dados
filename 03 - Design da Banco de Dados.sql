/*
Banco de dados..

- Defini��o cl�ssica: Um banco de dados � uma cole��o de tabelas estruturadas que 
  armazena um conjunto de dados.......

- O que interessa para esse treinamento: Os dados as aplica��es ficam armazenados em 
  arquivos em disco. 

- Cada banco de dados no SQL Server tem no m�nimo dois arquivos. Uma arquivo de dados
  conhecido como arquivo Prim�rio e tem a extens�o MDF e outro arquivo de log 
  com a extens�o LDF para registrar os log de trans��o (vamos tratar somente de
  arquivo de dados neste treinamento). 

*/
Drop Database if exists DBTeste
go

Create Database DBTeste
go

Use DBTeste
go

select * from sys.database_files

/*
- Cada arquivo tem um FILE ID que � o n�mero de identifica��o do arquivo. Importante.
- A coluna DATA_SPACE_ID � a identifica��o desse arquivo dentro um grupo de arquivo. 
- A coluna NAME � o nome l�gico do arquivo
- A coluna SIZE � o tamanho alocado do arquivo em p�ginas de dados
- A coluna GROWTH � a taxa de crescimento do arquivo em bytes
*/

/*

- No arquivo Prim�rio ou MDF al�m de termos os dados da aplica��o, temos tamb�m as 
  informa��es sobre :

  - Inicializa��o do banco de dados;
  - A refer�ncia para outros arquivos de dados do banco;
  - Metadados de todos os objetos de banco de dados criados pelos desenvolvedores.

  Todo e qualquer comando que tenha alguma refer�ncia a objetos como tabela, colunas, view, etc.,
  sempre consulta os metadados desses objetos no arquivo prim�rio.

  Um simples SELECT Coluna FROM Tabela, faz com que o SQL Server consulte nos metadados se a COLUNA
  existe e se a TABELA existe tamb�m. 
  
- Existe um outro tipo de arquivo que podemos (e devemos) associar ao banco de dados que � conhecido 
  como Secund�rio de dados. Ele tem a extens�o NDF.

  Cada arquivo de dados deve possuir algumas caracter�sticas como :

      - Ser� agrupado junto com outros arquivos de dados em um grupo l�gico chamado
        de FILEGROUP (FG). Se n�o especificado o FG, o arquivo fica no grupo de arquivo PRIMARY.

      - Deve ter um nome l�gico que ser� utilizado em instru��es T-SQL;

      - Deve ter um nome f�sico onde consta o local o arquivo no sistema operacional;

      - Dever ter um tamanho inicial para atender a carga de dados atual e uma previs�o
        futura;

      - Deve ter uma taxa de crescimento definida. Ela ser� utiliza para aumentar o 
        tamanho do arquivo de dados quando o mesmo estiver cheio;

      - Deve ter um limite m�ximo de crescimento. Isso � importante para evitar 
        que arquivos crescem � ocupem todo o espa�o em disco.

Exemplos de cria��o de banco de dados :

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

CREATE DATABASE DBDemoA                      -- Instru��o par criar o banco de dados.
ON PRIMARY                                   -- FG PRIMARY. 
 ( NAME = 'Primario',                        -- Nome l�gico do arquivo.
   FILENAME = 'D:\DBDemoA_Primario.mdf' ,    -- Nome f�sico do arquivo.
   SIZE = 256MB                              -- Tamanho inicial do arquivo.
 ) 
LOG ON 
 ( NAME = 'Log', 
   FILENAME = 'F:\DBDemoA_Log.ldf' , 
   SIZE = 12MB 
  )
GO

use DBDemoA
go

Select size*8 as TamanhoKb , growth  as CrescimentoKB , *  from sys.database_files
go

/*
Criando com 2 arquivos de dados 
*/

Use Master
go

DROP DATABASE if exists DBDemoA
GO

CREATE DATABASE DBDemoA
ON PRIMARY 
 ( NAME = 'Primario', 
   FILENAME = 'D:\DBDemoA_Primario.mdf' , 
   SIZE = 256MB 
 ),                                             -- Segundo Arquivo de dados, no mesmo FG
 ( NAME = 'Secundario',                         
   FILENAME = 'E:\DBDemoA_Secundario.ndf' , 
   SIZE = 256MB 
 ) 
LOG ON 
 ( NAME = 'Log', 
   FILENAME = 'F:\DBDemoA_Log.ldf' , 
   SIZE = 12MB 
  )
GO

/*
   No exemplo acima, temos dois arquivos de dados no FG PRIMARY. Os dados gravados
   nesse grupo ser�o distribuidos de forma proporcional dentro dos arquivos.
*/

use DBDemoA
go

Select size*8 as TamanhoKb , growth *8 as CrescimentoKB , *  from sys.database_files

/*

FILEGROUP
---------

- FILEGROUP � um agrupamento l�gico de arquivos de dados para distribuir melhor a 
  aloca��o de dados entre os discos, agrupar dados de acordo com contextos ou 
  arquivamentos como tamb�m permitir ao DBA uma melhor forma de administra��o.

  No nosso caso, vamos focar em melhorar o desempenho das consultas.
      
*/

Use Master
go

DROP DATABASE if exists DBDemoA
GO

CREATE DATABASE DBDemoA
ON PRIMARY                                      -- FG Primario 
 ( NAME = 'Primario', 
   FILENAME = 'D:\DBDemoA_Primario.mdf' , 
   SIZE = 64MB 
 ), 
FILEGROUP DADOS                                 -- FG com o nome DADOS 
 ( NAME = 'DadosTransacional1',                 
   FILENAME = 'E:\DBDemoA_SecundarioT1.ndf' , 
   SIZE = 1024MB
 ) ,
 ( NAME = 'DadosTransacional2', 
   FILENAME = 'E:\DBDemoA_SecundarioT2.ndf' , 
   SIZE = 1024MB
 ) 
LOG ON 
 ( NAME = 'Log', 
   FILENAME = 'F:\DBDemoA_Log.ldf' , 
   SIZE = 512MB 
  )
GO

/*
Estamos dizendo para o SQL SERVER onde ele deve gravar todos os dados da 
aplica��o. 
*/
ALTER DATABASE [DBDemoA] MODIFY FILEGROUP [DADOS] DEFAULT 
GO



USE DBDemoA
GO

Select size*8 as TamanhoKb , growth as CrescimentoKB , *  from sys.database_files
go

Select * from sys.filegroups
go 


/*
*/

select * from sys.dm_db_file_space_usage

/*
Ref.: https://docs.microsoft.com/pt-br/sql/relational-databases/system-dynamic-management-views/sys-dm-db-file-space-usage-transact-sql
*/


Use Master
go

DROP DATABASE if exists DBDemoA
GO



CREATE DATABASE DBDemoA
ON PRIMARY 
 ( NAME = 'Primario', 
   FILENAME = 'D:\DBDemoA_Primario.mdf' , 
   SIZE = 512MB ,
   MAXSIZE = 512MB  
 ), 
FILEGROUP DADOS
 ( NAME = 'DadosTransacional1', 
   FILENAME = 'd:\DBDemoA_SecundarioT1.ndf' , 
   SIZE = 1024MB,
   MAXSIZE = 10GB  

 ) ,
 ( NAME = 'DadosTransacional2', 
   FILENAME = 'd:\DBDemoA_SecundarioT2.ndf' , 
   SIZE = 1024MB,
   MAXSIZE = 10GB  
 ) ,
 FILEGROUP INDICES 
 ( NAME = 'IndicesTransacionais1', 
   FILENAME = 'E:\DBDemoA_SecundarioI1.ndf' , 
   SIZE = 1024MB,
   MAXSIZE = 10GB  
 ) ,
 ( NAME = 'IndicesTransacionais2', 
   FILENAME = 'E:\DBDemoA_SecundarioI2.ndf' , 
   SIZE = 1024MB,
   MAXSIZE = 10GB  
 ),
 FILEGROUP DADOSHISTORICO
 ( NAME = 'DadosHistorico1', 
   FILENAME = 'E:\DBDemoA_SecundarioH1.ndf' , 
   SIZE = 1024MB,
   MAXSIZE = 20GB  
 ) ,
 ( NAME = 'DadosHistorico2', 
   FILENAME = 'E:\DBDemoA_SecundarioH2.ndf' , 
   SIZE = 1024MB,
   MAXSIZE = 20GB  
 ) 

LOG ON 
 ( NAME = 'Log', 
   FILENAME = 'F:\DBDemoA_Log.ldf' , 
   SIZE = 512MB 
  )
GO
go
ALTER DATABASE [DBDemoA] MODIFY FILEGROUP [DADOS] DEFAULT 
GO

/*
Analisando o Banco
*/

use DBDemoA
go

Select size*8 as TamanhoKb , growth  as CrescimentoKB , *  from sys.database_files
go
Select * from sys.filegroups
go 

select * from sys.dm_db_file_space_usage
