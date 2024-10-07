CREATE OR REPLACE FUNCTION limparMovimento() RETURNS
void AS '
-- Remove dados 
DELETE FROM movimento;

' LANGUAGE SQL;

drop function  limparMovimento() 

• Para executar a função
select * from movimento;

BEGIN TRANSACTION

COMMIT
ROLLBACK TRANSACTION

-- eXECUTAR A FUNÇÃO
SELECT limparMovimento();

SELECT * FROM  limparMovimento();


select * from movimento;





CREATE or replace FUNCTION inserirMovimento() RETURNS
void AS $$
insert into movimento values('ped1',1,20,53.00);
insert into movimento values('ped1',3,15,29.70);
insert into movimento values('ped1',4,10,15.40);
insert into movimento values('ped2',4,12,18.48);
insert into movimento values('ped2',3,10,19.80);
insert into movimento values('ped3',1,15,39.75);
$$ LANGUAGE SQL; 

SELECT * FROM  limparMovimento();
select inserirMovimento() 

                                     $1       $2       $3
CREATE FUNCTION atualizarMovimento(char(10),integer, integer) 
returns integer AS
$$
UPDATE movimento set qtde = $3 where
nro_ped = $1 and cod_prod = $2;
select 1;
$$
LANGUAGE SQL;

select * from movimento

select  atualizarMovimento('ped1', 1, 200)

CREATE FUNCTION atualizarMovimento(integer,integer) 
returns integer AS
$$
UPDATE movimento set qtde = 20 where
nro_ped = cast($1 as char(10)) and cod_prod = $2;
select 1;
$$
LANGUAGE SQL;

select  atualizarMovimento('ped1', 1)

drop function atualizarMovimento(integer,integer)



CREATE OR REPLACE FUNCTION
atualizarPrecoProduto(integer, decimal(5,2)) returns
setof produto AS $$
UPDATE produto set preco = preco * (1.00 + $2/100.00)
where cod_prod = $1;
select * from produto where cod_prod = $1;
$$
LANGUAGE SQL;


CREATE OR REPLACE FUNCTION atualizarPrecoProduto(codigo_produto integer, novo_preco numeric)
RETURNS SETOF produto AS $$
BEGIN
    -- Atualiza o preço do produto
    UPDATE produto 
    SET preco = novo_preco
    WHERE cod_prod = codigo_produto;

    -- Retorna o produto atualizado
    RETURN QUERY SELECT * FROM produto WHERE cod_prod = codigo_produto;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM atualizarPrecoProduto(1, 3.5271500000000002);



select 100 * 1.05
select * from produto
select * from atualizarPrecoProduto(1,10)
select atualizarPrecoProduto(1,10)



CREATE or REPLACE FUNCTION fn_exemplo_a() RETURNS integer AS $$
<<bloco_externo>> -- bloco nomeado
DECLARE
_qtd integer := 30;
_sal decimal(5,2);
BEGIN
RAISE NOTICE 'Quantidade aqui vale: %', _qtd; -- 30
_qtd := 50;
--***************
-- subbloco
--***************
DECLARE
_qtd integer := 80;
BEGIN
RAISE NOTICE 'Quantidade (interno) aqui vale: %', _qtd; -- 80
RAISE NOTICE 'Quantidade (externo) aqui vale: %', bloco_externo._qtd; -- 50
END;
_sal:= 100;
RAISE NOTICE 
'Quantidade (externo) aqui vale: % e seu salário é %', 
_qtd, _sal; -- 50
RETURN _qtd;
END;
$$ LANGUAGE plpgsql;


select fn_exemplo_a()





Exercicio:
MOnte uma função chamada de ListaProduto no qual possua 
um parametro de entrada para receber o código do produto
e retorne os valores de cod_prod+nome+preco

Formato de saída: "'1';'OMO';'3.5271500000000002'"  x 1.20793



create or replace function ListaProduto (codigo_produto integer) 
returns text as $$
declare
	resultado text;	
begin
	 SELECT 
        cod_prod::text || '; ' || nome || '; ' || preco::text
    INTO resultado
    FROM produto
    WHERE cod_prod = codigo_produto;

    
    RETURN resultado;
end;
$$ language plpgsql;

select ListaProduto(1)