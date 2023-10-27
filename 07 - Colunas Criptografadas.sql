/*
Colunas criptografadas.

-- Quando temos um dado sigiloso, podemos usar os recursos do SQL Server para realizar
   a criptografia de dados. 

-- O SQL Server disp�e de v�rios recursos para criptografia como tamb�m o n�vel onde voce
   deseja aplicar. Desde um banco de dados at� uma coluna espec�fica. 

-- No nosso contexto, isso pode ser um problema de desempenho das consultas. Vamos ver 
   um exemplo, usando um processo simples para criptografar dados. 

*/

USE DBDemoTable 
go 

declare @cFrase char(20) = 'P@ssw0rd'
declare @cTexto char(20) = 'Brasil'
declare @vDadosCifrado varbinary(8000)

set @vDadosCifrado = EncryptByPassPhrase(@cFrase, @cTexto)
select @vDadosCifrado

select cast(DecryptByPassPhrase(@cFrase ,  @vDadosCifrado)  as char(20))


go

drop table if exists tFuncionario
go

Create table tFuncionario 
( 
   id int not null,
   Nome varchar(50) not null,
   SalarioCifrado varbinary(36) 
) 
go

insert into tFuncionario 
(id, nome, SalarioCifrado) 
values 
(1,'Jose', EncryptByPassPhrase('P@ssw0rd', cast(7500.00 as varchar(7)) ))

select * from tFuncionario

select id, 
       nome,  
	   cast( cast(DecryptByPassPhrase('P@ssw0rd',  SalarioCifrado)  as varchar(7)) as smallmoney) as Salario 
  from tFuncionario

/*
-- Criptografia somente se realmente e totalmente necess�rio. 
-- A coluna para armazenar um dado criptografado � um VARBINARY e tem que ter 36 bytes de armazenamento.
-- Dica � criar uma tabela separada para criar a colunas (ou colunas) que ser�o criptogradas.
-- Claro que voce deve aumentar o controle de administra��o. Por exemplo, guardar em local
   seguro a senha 'P@ssw0rd'. 

*/

