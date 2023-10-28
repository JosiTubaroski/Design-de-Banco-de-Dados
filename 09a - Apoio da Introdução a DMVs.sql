
Select @@SPID, GETDATE()

/*
Execute a primeira parte do script (at� a marca FinalScript)
*/
use DBDemo 
go

set nocount on 
go

Create Table #tItemModelo04 
(
   iID           smallint , 
   Codigo        varchar(20),                        
   Titulo        varchar(200),                       
   Descricao     varchar(3500),                      
   iIDFornecedor smallint ,                          
   Preco         smallmoney ,                        
   Comissao      numeric(4,2),                       
   ValorComissao smallmoney ,         
   Quantidade    smallint ,                          
   Frete         smallmoney                          
)                                                    
go
select @@SPID as SPID 

-- FinalScript 
go


while (select COUNT(1) from #tItemModelo04) <= 100000 begin 
   insert into #tItemModelo04
   select top 1 * from tItemModelo04 order by NEWID()
end 



/*
Segunda parte - Para explica��o das DMVs relacionadas a �ndices 
*/

-- Script 01 
use DBDemo
go

drop Table #tCidade  
go

Create Table #tCidade  
(
   cCidade varchar(30), 
   cUF char(2) , 
   nContagem int default 0 
)
go

drop table if exists tCliente
go

Create Table tCliente (
   iidCliente int not null identity(1,1) ,
   cNome varchar(100), 
   cCPF varchar(14),
   cCidade varchar(30),
   cUF char(2) ,
   dCadastro datetime,
   nValor int default 0  ,
   Constraint PKCliente Primary key 
   (
      iidCliente 
   )
)



insert into tCliente (cNome, cCPF,cCidade, cUF,dCadastro)
select cNome, cCPF,cCidade,cUF,dCadastro  from eCommerce.dbo.tCliente
go
insert into #tCidade (cCidade, cUF ) select distinct cCidade, cUF from tCliente 

-- Script01 


-- Script02
Create Unique Index IDUCPF on tCliente(cCPF)
go
Create Index IDXNome on tCliente(cNome)
go
Create index IDXUFCidade  on tCliente(cUF,cCidade) include (nValor)
go
Create index IDXCidadeUF on tCliente(cCidade,cUF) 
go
Create Index IDXCadastro on tCliente(dCadastro)
go
-- Script02

select * from sys.indexes

select tab.name as cTable, ind.name as cIndex, ind.type_desc as cTypeIndex,
ind.index_id
from sys.indexes ind
join sys.tables tab
 on ind.object_id = tab.object_id
where tab.name = 'tCliente'
order by index_id

--- Verificando as colunas que contem indices

select tab.name as cTable ,
       ind.name as cIndex ,
       Indcol.key_ordinal as nOrdinal , 
       col.name as cColumn
from sys.tables as tab
join sys.indexes as ind
  on tab.object_id = ind.object_id
join sys.index_columns indcol
  on ind.index_id = indcol.index_id 
  and ind.object_id = indcol.object_id
join sys.all_columns as col
  on indcol.column_id = col.column_id
  and indcol.object_id = col.object_id
where tab.name = 'tCliente'
 order by ind.index_id, indcol.key_ordinal

 sp_helpindex tCliente

 --- Estatisticas de Uso

 Select * from sys.dm_db_index_usage_stats
 where database_id = DB_ID()

 --- Apresenta o tamanho e fragmenta��o dos dados e indices

 select * from sys.dm_db_index_physical_stats (db_id(), null, null, null, 'LIMITED')

 --- Apresenta as opera��es de leitura e grava��o do n�vel mais baixo

 select * from sys.dm_db_index_operational_stats (db_id(), null, null, null)



/*
*/

-- Script03
declare @cCidade varchar(30)
declare @cUF char(2) 
declare @cCont int = 1 
declare @cCPF varchar(14) 
declare @nContCPF int = 1
declare @cNome varchar(100)

While @cCont <= 20000 Begin 
   
   raiserror('Contagem %d' ,10,1, @cCont) with nowait

   select @cNome = cNome from tCliente where iidcliente =  cast(rand()*199519 as int)
   
   if RAND()*2 > 1.5 
      Begin 

         Select top 1 @cCidade = cCidade , @cUF = cUF 
           From #tCidade 
          Order by NEWID()

         Select COUNT(1) as nTotalCliente 
           From tCliente 
        Where cUF = @cUF and cCidade = @cCidade 

        Update #tCidade 
		   Set nContagem = nContagem + 1
         Where cUF = @cUF 
		   and cCidade = @cCidade 

        if RAND()*2 > 1.5

           update tCliente 
           set nValor = nValor + 1 , cUF = LOWER(cUF) 
               Where substring(cUF,1,2) like '%'+@cUF+'%'
            
      End 
   Else 
      Begin
         
         set @cCPF = cast(FORMAT(cast(rand()*999999 as int),'00####') as varchar(14))+'%'
         
         Select @nContCPF = COUNT(1) 
           From tCliente 
          --Where cCPF like @cCPF+'%'
          where cCpf like @cCPF
          
         Select @nContCPF as nTotalCPF
          
         if @nContCPF > 0 
            Select MAX(cNome) as Nome  
              From tCliente 
            Where cCPF like @cCPF

      end 

   set @cCont += 1

 end 
 -- Script03

 go
 drop table #tCidade

select * from #tCidade 
