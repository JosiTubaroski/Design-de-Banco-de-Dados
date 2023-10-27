/*
- Colunas Calculadas e Persistidas

Uma coluna calculada � utilizada quando realizamos um c�lculo ou montamos uma express�o e 
associamos a uma coluna.

O dado retornado por essa coluna � calculado no momento em que o mesmo for solicitado. 

*/
USE DBDemoTable 
go 

drop table if exists tItemModelo04 
go

Create Table tItemModelo04 
(
   iID           smallint primary key identity(1,1), 
   Codigo        varchar(20),
   Titulo        varchar(200),
   Descricao     varchar(5000),
   iIDFornecedor int ,
   Preco         smallmoney , 
   Comissao      numeric(5,2),
   ValorComissao as (Preco * Comissao/100) , -- Coluna Calculada.
   Quantidade    smallint ,
   Frete         smallmoney 
) on DADOS4
go

insert into tItemModelo04 (Codigo,Titulo,Descricao, iIDFornecedor,Preco,Comissao,Quantidade,Frete)
values ('Cod1154','AAAAAAA','aaaa' ,RAND()*10000, 128.00 , 10.00, 100, 100) 

select * from tItemModelo04

update tItemModelo04 set comissao = 20.00 where iID = 1

select * from tItemModelo04

sp_help tItemModelo04

/*
Veja que a coluna calculada � apresentada na estrutura da tabela, mas o dados
n�o est�o armazenado. 

Quando o dado dessa coluna for retornado, ele ser� calculado conforme a f�rmula e 
ser� retornando o tipo NUMERIC(20,10) e ocupando 13 bytes. 

*/

Alter table tItemModelo04 drop column ValorComissao 
go
Alter table tItemModelo04 add ValorComissao as cast((Preco * Comissao/100) as smallmoney)  -- Coluna Calculada.

select * from tItemModelo04

sp_help tItemModelo04

/*
Agora se o valor dessa coluna for retornado, ele ser� calculado conforme a f�rmula e 
ser� retornando o tipo SMALLMONEY e ocupando 4 bytes. 

*/



/*
Por uma necessidade de acesso mais r�pido desse dado ou se ele ser� parte
de um �ndices de pesquisa, voce tem a op��o de persistir o dado em disco. 
*/


drop table if exists tItemModelo04 
go

Create Table tItemModelo04 
(
   iID           smallint primary key identity(1,1), 
   Codigo        varchar(20),
   Titulo        varchar(200),
   Descricao     varchar(5000),
   iIDFornecedor int ,
   Preco         smallmoney , 
   Comissao      numeric(5,2),
   ValorComissao as cast( (Preco * Comissao/100) as smallmoney) PERSISTED  , 
   Quantidade    smallint ,
   Frete         smallmoney 
) on DADOS4
go

insert into tItemModelo04 (Codigo,Titulo,Descricao, iIDFornecedor,Preco,Comissao,Quantidade,Frete)
values ('Cod1154','AAAAAAA','aaaa' ,RAND()*10000, 128.00 , 10.00, 100, 100) 

select * from tItemModelo04

sp_help tItemModelo04

-- ?? 
