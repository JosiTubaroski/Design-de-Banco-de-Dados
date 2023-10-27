DROP DATABASE IF EXISTS DBDemoA

/*
Criando tabelas.

- Como j� disse, as tabelas s�o um dos objetos de aloca��o de dados e tamb�m
  � a representa��o l�gica dos dados.  

- A estrutura apresentada no momento de sua cria��o � de f�cil interpreta��o para 
  o desenvolvedor. Ela tem o armazenamento f�sico que � a aloca��o desses dados 
  em p�ginas de dados. 

- Antes de entendermos como os dados s�o gravados nessas p�ginas, temos que 
  tomar alguns cuidados no momento de definir as colunas e criar a tabela. 

*/


/*

Localiza��o dentro dos FG
-------------------------

- Uma tabela quando criada, deve ser especificado em qual FG ela ser� armazenada.
- Se n�o informado, ele � criada no FG padr�o. Se quando o banco de dados foi 
  criado e n�o foi informado o FG, ent�o a tabela � criada no FG PRIMARY. 

- Para criar uma tabela dentro de um FG, voc� deve informar na cria��o da tabela,
  qual � o FG.

*/

use master
go

DROP DATABASE IF EXISTS DBDemoTable 
GO

CREATE DATABASE DBDemoTable 
ON PRIMARY       ( NAME = 'Primario', FILENAME = 'D:\DBDemoTable.mdf'   ),
FILEGROUP DADOS1 ( NAME = 'Dados1',   FILENAME = 'D:\DBDemoTable1.ndf'  ),
FILEGROUP DADOS2 ( NAME = 'Dados2',   FILENAME = 'E:\DBDemoTable2.ndf'  ),
FILEGROUP DADOS3 ( NAME = 'Dados3',   FILENAME = 'E:\DBDemoTable3.ndf'  ) ,
FILEGROUP DADOS4 ( NAME = 'Dados4',   FILENAME = 'E:\DBDemoTable4.ndf'  ) 
LOG ON           ( NAME = 'Log',      FILENAME = 'F:\DBDemoTableLog.ldf' )
GO

/*
Defini��o do FILEGROUP default.
*/
ALTER DATABASE DBDemoTable MODIFY FILEGROUP DADOS1 DEFAULT 
GO

USE DBDemoTable 
go 

/*
Apresenta o tamanho alocado do FG e as quantidades em KB espa�o utilizados e espa�os livres.
*/
select fg.name ,
       8 * su.total_page_count              as nTamanhoKb, 
       8 * su.allocated_extent_page_count   as nUsadoKB, 
       8 * su.unallocated_extent_page_count as nLivreKB
  from sys.dm_db_file_space_usage su 
  join sys.filegroups fg 
    on su.filegroup_id = fg.data_space_id

GO 


Create Table tExemplo1 
(
   id int ,
   nome char(20)
) 

/*
Como n�o foi citado qualquer refer�ncia de FG, o SQL Server 
assume o FG default que neste caso � o DADOS1
*/

/*
Apresenta o nome da tabela e em qual FG ela foi criada 
*/

Select object_name(i.object_id) as [Table] , d.name as Filegroup 
  from sys.data_spaces d
  join sys.indexes i 
    on d.data_space_id = i.data_space_id
 where i.object_id = object_id('tExemplo1')
   and i.index_id in (0,1) 
go

/*
Refer�ncia
sys.data_spaces : https://docs.microsoft.com/pt-br/sql/relational-databases/system-catalog-views/sys-data-spaces-transact-sql
sys.indexes : https://docs.microsoft.com/pt-br/sql/relational-databases/system-catalog-views/sys-indexes-transact-sql
*/


Create Table tExemplo2 
(  
   id int ,
   nome char(20)
) On Dados2     -- << Defini��o do FG

go

Select object_name(i.object_id) as [Table] , d.name as Filegroup 
  from sys.data_spaces d
  join sys.indexes i 
    on d.data_space_id = i.data_space_id
 where i.index_id in (0,1) 
   and object_name(i.object_id) in ('tExemplo1','tExemplo2')
go



/*

Exemplo de como a defini��o da estrutura influ�ncia na ocupa��o das 
p�ginas de dados. 

Vamos mostrar alguns exemplos de tabelas que atendem a mesma demanda para 
armazenar dados mas com estruturas diferentes e depois vamos ver a 
quantidade de p�ginas utilizadas para cada uma dessas tabelas. 

O cen�rio � o seguinte :

Cadastro de Itens de Loja Virtual
----------------------------------

Identifica��o do Item
T�tulo do Item
Breve descri��o
Nome do Fornecedor
Pre�o de venda
Comiss�o da venda
Valor Comiss�o 
Quantidade dispon�vel
Valor do frete

Algumas regras: 

- Ser�o no total 15.000 itens, com um aumento de 500 novos itens a cada ano.
- Os fornecedores enviam os itens com os dados para serem cadastrados.
- Trabalhos com poucos fornecedores e selecionados. 
  Com aproximadamente 5.000 cadastros com cerca de 20 novos por ano.
- Cada item tem um c�digo que � do fornecedor, que em alguns casos 
  chegam no limite de 20 caracteres
- A comiss�o de venda � definida com o fornecedor � tem um valor percentual fixo. 

Foram criadas quatro exemplos de tabelas, conforme script abaixo:

*/

USE DBDemoTable 
go 


drop table if exists tItemModelo01 
go
drop table if exists tItemModelo02
go
drop table if exists tItemModelo03 
go
drop table if exists tItemModelo04 
go


