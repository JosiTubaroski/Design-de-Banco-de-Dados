/*
Introdu��o

- Uma das t�cnicas mais eficientes para organizar dados para uma pesquisa r�pida 
  � a utiliza��o de ordena��o utilizando uma estrutura de dados conhecida como �rvore bin�ria.

  - Essa estrutura � capaz de organizar os dados a partir de n� raiz com um �nico valor 
    (ou uma �nica chave) e com dois ponteiros refereciando os pr�ximos n�s.
  - Existe somente um n� raiz (root) onde come�a a pesquisa.
  - Os n�s intermedi�rios onde se navega pela �rvore
  - N�s folhas (leaf) onde eles n�o possuem refer�ncia para outro n�s. 

  Ref.: https://pt.wikipedia.org/wiki/%C3%81rvore_bin%C3%A1ria

- Devido a algumas dificuldades em incluir, alterar ou excluir dados dentro dessa
  �rvore, foi criando um estrutura semelhantes que � conhecidadae como b-tree.

  Ref.: https://pt.wikipedia.org/wiki/%C3%81rvore_B
  
- A diferen�a entre a �rvore bin�ria e a b-tree, � que a primeira � restrita a uma �nica
  chave de pesquisa em um determinado n� e tem dois ponteiros no m�ximo saindo de um n�.
  A segunda j� permite um n�mero maior de chaves em um n� e o n�mero m�ximo de ponteiros
  saindo d� ser� de total de chaves mais 1.

- E temos uma outra varia��o da b-tree que � conhecido como b-tree+ (b-tree plus) que 
  entre suas caracter�sticas, a mais significativa � o encadeamento entre as n�s folhas.

  Ref.: https://pt.wikipedia.org/wiki/%C3%81rvore_B%2B



*/

use DBDemo
go


Create or Alter View vRandData 
as
with cteRand as (
   select 1 as number , 0 as ancor
   union all
   select number+1 as number , 1 as ancor
   from cteRand
   where number < 1000
)
select number from cteRand 

select * from vRandData
option (maxrecursion 1000)


/*
Gerando 101 n�meros ale�torios e sem ordem de apresenta��o.
Encontre o n�mero 250
*/

select top 101 * 
  from vRandData
 order by newid()
option (maxrecursion 1000)



/*
Gerando 101 n�meros ale�torios, ordenado de forma crescente.
Encontre o n�mero 600
*/

select * from (
select top 101 * 
  from vRandData
 order by newid()
) as a order by 1
option (maxrecursion 1000)



/*
Gerando 11 n�meros ale�torios, ordenado de forma crescente em uma B+Tree 
Encontre o n�mero ???
*/

drop table if exists tNumber 
go

Create Table tNumber (id tinyint identity(1,1), Number smallint)
go

insert into tNumber (Number) 
select number from (
select top 11 * 
  from vRandData
 order by newid()
 ) as a order by number
option (maxrecursion 1000)

select * from tNumber order by number


select count(1) as TotalChaves from tNumber

-- Encontrar o n�mero que representa a metada da lista

select * from tNumber where id = CEILING( 11/2.0)

select * from tNumber 


/*
Simulador de Arvore B+Tree 
Ref.: https://www.cs.usfca.edu/~galles/visualization/BPlusTree.html
*/





 
 
