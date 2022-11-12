--=============== ������ 6. POSTGRESQL =======================================
--= �������, ��� ���������� ���������� ������ ���������� � ������� ����� PUBLIC===========
SET search_path TO public;

--======== �������� ����� ==============

--������� �1
--�������� SQL-������, ������� ������� ��� ���������� � ������� 
--�� ����������� ��������� "Behind the Scenes".

--explain analyze --Execution Time: 0.546 ms
select film_id, title, special_features
from film
where 'Behind the Scenes' = any(special_features)



--������� �2
--�������� ��� 2 �������� ������ ������� � ��������� "Behind the Scenes",
--��������� ������ ������� ��� ��������� ����� SQL ��� ������ �������� � �������.

--explain analyze  --Execution Time: 0.619 ms
select film_id, title, special_features
from film
where special_features @> array['Behind the Scenes']


--explain analyze  --Execution Time: 0.651 ms
select film_id, title, special_features
from film
where array_position(special_features, 'Behind the Scenes') is not null



--������� �3
--��� ������� ���������� ���������� ������� �� ���� � ������ ������� 
--�� ����������� ��������� "Behind the Scenes.

--������������ ������� ��� ���������� �������: ����������� ������ �� ������� 1, 
--���������� � CTE. CTE ���������� ������������ ��� ������� �������.

--explain analyze  --Execution Time: 18.403 ms
with cte as
	(select film_id, title, special_features
	from film
	where 'Behind the Scenes' = any(special_features))
select c.customer_id, count(rental_id)
	from rental r 
	join customer c on c.customer_id = r.customer_id
	join inventory i on r.inventory_id = i.inventory_id
	join cte on cte.film_id = i.film_id
group by c.customer_id
order by c.customer_id


--������� �4
--��� ������� ���������� ���������� ������� �� ���� � ������ �������
-- �� ����������� ��������� "Behind the Scenes".

--������������ ������� ��� ���������� �������: ����������� ������ �� ������� 1,
--���������� � ���������, ������� ���������� ������������ ��� ������� �������.

--explain analyze  --Execution Time: 18.738 ms
select c.customer_id, count(rental_id)
from rental r 
	join customer c on c.customer_id = r.customer_id
	join inventory i on r.inventory_id = i.inventory_id
	join
		(select film_id, title, special_features
		from film
		where 'Behind the Scenes' = any(special_features)) t on t.film_id = i.film_id
group by c.customer_id
order by c.customer_id

	
--������� �5
--�������� ����������������� ������������� � �������� �� ����������� �������
--� �������� ������ ��� ���������� ������������������ �������������

create materialized view view1 as
	select c.customer_id, count(rental_id)
	from rental r 
	join customer c on c.customer_id = r.customer_id
	join inventory i on r.inventory_id = i.inventory_id
	join
		(select film_id, title, special_features
		from film
		where special_features::text like '%Behind the Scenes%') t on t.film_id = i.film_id
	group by 1
with no data

refresh materialized view view1



--������� �6
--� ������� explain analyze ��������� ������ �������� ���������� ��������
-- �� ���������� ������� � �������� �� �������:

--1. ����� ���������� ��� �������� ����� SQL, ������������ ��� ���������� ��������� �������, 
--   ����� �������� � ������� ���������� �������
--2. ����� ������� ���������� �������� �������: 
--   � �������������� CTE ��� � �������������� ����������

1. ����� �������� � ������ �� ��������� any ���������� �������� � ����� �� ���������, ��� � ����� �� ��������� ������� � ������� ������� "@>" ���
����� �� ������� ������� "array_position". ����� ������ ��� �����������, �� ������� ����������� �������� ���������� - 0,5-0,7 ��. ���� �� ���� ������ ���� ��� � 1000 ������, ����� �����
���� � �������� �����������. � ��� ������������ ������� ������ � �������� �� ����������.

2. � ���� ������ ��� �������� ���������� � ���������� ��������� 18-19 ��, ������ ��� ������ ���� � �� ��, �� � ������ ���������. ������� ������������ ������, ����� �������
�������, ���.



--======== �������������� ����� ==============

--������� �1
--���������� ��� ������� � ����� ������ �� ����� ���������

--������� �2
--��������� ������� ������� �������� ��� ������� ����������
--�������� � ����� ������ ������� ����� ����������.





--������� �3
--��� ������� �������� ���������� � �������� ����� SQL-�������� ��������� ������������� ����������:
-- 1. ����, � ������� ���������� ������ ����� ������� (���� � ������� ���-�����-����)
-- 2. ���������� ������� ������ � ������ � ���� ����
-- 3. ����, � ������� ������� ������� �� ���������� ����� (���� � ������� ���-�����-����)
-- 4. ����� ������� � ���� ����




