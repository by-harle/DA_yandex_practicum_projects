/* Проект «Секреты Тёмнолесья»
 * Цель проекта: изучить влияние характеристик игроков и их игровых персонажей 
 * на покупку внутриигровой валюты «райские лепестки», а также оценить 
 * активность игроков при совершении внутриигровых покупок
 * 
 * Автор: Михайлов Станислав Владимирович
 * Дата: 21.05.2025
*/

-- Часть 1. Исследовательский анализ данных
-- Задача 1. Исследование доли платящих игроков



-- 1.1. Доля платящих пользователей по всем данным:

-- Расчитываем общее количество игроков, количество платящих игроков
-- и определяем долю платящих игроков относительно всех.
SELECT
	COUNT(id) AS total_users
	,COUNT(id) FILTER (WHERE payer = 1) AS num_payer
	,ROUND(COUNT(id) FILTER (WHERE payer = 1) / COUNT(id)::NUMERIC, 3) AS ratio_payer
FROM 
	fantasy.users;



-- 1.2. Доля платящих пользователей в разрезе расы персонажа:

-- Рассчитываем количество платящих игроков по каждой расе
-- и находим их долю относительно количества игроков в расе.
SELECT 
	r.race
	,COUNT(id) AS num_users_per_race
	,COUNT(id) FILTER (WHERE payer = 1) AS num_payer_per_race
	,ROUND(COUNT(id) FILTER (WHERE payer = 1) / COUNT(id)::NUMERIC, 3) AS ratio_payer_per_race
FROM 
	fantasy.users AS u
JOIN 
	fantasy.race AS r USING(race_id)
GROUP BY 
	r.race
ORDER BY 
	ratio_payer_per_race DESC;



-- Задача 2. Исследование внутриигровых покупок
-- 2.1. Статистические показатели по полю amount:

-- Производим расчет общего количества покупок и их суммарной стоимости.
-- Находим минимальное и максимальное значение среди всех покупок.
-- Определяем среднее, медиану и стандартное отклонение по всем покупкам.
-- Тоже самое делаем по всем покупкам, с предварительно отфильтрованными покупками с 0 стоимостью и объединим результаты.
SELECT
	'С учетом нулевых покупок'
	,COUNT(transaction_id) AS num_purchases 	
	,SUM(amount) AS total_amount
	,MIN(amount) AS min_amount
	,MAX(amount) AS max_amount
	,ROUND(AVG(amount)::NUMERIC, 1) AS avg_amount
	,ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY amount)::NUMERIC, 1) AS median_amount
	,ROUND(stddev(amount)::NUMERIC, 1) AS sd_amount
FROM 
	fantasy.events
UNION
SELECT
	'Без учета нулевых покупок'
	,COUNT(transaction_id) AS num_purchases 	
	,SUM(amount) AS total_amount
	,MIN(amount) AS min_amount
	,MAX(amount) AS max_amount
	,ROUND(AVG(amount)::NUMERIC, 1) AS avg_amount
	,ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY amount)::NUMERIC, 1) AS median_amount
	,ROUND(stddev(amount)::NUMERIC, 1) AS sd_amount
FROM 
	fantasy.events
WHERE 
	amount != 0;



-- 2.2: Аномальные нулевые покупки:

-- Рассчитываем общее количество покупок.
WITH
total_transactions AS (
	SELECT
		COUNT(*) AS total_transactions
	FROM
		fantasy.events
)
-- Рассчитываем долю количества покупок с 0 стоимостью относительно всего количества покупок.
SELECT 
	COUNT(transaction_id) AS num_zero_amount
	,ROUND(COUNT(transaction_id) / (SELECT total_transactions FROM total_transactions)::NUMERIC, 5) AS ration_zero_amount
FROM 
	fantasy.events
WHERE amount = 0;



-- 2.3: Сравнительный анализ активности платящих и неплатящих игроков:

