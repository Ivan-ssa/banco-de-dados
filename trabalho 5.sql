-- buscando resultado

select * from ex_motorista  -- resultset ex_motorista

--Populando um motorista, por exemplo:
insert into ex_motorista values ('123AB', 'Carlo')
insert into ex_motorista values ('321AB', 'flora')
--Para Executar função e gerar multas
	
	--ele gerar multa apartir da cnh 
select GerarMultas ('123AB',130.00)
select GerarMultas ('123AB',160.00)

--- meus testes 
select * from ex_motorista

select * from ex_multa -- mostra a tabela de multas 
---- mostra o total de multas por motoristas 


SELECT * FROM AtualizarTotalMultas();


--Criando as tabelas
create table ex_motorista
(cnh char(5) primary key,
nome varchar(20) not null,
totalMultas decimal(9,2) );
 
create table ex_multa
(id serial primary key,
cnh char(5) references ex_motorista(cnh) not null,
velocidadeApurada decimal(5,2) not null,
velocidadeCalculada decimal(5,2),
pontos integer not null,
valor decimal(9,2) not null);
 
--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
-- função que gera as multas
create or replace function GerarMultas (pCNH char(5),pVelocidadeApurada decimal(5,2))
returns varchar(50) as
$$
declare
-- variaveis declaradas 
_VelocidadeCalculada decimal (5,2):=0;
_TotalPontos integer :=0;
_nome varchar(20);
_motorista record;
_menssagem varchar(50);

begin -- inicio da logica
-- calculo da velocidade 

_VelocidadeCalculada := pVelocidadeApurada * 90/100; --

-- buscando o motorista 
select nome into _nome from ex_motorista where cnh = pCNH;
if not found then 
	raise exception 'Motorista não existe!!!';
end if;

-- 2º teste os intervalos para ver se o motorista tem multa e se tiver --    insere na tabela ex_multa

if _VelocidadeCalculada >= 80.01 and _VelocidadeCalculada <= 110 then -- teste de 80 a 100
 insert into ex_multa 
	
    (cnh, velocidadeapurada, velocidadecalculada, pontos, valor)
    values
   (pCNH,  pVelocidadeApurada, _VelocidadeCalculada, 20, 120.00 );
end if;

if _VelocidadeCalculada >= 110.01 and _VelocidadeCalculada <= 140 then -- teste 110 a 140
    insert into ex_multa 
    (cnh, velocidadeapurada, velocidadecalculada, pontos, valor)
    values
   (pCNH, pVelocidadeApurada, _VelocidadeCalculada, 40, 350.00 );
   
end if;

if _VelocidadeCalculada > 140 then -- teste maior que 140
    insert into ex_multa 
    (cnh, velocidadeapurada, velocidadecalculada, pontos, valor)
    values
   (pCNH,  pVelocidadeApurada, _VelocidadeCalculada, 60, 680.00 );
end if;

--soma o total de pontos do motorista
select sum(pontos) into _TotalPontos 
from ex_multa
where cnh = pCNH;

--- retorna a mensagem
_menssagem:= 'O motorista ' || _nome || ' soma ' || _TotalPontos || ' pontos em multas';
return _menssagem;
end;
$$ language 'plpgsql';
-----------------------------------
-----------------------------------------
-- função atualizar total de multas parte 2
CREATE OR REPLACE FUNCTION AtualizarTotalMultas()
RETURNS TABLE(cnh CHAR(5), nome VARCHAR(20), totalMultas DECIMAL(10, 2)) AS
$$
BEGIN
    RETURN QUERY 
    SELECT ex_motorista.cnh, ex_motorista.nome, COALESCE(ex_motorista.totalMultas, 0.00) AS totalMultas
    FROM ex_motorista; 
END;
$$ LANGUAGE plpgsql;




