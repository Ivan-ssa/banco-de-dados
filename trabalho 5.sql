---- codigos testes 
select * from ex_motorista  -- resultset ex_motorista
select * from ex_multa --resultset multa

	
	delete from ex_motorista
where cnh = '321AB';
DELETE FROM ex_multa
WHERE cnh = '321AB';
--------------------




-- buscando resultado no banco	

select FN_TRATAR_ERRO('789AB') -- teste do tratamento do erro ( Função tratar erro )
select GerarMultas ('123AB',80.00) -- testando se o motorista esta dentro da velociade e gera menssagem motorista LEGAL !!!! ( função gera multas)
SELECT * FROM AtualizarTotalMultas(); -- aqui busca o valor total de multas por motorista (função atualiza multa)
select GerarMultas ('789AB',160.00)  -- incerindo motorista que não existe ( função gera multas)

select consultaPontos('123AB') -- consul a guantidade de pontos por consulta de cnh 



----------------------------------------------------	
--Populando um motorista, por exemplo:
insert into ex_motorista values ('123AB', 'Carlo')
insert into ex_motorista values ('321AB', 'flora')
insert into ex_motorista values ('586' , 'Pedro')
	
	-- Gerando as multas multa apartir da cnh 
select GerarMultas ('123AB',80.00)
select GerarMultas ('123AB',120.00)
select GerarMultas ('123AB',160.00)
	
select GerarMultas ('321AB',80.00)
select GerarMultas ('321AB',120.00)
select GerarMultas ('321AB',160.00)


	
	
--Criando as tabelas do trabalho
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
-------------------------------------------------------------------------


 
--------------------------------------------------------------------------------------
                 ----------------------------------------------------------
-- função que gera as multas
CREATE OR REPLACE FUNCTION GerarMultas(pCNH CHAR(5), pVelocidadeApurada DECIMAL(5,2))
RETURNS VARCHAR(50) AS
$$
DECLARE
    _VelocidadeCalculada DECIMAL(5,2) := 0;
    _TotalPontos INTEGER := 0;
    _nome VARCHAR(20);
    _motorista RECORD;
    _mensagem VARCHAR(50);

BEGIN
    -- Cálculo da velocidade
    _VelocidadeCalculada := pVelocidadeApurada * 90 / 100;

    -- Verifica se o motorista existe
    PERFORM 1 FROM ex_motorista WHERE cnh = pCNH;
    IF NOT FOUND THEN
        -- Chama a função de tratamento de erro caso o motorista não seja encontrado
        PERFORM fn_tratar_erro(pCNH);
        RETURN 'Erro: Motorista não encontrado';
    END IF;

    -- Busca o nome do motorista
    SELECT nome INTO _nome FROM ex_motorista WHERE cnh = pCNH;

    -- Verifica se o motorista está dentro da velocidade permitida (até 80 km/h)
    IF _VelocidadeCalculada <= 80 THEN
        RETURN 'O motorista ' || _nome || ' é um motorista LEGAL !!!! Dentro da velocidade permitida.';
    END IF;

    -- 2º Verificação: inserção de multa para intervalos de velocidade
    IF _VelocidadeCalculada >= 80.01 AND _VelocidadeCalculada <= 110 THEN
        INSERT INTO ex_multa (cnh, velocidadeapurada, velocidadecalculada, pontos, valor)
        VALUES (pCNH, pVelocidadeApurada, _VelocidadeCalculada, 20, 120.00);
    END IF;

    IF _VelocidadeCalculada >= 110.01 AND _VelocidadeCalculada <= 140 THEN
        INSERT INTO ex_multa (cnh, velocidadeapurada, velocidadecalculada, pontos, valor)
        VALUES (pCNH, pVelocidadeApurada, _VelocidadeCalculada, 40, 350.00);
    END IF;

    IF _VelocidadeCalculada > 140 THEN
        INSERT INTO ex_multa (cnh, velocidadeapurada, velocidadecalculada, pontos, valor)
        VALUES (pCNH, pVelocidadeApurada, _VelocidadeCalculada, 60, 680.00);
    END IF;

    -- Soma o total de pontos do motorista
    SELECT SUM(pontos) INTO _TotalPontos 
    FROM ex_multa
    WHERE cnh = pCNH;

    -- Retorna a mensagem final
    _mensagem := 'O motorista ' || _nome || ' soma ' || _TotalPontos || ' pontos em multas';
    RETURN _mensagem;

END;
$$ LANGUAGE plpgsql;

-----------------------------------------------------------------------------------------
                       ----------------------------------------------------------


-- função atualizar total de multas parte 2

CREATE OR REPLACE FUNCTION AtualizarTotalMultas()
RETURNS TABLE(cnh CHAR(5), nome VARCHAR(20), totalMultas DECIMAL(10, 2)) AS
$$
BEGIN
    -- Atualiza o campo totalMultas de cada motorista
    UPDATE ex_motorista
    SET totalMultas = (
        SELECT COALESCE(SUM(ex_multa.valor), 0.00)
        FROM ex_multa
        WHERE ex_multa.cnh = ex_motorista.cnh);

    -- Retorna a tabela atualizada
    RETURN QUERY 
    SELECT ex_motorista.cnh, ex_motorista.nome, ex_motorista.totalMultas
    FROM ex_motorista;

END;
$$ LANGUAGE plpgsql;


--------------------------------------------------------------------------------------------
              ---------------------------------------------------------



----------------------------------------------------------------------------
----- função para tratar erro se não exixte motorista cadastrado -----


CREATE OR REPLACE FUNCTION FN_TRATAR_ERRO(_CNH CHAR(5)) RETURNS VOID AS
$$

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

-------------------------------------------------------------------------------
	--------------------------------------------------------------
	
---criando função para soma de pontos 








create or replace function consultaPontos (pCNH char(5))
returns varchar(50) as
$$
declare
-- Coloque aqui as variáveis

_TotalPontos  integer;
_nome varchar(20);
_motorista record;
_msg varchar(50);
begin -- Escreva aqui
-- 3º busque o nome do motorista –
select nome into _nome from ex_motorista where cnh = pcnh;
if not found then
  raise exception 'Motorista não existe!!!!';
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

SELECT consultaPontos('123AB');

--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
-----------------exercio 6------------------------------------------------------------

--- atualização 22 