-- Находим количество и суммарную стоимость покупок для каждого игрока среди игроков, совершивших покупки,
-- без учета покупок с 0 стоимостью.
WITH
users_purchases AS (
	SELECT
		u.id
		,u.payer
		,COUNT(*) AS num_purchases_per_user
		,SUM(e.amount) AS total_amount_per_user
	FROM 
		fantasy.users AS u
	JOIN (			-- Присоединяем таблицу events, оставляя только игроков, совершивших покупки, без учета покупок с 0 стоимостью
		SELECT 		
			id
			,amount
		FROM
			fantasy.events
		WHERE 
			amount > 0
	) AS e USING(id)
	GROUP BY 
		u.id
		,u.payer
)
-- Рассчитываем для групп игроков платящих и неплатящих общее количество игроков, 
-- среднее количество покупок и среднюю суммарную стоимость покупок по каждому игроку для каждой группы.
SELECT 
	payer
	,CASE
		WHEN payer = 0 THEN 'Не платящий'
		WHEN payer = 1 THEN 'Платящий'
	END AS name_payer
	,COUNT(id) AS num_users
	,ROUND(AVG(num_purchases_per_user)::NUMERIC, 1) AS avg_num_purchase_per_users
	,ROUND(AVG(total_amount_per_user)::NUMERIC, 1) AS avg_amount_per_users
FROM users_purchases
GROUP BY 
	payer;

-- Расчитаем количество игроков, совершающих внутриигровые покупки,
-- и найдем их долю от общего количества игроков, исключая игроков, совершивших покупки за 0 стоимость.

-- Расчитываем общее количество игроков, исключая совершивших покупки за нулевую стоимость.
WITH
total_users_without_zero AS (
SELECT
	COUNT(id) AS total_users_without_zero
FROM
	fantasy.users
WHERE id NOT IN 
	(SELECT id FROM fantasy.events WHERE amount = 0)
)
-- Расчитаем количество игроков, совершающих внутриигровые покупки,
-- и найдем их долю от общего количества игроков, исключая игроков, совершивших покупки за 0 стоимость.
SELECT 
	COUNT(DISTINCT id) AS num_users_using_store
	,ROUND(COUNT(DISTINCT id)::numeric / (SELECT total_users_without_zero FROM total_users_without_zero), 3) AS ratio_users_using_store
FROM 
	fantasy.events
WHERE amount > 0;


-- 2.4: Популярные эпические предметы:

-- Рассчитываем общее количество покупок предметов, без учета покупок с 0 стоимостью.
WITH
total_transactions AS (
	SELECT
		COUNT(*) AS total_transactions
	FROM 	
		fantasy.events
	WHERE amount > 0
),
-- Рассчитываем количество игроков платящих и не платящих среди игроков, использующих внутриигровой магазин
-- без учета игроков, совершающих нулевые покупки.
total_users_per_payer AS (
	SELECT 
		payer
		,COUNT(*) AS total_users_per_payer
	FROM 
		fantasy.users
	WHERE id IN
		(SELECT id FROM fantasy.events WHERE amount > 0)
	GROUP BY 
		payer
),
-- Рассчитываем количество всех игроков, использующих внутриигровой магазин.
total_users AS (
	SELECT 	
		SUM(total_users_per_payer) AS total_users
	FROM 
		total_users_per_payer
),
-- Фильтруем таблицу events от покупок с нулевой стоимостью
-- и присоединяем к ней поле users.payer 
events_filtered AS (
	SELECT
		e.id
		,e.item_code
		,e.amount
		,u.payer
	FROM (       
		SELECT
			id
			,amount
			,item_code
		FROM
			fantasy.events
		WHERE 
			amount > 0
	) AS e
	JOIN fantasy.users AS u USING(id)
)
-- Для каждого предмета находим общее количество продаж и долю продаж по каждому предмету
-- относительно всех продаж без учета продаж предметов за нулевую стоимость.
-- Так же определяем долю уникальных игроков относительно всех игроков, которые купили предмет хотя бы 1 раз без учета покупок за 0 стоимость
-- долю уникальных платящих игроков, которые хотя бы 1 раз покупали предмет, среди всех уникальных платящих игроков.
SELECT 
	i.item_code
	,i.game_items
	,COUNT(*) AS num_purchases_per_item -- Общее количество покупок на предмет
	,ROUND(COUNT(*) / (SELECT total_transactions FROM total_transactions)::NUMERIC, 6) AS ratio_purchases_per_item	 -- Доля покупок предмета относительно всех покупок
	,ROUND(COUNT(DISTINCT e.id)  -- Доля уникальных игроков среди игроков, использующих внутриигровой магазин, которые хотя бы 1 раз покупали предмет
		/ (SELECT total_users FROM total_users)::NUMERIC, 3) AS ratio_unique_players_per_item
	,ROUND(COUNT(DISTINCT e.id) FILTER(WHERE payer = 1) -- Доля уникальных платящих игроков среди игроков, использующих внутриигровой магазин, которые хотя бы 1 раз покупали предмет, среди всех уникальных платящих игроков.
		/ (SELECT total_users_per_payer FROM total_users_per_payer WHERE payer = 1)::NUMERIC, 3) AS ratio_unique_payer_players_per_item
FROM 
	fantasy.items AS i
LEFT JOIN 
	events_filtered AS e USING(item_code)
GROUP BY 
	i.item_code
	,i.game_items
ORDER BY
	ratio_unique_players_per_item DESC;



-- Часть 2. Решение ad hoc-задач
-- Задача 1. Зависимость активности игроков от расы персонажа:

-- Рассчитываем общее количество игроков и количество платящих игроков в разрезе каждой расы.
WITH
total_users AS (
	SELECT 
		race_id
		,COUNT(*) AS total_users_all
	FROM 
		fantasy.users
	GROUP BY 
		race_id
),
-- Рассчитываем количество игроков, которые совершают внутриигровые покупки в разрезе расы.
-- Рассчитаем количество платящих игроков среди игроков, которые совершают покупки, в разрезе каждой расы.
-- При расчете, не учитываем покупки с 0 стоимостью.
race_num_users_events_payer AS (	
	SELECT
		u.race_id
		,COUNT(id) AS total_users_events
		,COUNT(id) FILTER (WHERE payer = 1) AS total_users_payer
		,AVG(payer) AS ratio_payers_per_users_events
	FROM
		fantasy.users AS u
	WHERE id IN
		(SELECT id FROM fantasy.events WHERE amount > 0)
	GROUP BY u.race_id
),
-- Производим расчет доли игроков, совершающих внутриигровые покупки, относительно всех игроков в разрезе расы
-- Так же рассчитываем долю платящих игроков относительно игроков, которые совершили покупки в разрезе расы.
race_stat AS (
SELECT
	r.race_id
	,total_users_events
	,total_users_all
	,total_users_payer
	,ratio_payers_per_users_events
	,total_users_events / total_users_all::NUMERIC AS ratio_users_events
FROM 
	race_num_users_events_payer AS r
JOIN total_users AS tu USING(race_id)
),
-- Рассчитываем количество покупок и сумму покупок по каждому игроку в сегменте игроков, производивших покупки
-- во внутриигровом магазине, исключая покупки с 0 стоимостью.
users_purchases AS (
	SELECT
		u.race_id
		,u.id
		,COUNT(*) FILTER (WHERE e.amount != 0) AS num_purchases_per_user -- Убираем из расчета строки, стоимость покупок в которых равна 0
		,COALESCE(SUM(e.amount), 0) AS total_amount_per_user -- Укажем для пользователей, которые не совершали покупок, что стоимость их покупки равна 0.
	FROM 
		fantasy.users AS u
	JOIN 
		fantasy.events AS e USING(id)
	GROUP BY 
		u.race_id
		,u.id
),
-- Найдем среднее количество покупок, среднюю суммарную стоимость всех покупок на одного игрока
-- и среднюю стоимость одной покупки на 1 игрока в разрезе каждой расы.
purchases_stats AS (
	SELECT
		race_id
		,AVG(num_purchases_per_user) AS avg_num_purchases_per_users
		,AVG(total_amount_per_user) AS avg_amount_per_users	
		,AVG(total_amount_per_user)::NUMERIC / AVG(num_purchases_per_user) AS avg_costs_purchase_per_user
	FROM
		users_purchases	
	GROUP BY race_id
)
-- Собираем информацию по расам всю вместе
SELECT
	rs.race_id
	,r.race
	,rs.total_users_all                                                            -- Общее количество игроков
	,rs.total_users_events                                                         -- Количество игроков, соверщающие внутриигровые покупки
	,ROUND(rs.ratio_users_events, 3) AS ratio_users_events                         -- Доля игроков, совершивших внутриигровые покупки, от общего количества игроков в расе
	,ROUND(rs.ratio_payers_per_users_events, 3) AS ratio_payers_per_users_events   -- Доля платящих игроков от количества игроков, совершивших внутриигровые покупки
	,ROUND(ps.avg_num_purchases_per_users, 1) AS avg_num_purchases_per_users       -- Cреднее количество покупок на одного игрока среди игроков, совершивших покупки
	,ROUND(ps.avg_amount_per_users::NUMERIC, 1) AS avg_amount_per_users            -- Cредняя стоимость одной покупки на одного игрока среди игроков, совершивших покупки
	,ROUND(ps.avg_costs_purchase_per_user, 1) AS avg_costs_purchase_per_user       -- Cредняя суммарная стоимость всех покупок на одного игрока среди игроков, совершивших покупки
FROM
	race_stat AS rs
JOIN purchases_stats AS ps USING(race_id)
JOIN fantasy.race AS r USING(race_id)
ORDER BY 
	total_users_all DESC;



-- Задача 2: Частота покупок
-- Напишите ваш запрос здесь

-- Соединяем всех пользователей с их транзакциями и преобразовываем поля "date" и "time" в одно поле типа TIMESTAMP.
WITH
user_transactions AS (
	SELECT
		u.id
		,date::date + time::time AS time_transaction
	FROM 
		fantasy.users AS u
	LEFT JOIN ( -- Удаляем из таблицы events аномальные строки, имеющие строимость покупки равную 0.
		SELECT
			id
			,date
			,time
		FROM 
			fantasy.events
		WHERE amount != 0
	) AS e USING(id)
),
-- Рассчитываем временной интервал между покупками для каждого игрока
user_transactions_interval AS (
	SELECT
		id
		,time_transaction
		,LEAD(time_transaction::date) OVER(PARTITION BY id ORDER BY time_transaction)
			- time_transaction::date AS interval_purchase
	FROM
		user_transactions
),
-- Рассчитываем суммарное количество покупок и средний временной интервал между покупками для каждого игрока
user_purchase_stats AS (
SELECT
	id
	,COUNT(id) AS num_user_purchase
	,AVG(interval_purchase) AS interval_user_purchase
FROM 
	user_transactions_interval
GROUP BY 
	id
),
-- Разделим пользователей на 3 группы по интервалу времени между покупками.
-- Расчет будет производить на пользователях, которые сделали 25 или более покупок.
user_purchase_group AS (
SELECT 
	id
	,num_user_purchase
	,interval_user_purchase
	,NTILE(3) OVER(ORDER BY interval_user_purchase) AS group_users_interval
FROM 
	user_purchase_stats
WHERE
	num_user_purchase >= 25
),
-- Даем наименование каждой группе
-- Добавляем поле с индентификатором платежности пользователя.
user_group AS (
	SELECT
		upg.id
		,u.payer 
		,upg.num_user_purchase
		,upg.interval_user_purchase
		,CASE
			WHEN upg.group_users_interval = 1 THEN 'высокая частота'
			WHEN upg.group_users_interval = 2 THEN 'умеренная частота'
			WHEN upg.group_users_interval = 3 THEN 'низкая частота'
		END AS frequency_purchase
	FROM 
		user_purchase_group AS upg		
	JOIN fantasy.users AS u USING(id)
),
-- Рассчитываем по группам количество игроков, совершивших покупки,
-- среднее количество покупок на одного игрока,
-- среднее количество дней между покупками на одного игрока.
stat_users_per_group AS (
SELECT
	frequency_purchase
	,COUNT(id) AS total_num_users_per_group
	,AVG(num_user_purchase) AS avg_num_purchase_per_user
	,AVG(interval_user_purchase) AS avg_interval_purchase_per_user
FROM
	user_group
GROUP BY
	frequency_purchase
),
-- Рассчитываем по группам количество платящих игроков
payer_users_per_group AS (
	SELECT
		frequency_purchase
		,COUNT(id) AS payer_users_per_group
	FROM
		user_group
	WHERE 
		payer = 1
	GROUP BY
		frequency_purchase
)
-- Создаем основную таблицу по группам пользователей и считаем долю
-- платящих игроков от общего количества игроков
SELECT
	s.frequency_purchase
	,s.total_num_users_per_group
	,p.payer_users_per_group
	,ROUND(p.payer_users_per_group / s.total_num_users_per_group::NUMERIC, 3) AS ratio_payer_users
	,ROUND(s.avg_num_purchase_per_user, 1) AS avg_num_purchase_per_user
	,ROUND(s.avg_interval_purchase_per_user, 0) AS avg_interval_purchase_per_user
FROM 
	stat_users_per_group AS s
JOIN 
	payer_users_per_group AS p USING(frequency_purchase)

















