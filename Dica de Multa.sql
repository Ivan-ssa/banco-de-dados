-- Para Executar
select fn_GeraMultas ('123AB',130.00)

-- Dicas da Função - Questão A
create or replace function fn_GeraMultas
(pCNH char(5), pVelApurada DECIMAL(5,2)) 
returns varchar(50) as
$$
declare
-- Coloque aqui as variáveis
_VelCalculada Decimal(5,2):= 0;
_TotalPontos  integer := 0;

begin -- Escreva aqui
-- 1º o cálculo da velocidade calculada
_VelCalculada :=  pVelApurada * 90/100;

-- 2º teste os intervalos para ver se o motorista tem multa e se tiver --    insere na tabela ex_multa
if _VelCalculada >= 110.01 and _VelCalculada <= 140 then
    insert into ex_multa 
    (cnh, velocidadeapurada, velocidadecalculada, pontos, valor)
    values
   (pCNH,  pVelApurada, _VelCalculada, 40, 350.00 );
end if;

-- 3º busque o nome do motorista –

-- 4º some o total de pontos do motorista
select sum(pontos) into _TotalPontos 
from ex_multa
where cnh = pCNH;

-- 5º retorne a mensagem
end;
$$ language 'plpgsql';