Create Table tItemModelo01 
(
   Codigo        nchar(20) primary key ,       -- 40 bytes 
   Titulo        nvarchar(200),                -- 400 bytes 
   Descricao     nvarchar(3500),               -- 7000 bytes 
   Fornecedor    nvarchar(100),                -- 200 bytes 
   Preco         money ,                       -- 8 bytes 
   Comissao      money ,                       -- 8 bytes 
   ValorComissao money ,                       -- 8 bytes 
   Quantidade    int ,                         -- 8 bytes 
   Frete         money                         -- 8 bytes 
) on DADOS1                                    -- +- 7680 bytes limite m�ximo de aloca��o.
go 


Create Table tItemModelo02 
(
   Codigo        char(20) primary key ,  -- 20 bytes,  Troca de NCHAR para CHAR 
   Titulo        varchar(200),           -- 200 bytes Troca de NVARCHAR para VARCHAR 
   Descricao     varchar(3500),          -- 3500 bytes 
   Fornecedor    varchar(100),           -- 100 bytes 
   Preco         money ,                 -- 8 bytes 
   Comissao      money ,                 -- 8 bytes 
   ValorComissao money ,                 -- 8 bytes 
   Quantidade    int ,                   -- 4 bytes 
   Frete         money                   -- 8 bytes 
) on DADOS2                              -- +- 3856 bytes 
go 

Create Table tItemModelo03
(
   iID           int primary key identity(1,1) ,  -- 4 bytes, incluimos uma PK INT com numera��o autom�tica.
   Codigo        varchar(20),                     -- 20 bytes 
   Titulo        varchar(200),                    -- 200 bytes 
   Descricao     varchar(3500),                   -- 3500 bytes 
   iIDFornecedor int ,                            -- 4 bytes ,considero que os dados de Fornecedor em outra tabela. 
   Preco         money ,                          -- 8 bytes 
   Comissao      numeric(4,2),                    -- 5 bytes, Como a comiss�o � um percentual (99,99)
   ValorComissao money ,                          -- 8 bytes 
   Quantidade    int ,                            -- 4 bytes 
   Frete         money                            -- 8 bytes 
) on DADOS3                                       -- +- 3761 bytes 
go

Create Table tItemModelo04 
(
   iID           smallint primary key identity(1,1), -- 2 bytes , Como a tabela ter� 15.000, smallint 
   Codigo        varchar(20),                        -- 20 bytes 
   Titulo        varchar(200),                       -- 200 bytes 
   Descricao     varchar(3500),                      -- 3500 bytes 
   iIDFornecedor smallint ,                          -- 2 bytes, no m�ximo 5000 fornecedores 
   Preco         smallmoney ,                        -- 4 bytes Preco com valor m�ximo de 200 mil.
   Comissao      numeric(4,2),                       -- 5 bytes 
   ValorComissao as (Preco * Comissao/100) ,         -- 0 bytes, em vez de guardar a comiss�o, calculamos. 
   Quantidade    smallint ,                          -- 2 bytes Armazena ate 32.000 quantidade do Item .
   Frete         smallmoney                          -- 4 bytes Frete com valor m�ximo de 200 mil.
) on DADOS4                                          -- +- 3739 
go

set nocount on
go


declare @cCodigo varchar(20) = substring(cast(newid() as varchar(36)),1,20)
declare @cDescricao varchar(3500) = replicate('A', rand()*3500)

insert into tItemModelo01 
       (Codigo  ,Titulo   ,Descricao  , Fornecedor      ,Preco,Comissao, ValorComissao, Quantidade,Frete)
values (@cCodigo,'AAAAAAA',@cDescricao,'FORNECEDOR AAAA', 100 ,     100,           100,        100,  100) 

insert into tItemModelo02 (Codigo,Titulo,Descricao, Fornecedor,Preco,Comissao, ValorComissao, Quantidade , Frete)
values (@cCodigo,'AAAAAAA',@cDescricao,'FORNECEDOR AAAA', 100, 100, 100, 100,100) 

insert into tItemModelo03 (Codigo,Titulo,Descricao, iIDFornecedor,Preco,Comissao, ValorComissao, Quantidade , Frete)
values (@cCodigo,'AAAAAAA',@cDescricao,RAND()*10000, 100, 50, 100, 100,100) 

insert into tItemModelo04 (Codigo,Titulo,Descricao, iIDFornecedor,Preco,Comissao,Quantidade,Frete)
values (@cCodigo,'AAAAAAA',@cDescricao,RAND()*10000, 100, 50, 100, 100) 

GO 15000


select fg.name ,
       su.total_page_count  as  nTotalPaginas , 
       su.allocated_extent_page_count  as nPaginasUsada, 
       su.unallocated_extent_page_count   as nPaginasLivre, 
	   -------
       su.total_page_count * 8192 / 1024.0 as nTamanhoKb, 
       su.allocated_extent_page_count * 8 / 1024.0 nUsadoKB, 
       su.unallocated_extent_page_count  * 8 / 1024.0 nLivreKB
  from sys.dm_db_file_space_usage su 
  join sys.filegroups fg 
    on su.filegroup_id = fg.data_space_id


	select fg.name ,
       8 * su.total_page_count              as nTamanhoKb, 
       8 * su.allocated_extent_page_count   as nUsadoKB, 
       8 * su.unallocated_extent_page_count as nLivreKB
  from sys.dm_db_file_space_usage su 
  join sys.filegroups fg 
    on su.filegroup_id = fg.data_space_id

/*
*/

select top 100* from tItemModelo01 where Codigo = '000204D7-65F2-4608-B'
select top 100* from tItemModelo02 where Codigo = '000204D7-65F2-4608-B'
select top 100* from tItemModelo03 where Codigo = '000204D7-65F2-4608-B'
select top 100* from tItemModelo04 where Codigo = '000204D7-65F2-4608-B'



