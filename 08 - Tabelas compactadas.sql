/*

Compacta��o de dados. 

-- Recurso do SQL Server para compactar dados pelas linhas ou p�ginas de dados.

-- A compacta��o tem como objetivo reduzir o espa�o alocado pelo banco de dados em 
   disco, como tamb�m aumentar a performance de acesso aos dados, visto que com a 
   compacta��o, � poss�vel alocar mais bytes em uma p�gina de dados.

-- Ela n�o altera o tamanho da p�gina de dados como tamb�m n�o
   altera o limite de bytes em um linha de dados, que � de 8060 bytes, mas
   permite alocar um maior n�mero de linhas por p�ginas.
   
-- Pode ser aplicada em uma tabela sem �ndices (heap table),
   uma tabela com �ndices agrupado (clusterizado) ou apenas compacta��o de 
   �ndices.

-- Mas n�o � toda da tabela que pode ser compactada ou que realmente teremos
   algum ganho de armazenamento ou performance se compactaramos.

-- Um exemplo � uma tabela cuja a soma dos bytes armazenados for pr�ximo a 8060 caracteres,
   n�o haver� ganho de compacta��o significativo devido ao total de bytes que ser�o
   compactados mais os bytes adicionais para realizar a compacta��o.

-- Uma tabela quem cont�m muitos dados exclusivos (ou �nicos) n�o ganhar� benef�cios
   da compacta��o.

-- Vamos fazer a compacta��o com 3 cen�rios e utilizando a compacta��o de p�ginas.

Ref.: https://msdn.microsoft.com/en-us/library/dd894051.aspx


*/

use DBDemo
go


/*
Cadastro de clientes 
Tamanho da linha : 500 bytes
Dados : Tabela de cadastro com alto �ndices de dados exclusivos.

*/

drop table if exists tCliente

select iIDCliente, iIDEstado, cNome, cCPF, cEmail, cCelular, dCadastro, dNascimento, cLogradouro, cCidade, cUF, cCEP, dDesativacao, mCredito
  into tCliente 
  From eCommerce.dbo.tCliente

select top 10 *  from tCliente
go

sp_spaceused 'tCliente'

sp_help 'tCliente'

EXEC sp_estimate_data_compression_savings 'dbo', 'tCliente', null, NULL, 'PAGE' ;  
go

-- Ref.: https://docs.microsoft.com/pt-br/sql/relational-databases/system-stored-procedures/sp-estimate-data-compression-savings-transact-sql

/*
Tamanho atual    = 32.136 KB
Tamanho estimado = 30.064 KB
Taxa estimada    =    6,54%

*/

select total_pages , used_pages , data_pages  , p.data_compression_desc 
  from sys.allocation_units au 
  join sys.partitions p
    on au.container_id =  p.partition_id
	where p.object_id = object_id('tCliente')
	  and au.type = 1
go

/*
total_pages          used_pages           data_pages           data_compression_desc
-------------------- -------------------- -------------------- ------------------------------------------------------------
4025                 4017                 4016                 NONE
*/

ALTER TABLE dbo.tCliente
      REBUILD PARTITION = ALL  
	  WITH (DATA_COMPRESSION = PAGE)   
go

select total_pages , used_pages , data_pages  , p.data_compression_desc 
  from sys.allocation_units au 
  join sys.partitions p
    on au.container_id =  p.partition_id
	where p.object_id = object_id('tCliente')
	  and au.type = 1

/*
         total_pages          used_pages           data_pages           data_compression_desc
         -------------------- -------------------- -------------------- ------------------------------------------------------------
Antes    4025                 4017                 4016                 NONE
Depois   3769                 3757                 3756                 PAGE

*/


/*
Movimento 
Tamanho da linha : 120 bytes
Dados : Tabela de movimentos, com dados de tamanho curto, com tend�ncias de dados repetidos e colunas com NULL.

*/
drop table if exists tMovimento
go

select * into tMovimento from eCommerce.dbo.tMovimento 
go

sp_spaceused 'tMovimento'   
sp_help 'tMovimento'
go

EXEC sp_estimate_data_compression_savings 'dbo', 'tMovimento', null, NULL, 'PAGE' ;  
go

/*
Tamanho atual    = 17.464
Tamanho estimado =  5.984
Taxa estimada    =    66%

*/

select total_pages , 
       used_pages , 
       data_pages  , 
       p.data_compression_desc 
  from sys.allocation_units au 
  join sys.partitions p
    on au.container_id =  p.partition_id
 where p.object_id = object_id('tMovimento')
	
go
/*
total_pages          used_pages           data_pages           data_compression_desc
-------------------- -------------------- -------------------- ------------------------------------------------------------
1977                 1962                 1961                 NONE

*/

ALTER TABLE dbo.tMovimento 
      REBUILD PARTITION = ALL  
	  WITH (DATA_COMPRESSION = PAGE)   
go

select total_pages , 
       used_pages , 
       data_pages  , 
       p.data_compression_desc 
  from sys.allocation_units au 
  join sys.partitions p
    on au.container_id =  p.partition_id
 where p.object_id = object_id('tMovimento')
	 
/*
         total_pages          used_pages           data_pages           data_compression_desc
         -------------------- -------------------- -------------------- ------------------------------------------------------------
Antes    1977                 1962                 1961                 NONE
Depois    673                  666                  665                 PAGE
       65.95%
           
*/


/*
Movimento de Itens 
Tamanho da linha : 50 bytes
Dados : Tabela dos itens do movimento, com dados de tamanho curto e somente n�mericos e com tend�ncias de dados repetidos.


*/
drop table if exists tItemMovimento
go

select * into tItemMovimento from eCommerce.dbo.tItemMovimento
go

select top 10 * from tItemMovimento
go


sp_spaceused 'tItemMovimento'
sp_help 'tItemMovimento'


EXEC sp_estimate_data_compression_savings 'dbo', 'tItemMovimento', null, NULL, 'PAGE' ;  
go

/*
Tamanho atual    = 29.640
Tamanho estimado = 10.168
Taxa estimada    = 65,69%

*/

select total_pages , 
       used_pages , 
       data_pages  , 
       p.data_compression_desc 
  from sys.allocation_units au 
  join sys.partitions p
    on au.container_id =  p.partition_id
 where p.object_id = object_id('tItemMovimento')
	
go
/*
total_pages          used_pages           data_pages           data_compression_desc
-------------------- -------------------- -------------------- ------------------------------------------------------------
3305                 3293                 3292                 NONE

*/

ALTER TABLE dbo.tItemMovimento 
      REBUILD PARTITION = ALL  
	  WITH (DATA_COMPRESSION = PAGE)   
go

select total_pages , 
       used_pages , 
       data_pages  , 
       p.data_compression_desc 
  from sys.allocation_units au 
  join sys.partitions p
    on au.container_id =  p.partition_id
 where p.object_id = object_id('tItemMovimento')
	 
/*
/*
         total_pages          used_pages           data_pages           data_compression_desc
         -------------------- -------------------- -------------------- ------------------------------------------------------------
Antes    3305                 3294                 3293                 NONE
Depois   1137                 1124                 1123                 PAGE
       65,59%
*/
           





