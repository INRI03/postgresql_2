--=============== МОДУЛЬ 6. POSTGRESQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Напишите SQL-запрос, который выводит всю информацию о фильмах 
--со специальным атрибутом "Behind the Scenes".

--explain analyze --Execution Time: 0.546 ms
select film_id, title, special_features
from film
where 'Behind the Scenes' = any(special_features)



--ЗАДАНИЕ №2
--Напишите еще 2 варианта поиска фильмов с атрибутом "Behind the Scenes",
--используя другие функции или операторы языка SQL для поиска значения в массиве.

--explain analyze  --Execution Time: 0.619 ms
select film_id, title, special_features
from film
where special_features @> array['Behind the Scenes']


--explain analyze  --Execution Time: 0.651 ms
select film_id, title, special_features
from film
where array_position(special_features, 'Behind the Scenes') is not null



--ЗАДАНИЕ №3
--Для каждого покупателя посчитайте сколько он брал в аренду фильмов 
--со специальным атрибутом "Behind the Scenes.

--Обязательное условие для выполнения задания: используйте запрос из задания 1, 
--помещенный в CTE. CTE необходимо использовать для решения задания.

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


--ЗАДАНИЕ №4
--Для каждого покупателя посчитайте сколько он брал в аренду фильмов
-- со специальным атрибутом "Behind the Scenes".

--Обязательное условие для выполнения задания: используйте запрос из задания 1,
--помещенный в подзапрос, который необходимо использовать для решения задания.

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

	
--ЗАДАНИЕ №5
--Создайте материализованное представление с запросом из предыдущего задания
--и напишите запрос для обновления материализованного представления

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



--ЗАДАНИЕ №6
--С помощью explain analyze проведите анализ скорости выполнения запросов
-- из предыдущих заданий и ответьте на вопросы:

--1. Каким оператором или функцией языка SQL, используемых при выполнении домашнего задания, 
--   поиск значения в массиве происходит быстрее
--2. какой вариант вычислений работает быстрее: 
--   с использованием CTE или с использованием подзапроса

1. Поиск элемента в строке по оператору any происходит примерно с такой же скоростью, что и поиск по элементам массива с помощью функции "@>" или
поиск по позиции массива "array_position". Время каждый раз варьируется, но среднее соотношение примерно одинаковое - 0,5-0,7 мс. Если бы база данных была раз в 1000 больше, тогда можно
было б сравнить объективнее. А так отрабатывает слишком быстро и сравнить не получается.

2. В моем случае оба варианта отработали с одинаковой скоростью 18-19 мс, потому что логика одна и та же, но в разных вариациях. Поэтому однозначного ответа, какой вариант
быстрее, нет.
