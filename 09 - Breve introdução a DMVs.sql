/*
DMV ou Exibi��es de Gerenciamento Din�mico 

- As DMVs s�o objetos que informam o estado de diversos componentes de 
  uma inst�ncia do SQL Server, retornando um conjunto de informa��es
  �teis que ir�o n�s ajudar por exemplo em entender o armazenamento ou a 
  utiliza��o de recursos. Claro, ajudar a identificar as querys mais lentas.

- Elas s�o acessas pela instru��o SELECT e podem fazer parte de JOIN com outras
  DMVs. Apesar do nome ser exibi��o, as DMVs podem ser views ou functions.

- As informa��es apresentados podem ser dados armazenados ou capturados do ambiente
  da inst�ncia, sistema operacional ou banco de dados.

- Elas s�o divididas em grupos.

- S�o do eschema SYS e, na grande maioria dos casos, come�am do o prefixo DM.

Ref.: https://docs.microsoft.com/pt-br/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views

Obs: Alguns momento iremos apresentar exibi��es do sistema que n�o s�o classificadas como DMVs. 

*/


use DBDemo
go

Select name,type, type_desc  
  From sys.system_objects
 Where name like 'DM[_]%'
 Order by name
go

Create or Alter View vDMVs
as
Select substring(substring(name,4,100),1,charindex('_',substring(name,4,100))-1)  as tipo,  
       name,
       type, 
       type_desc  
  From sys.system_objects
 Where name like 'DM[_]%'

go


/*
DMVs de Sistema Operacional do SQL Server - OSSQL.
--------------------------------------------------
*/

select * from vDMVs where tipo = 'os'

select * from sys.dm_os_host_info
select * from sys.dm_os_sys_info

select * from sys.dm_os_sys_memory

select * from sys.dm_os_file_exists('c:\windows\system.ini')
select * from sys.dm_os_file_exists('c:\windows')


-- Apresenta os contadores de desempenho para o SQL Server 
select * from sys.dm_os_performance_counters


-- Apresenta todos os buffer pools onde as paginas est�o localizadas
select * from sys.dm_os_buffer_descriptors

-- Apresenta o tamanho ocupado atual do buffer pool 
select count(*) * 8 / 1024.0  as nTamanhoBufferMB from sys.dm_os_buffer_descriptors

-- Apresenta o tamanho ocupado atual do buffer pool para cada banco de dados
select db_name(database_id) as cDatabase , 
       count(*) * 8 / 1024.0  as nTamanhoBufferMB 
  from sys.dm_os_buffer_descriptors
 group by db_name(database_id)
 order by nTamanhoBufferMB desc 




/*
DMVs relacionadas as execu��es, conex�es e sess�o.
--------------------------------------------------
*/

Select * From vDMVs Where tipo = 'exec'


/*
Mostra as Sess�es autenticadas na inst�ncia do SQL Server.
*/

Select * 
  From sys.dm_exec_sessions

/*
Session_id at� 50 s�o sess�es utilizadas internamente pelo SQL Server 
*/

Select * 
  From sys.dm_exec_sessions 
  Where session_id >= 51

/*
Ref.: https://docs.microsoft.com/pt-br/sql/relational-databases/system-dynamic-management-views/sys-dm-exec-sessions-transact-sql?view=sql-server-2017
*/

/*
Mostra as informa��es sobre as execu��es
*/

Select * 
  From sys.dm_exec_requests 
  Where session_id >= 51
  
Select @@SPID  -- Retorna a Identifica��o da sess�o do processo da conex�o atual 

Select * 
  From sys.dm_exec_requests 
  Where session_id = @@SPID

/*
Aten��o!!!
Somente abrar o arquivo 09a - Apoio a Introdu��o a DMVs.SQL
Ser� estabelecida uma nova sess�o.

*/

Select session_id ,  program_name, login_name , status, cpu_time, memory_usage, 
       reads, writes, logical_reads 
  From sys.dm_exec_sessions 
  where session_id >= 51 

Select session_id, start_time , status, command  , database_id , cpu_time , 
       reads, writes, logical_reads ,sql_handle
  From sys.dm_exec_requests 
  Where session_id >= 51


/*
Visualiza o conte�do do SQL_HANDLE 
*/

select text from sys.dm_exec_sql_text(0x020000007316630B97894DB33C1DEFD265921F0E7CA47E120000000000000000000000000000000000000000)


/*
Estat�sticas de desempenho dos planos de execu��o.
*/

select * from sys.dm_exec_query_stats

/*
Ref.: https://docs.microsoft.com/pt-br/sql/relational-databases/system-dynamic-management-views/sys-dm-exec-query-stats-transact-sql?view=sql-server-2017
*/


/*
DMVs relacionadas a banco de dados 
----------------------------------
*/

select * from vDMVs where tipo = 'db'
order by name 



use DBDemo
go

select * from sys.dm_db_file_space_usage




use DBDemoTable
go
select * from sys.dm_db_file_space_usage

/*
DMVs relacionadas a �ndices 
----------------------------
*/

use DBDemo
go


/*
Apresenta os indices atuais, utilizando as views de cat�logo do sistema.

Abrir o arquivo 09a - Apoio a introdu��o a DMVs
ir at� "Segunda parte - Para explica��o das DMVs relacionadas a �ndices"
e executar o script 01 e 02 .

*/


Select * from sys.indexes 
Select * from sys.tables


Select tab.name as cTable , ind.name as cIndex    , ind.type_desc as cTypeIndex  , ind.index_id 
  From sys.indexes ind 
  Join sys.tables tab
   on ind.object_id = tab.object_id 
  where tab.name = 'tCliente'
  order by index_id


/*
Identificando as tabelas, seus indices e colunas dos �ndices (chaves) 
*/
 
Select tab.name as cTable , 
       ind.name as cIndex , 
       ind.type_desc  as cTypeDesc , 
       indcol.key_ordinal as nOrdinal  , 
       col.name as cColumn
  from sys.tables as tab
  join sys.indexes as ind 
   on tab.object_id = ind.object_id 
  join sys.index_columns indcol 
    on ind.index_id = indcol.index_id and ind.object_id = indcol.object_id 
  join sys.columns as col
    on indcol.column_id = col.column_id and indcol.object_id =  col.object_id 
  where tab.name = 'tCliente'
    order by ind.index_id, indcol.key_ordinal

sp_helpindex tCliente

/*

*/


Select * From sys.dm_db_index_usage_stats
where database_id = DB_ID()

-- Apresenta o tamanho e fragmenta��o dos dados e �ndices.
Select   * From sys.dm_db_index_physical_stats(db_id(),null,null,null,'LIMITED')

-- Apresenta as opera��es de leitura e grava��o do n�vel mais baixo.
Select * from sys.dm_db_index_operational_stats(db_id(),null,null,null)



