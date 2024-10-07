-- Para Executar
select fn_GeraMultas ('123AC',110.00)

select * from ex_multa


-- Dicas da Função - Questão A
create or replace function fn_GeraMultas (pCNH char(5), pVelApurada DECIMAL(5,2)) 
returns varchar(50) as
$$
declare
-- Coloque aqui as variáveis
_VelCalculada Decimal(5,2):= 0;
_TotalPontos  integer := 0;
_nome varchar(20);
_motorista record;
_msg varchar(50);

begin -- Escreva aqui
-- 1º o cálculo da velocidade calculada
_VelCalculada :=  pVelApurada * 90/100;


-- 3º busque o nome do motorista –
select nome into _nome from ex_motorista where cnh = pcnh;
if not found then
  raise exception 'Motorista não existe!!!!';
end if;  
--select * into _motorista from ex_motorista where cnh = pcnh;
--raise notice 'Motorista % tem CNH:%', _motorista.nome, _motorista.cnh;


-- 2º teste os intervalos para ver se o motorista tem multa e se tiver --    insere na tabela ex_multa
if _VelCalculada >= 80.01 and _VelCalculada <= 110 then
    insert into ex_multa 
    (cnh, velocidadeapurada, velocidadecalculada, pontos, valor)
    values
   (pCNH,  pVelApurada, _VelCalculada, 20, 120.00 );
end if;

if _VelCalculada >= 110.01 and _VelCalculada <= 140 then
    insert into ex_multa 
    (cnh, velocidadeapurada, velocidadecalculada, pontos, valor)
    values
   (pCNH,  pVelApurada, _VelCalculada, 40, 350.00 );
end if;

if _VelCalculada > 140 then
    insert into ex_multa 
    (cnh, velocidadeapurada, velocidadecalculada, pontos, valor)
    values
   (pCNH,  pVelApurada, _VelCalculada, 60, 680.00 );
end if;


-- 4º some o total de pontos do motorista
select sum(pontos) into _TotalPontos 
from ex_multa
where cnh = pCNH;

-- 5º retorne a mensagem
_msg:= 'O motorista ' || _nome || ' soma ' || _TotalPontos || ' pontos em multas';
return _msg;
end;
$$ language 'plpgsql';











select FN_TRATAR_ERRO('123AB')





CREATE OR REPLACE FUNCTION FN_TRATAR_ERRO(_CNH CHAR(5)) RETURNS VOID AS
$$
<<BLOCO_A>>
DECLARE
_MULTA RECORD;
_MOTORISTA RECORD;
BEGIN
SELECT * INTO _MOTORISTA FROM EX_MOTORISTA WHERE cnh = _CNH;
IF NOT FOUND THEN
    RAISE EXCEPTION 'Motorista % não existe', _CNH;
end if;	
BEGIN
SELECT * into STRICT _MULTA FROM EX_MULTA WHERE CNH = _CNH;
EXCEPTION
WHEN NO_DATA_FOUND THEN
 RAISE NOTICE 'MOTORISTA % NÃO ENCONTRADO EM MULTAS', BLOCO_A._MOTORISTA.NOME;
WHEN TOO_MANY_ROWS THEN
 RAISE NOTICE '%', SQLSTATE ;
 RAISE NOTICE '%', SQLERRM;
 RAISE EXCEPTION 'MOTORISTA % POSSUI VARIAS MULTAS', BLOCO_A._MOTORISTA.NOME;
WHEN OTHERS THEN
RAISE NOTICE '%', SQLSTATE ;
RAISE NOTICE '%', SQLERRM;
END;
RETURN;
END;
$$ LANGUAGE Plpgsql

select count(*) from ex_motorista
select * from ex_motorista limit 10


insert into ex_multa (cnh,velocidadeApurada,velocidadeCalculada,pontos,valor)
values ('123AC', 90, 100, 20, 120 );

select 100  * 90/100;
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
 
Populando um motorista, por exemplo:
insert into ex_motorista values ('123AB', 'Carlo');







