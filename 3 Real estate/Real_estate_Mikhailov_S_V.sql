-- Раздел 1. Поиск аномалий.

-- 1. Изучаем таблицу advertisement.


-- Первоначальная оценка таблицы.
-- Всего строк 23650
SELECT
    *
    , count(id) over() AS num_row
FROM
    real_estate.advertisement a
LIMIT 100;

-- Находим строки с NULL значениями.
-- Всего пропусков 3180. Все находятся в days_exposition.
-- Видимо это непроданная недвижимость.
WITH null_t AS (
    SELECT
        *
    FROM
        real_estate.advertisement a
    WHERE
        id IS NULL
        OR a.first_day_exposition IS NULL
        OR a.days_exposition IS NULL
        OR a.last_price IS NULL
)
SELECT
    count(*) AS num_rows_with_null
    , count(*) - count(id) AS num_null_id
    , count(*) - count(first_day_exposition) AS num_null_first_day_exposition
    , count(*) - count(last_price) AS num_null_last_price
    , count(*) - count(days_exposition) AS num_null_days_exposition
FROM
    null_t;

-- Проверка на дубликаты.
-- Дубликатов не обнаружено.
SELECT
    id
    , a.first_day_exposition
    , a.days_exposition
    , a.last_price
    , count(*) AS num_duplicate
FROM
    real_estate.advertisement a
GROUP BY 
    id
    , a.first_day_exposition
    , a.days_exposition
    , a.last_price 
HAVING 
    count(*) > 1;

-- Смотрим минимальные и максимальные значения по столбцам.
-- Максимальный id - 23698, когда всего строк - 23650. Возможно записи удалялись.
-- min_last_price - 12190. Слишком низкая цена для жилья. Следующая минимальная стоимость - 430000. Скорее всего ошибка в данных.
-- min_last_price скорее всего 1219000
SELECT
    count(*) AS num_all_rows
    , min(id) AS min_id
    , max(id) AS max_id
    , min(first_day_exposition) AS min_first_day_exposition
    , max(first_day_exposition) AS max_first_day_exposition
    , min(days_exposition) AS min_days_exposition
    , max(days_exposition) AS max_days_exposition
    , min(last_price) AS min_last_price
    , max(last_price) AS max_last_price
FROM
    real_estate.advertisement;



-- 2. Изучаем таблицу city.



-- Первоначальная оценка таблицы.
-- Всего строк 305
SELECT
    *
    , count(city_id) over() AS num_row
FROM
    real_estate.city
LIMIT 100;

-- Находим строки с NULL значениями.
-- Все строки не имеют пустых значений.
SELECT
    *
FROM
    real_estate.city
WHERE city_id IS NULL OR city IS NULL;

-- Проверка на дубликаты.
-- Дубликатов не обнаружено.
SELECT 
    city_id
    , city
    , count(*) AS num_duplicate
FROM 
    real_estate.city
GROUP BY 
    city_id 
    , city
HAVING count(*) > 1;

-- Смотрим минимальные и максимальные значения по столбцам.
-- Проблем не выявлено.
SELECT
    count(*) AS num_all_rows
    , min(city_id) AS min_city_id
    , max(city_id) AS max_city_id
    , min(city) AS min_city
    , max(city) AS max_city
FROM
    real_estate.city;



-- 3. Изучаем таблицу type.



-- Первоначальная оценка таблицы.
-- Всего строк 10.
-- С данными полный порядок.
SELECT
    *
    , count(type_id) over() AS num_row
FROM
    real_estate.type
LIMIT 100;



-- 4. Изучаем таблицу flats.



-- Первоначальная оценка таблицы.
-- Всего записей 23650.
SELECT
    *
    , count(*) over() AS num_row
FROM
    real_estate.flats
LIMIT 100;

-- Находим все строки с NULL значениями.
-- Наблюдаются пропуски в следующих полях: 
-- ceiling_height - 9160, floors_total - 85, living_area - 1898
-- kitchen_area - 2269, balcony - 11513, airports_nearest - 5534
-- parks_around3000 - 5510, ponds_around3000 - 5510
WITH null_t AS (
    SELECT
        *
    FROM
        real_estate.flats
    WHERE
        id IS NULL
        OR city_id IS NULL
        OR type_id IS NULL
        OR total_area IS NULL
        OR rooms IS NULL
        OR ceiling_height IS NULL
        OR floors_total IS NULL
        OR living_area IS NULL
        OR floor IS NULL
        OR is_apartment IS NULL
        OR open_plan IS NULL
        OR kitchen_area IS NULL
        OR balcony IS NULL
        OR airports_nearest IS NULL
        OR parks_around3000 IS NULL
        OR ponds_around3000 IS NULL
)
SELECT 
    count(*) AS num_rows_with_null
    , count(*) - count(id) AS num_null_id
    , count(*) - count(city_id) AS num_null_city_id
    , count(*) - count(type_id) AS num_null_type_id
    , count(*) - count(total_area) AS num_null_total_area
    , count(*) - count(rooms) AS num_null_rooms
    , count(*) - count(ceiling_height) AS num_null_ceiling_height
    , count(*) - count(floors_total) AS num_null_floors_total
    , count(*) - count(living_area) AS num_null_living_area
    , count(*) - count(floor) AS num_null_floor
    , count(*) - count(is_apartment) AS num_null_is_apartment
    , count(*) - count(open_plan) AS num_null_open_plan
    , count(*) - count(kitchen_area) AS num_null_kitchen_area
    , count(*) - count(balcony) AS num_null_balcony
    , count(*) - count(airports_nearest) AS num_null_airports_nearest
    , count(*) - count(parks_around3000) AS num_null_parks_around3000
    , count(*) - count(ponds_around3000) AS num_null_ponds_around3000
FROM 
    null_t;

-- Поиск дубликатов.
-- Дубликатов не обнаружено.
SELECT 
    *
    , count(*) AS num_duplicate
FROM 
    real_estate.flats
GROUP BY
    id
    , city_id
    , type_id
    , total_area
    , rooms
    , ceiling_height
    , floors_total
    , living_area
    , floor
    , is_apartment
    , open_plan
    , kitchen_area
    , balcony
    , airports_nearest
    , parks_around3000
    , ponds_around3000
HAVING
    count(*) > 1;
    
-- Смотрим минимальные и максимальные значения по столбцам.
-- min_rooms = 0, max_rooms = 19, min_ceiling_height = 1,
-- max_ceiling_height = 100, min_living_area = 2, min_airports_nearest = 0
SELECT 
    min(total_area) AS min_total_area
    , max(total_area) AS max_total_area
    , min(rooms) AS min_rooms
    , max(rooms) AS max_rooms
    , min(ceiling_height) AS min_ceiling_height
    , max(ceiling_height) AS max_ceiling_height
    , min(floors_total) AS min_floors_total
    , max(floors_total) AS max_floors_total
    , min(living_area) AS min_living_area
    , max(living_area) AS max_living_area
    , min(floor) AS min_floor
    , max(floor) AS max_floor
    , min(kitchen_area) AS min_kitchen_area
    , max(kitchen_area) AS max_kitchen_area
    , min(balcony) AS min_balcony
    , max(balcony) AS max_balcony
    , min(airports_nearest) AS min_airports_nearest
    , max(airports_nearest) AS max_airports_nearest
    , min(parks_around3000) AS min_parks_around3000
    , max(parks_around3000) AS max_parks_around3000
    , min(ponds_around3000) AS min_ponds_around3000
    , max(ponds_around3000) AS max_ponds_around3000
FROM 
    real_estate.flats;

-- Теперь внимательнее рассматриваем крайние значения у некоторых подозрительных полей.
-- Большая площадь квартиры, но малая жилая площадь.

SELECT
    total_area
    , living_area
    , ROUND(living_area::numeric * 100 / total_area::numeric, 0) AS percent
FROM real_estate.flats
ORDER BY 
    living_area / total_area
LIMIT 50;

-- airports_nearest = 0 - расстояние до аэропорта равно 0.
-- Тут явно ошибка, потому что минимальное расстояние 6450.
-- либо недвижимость располагается в аэропорте.
SELECT *
FROM real_estate.flats
ORDER BY airports_nearest asc
LIMIT 10;


-- Раздел 2. Исследовательский анализ

-- Изучаем распределение объявлений по типу населенного пункта.
-- Самое большое количество объявлений с городским типом населенного пункта.
SELECT 
    t.TYPE
    , count(*) AS num_flats_per_type
FROM 
    real_estate.flats f
JOIN 
    real_estate.city AS c
        USING(city_id)
JOIN 
    real_estate.TYPE AS t
        USING(type_id)
GROUP BY
    t.TYPE
ORDER BY 
    num_flats_per_type DESC;

-- Рассчитываем основные статистики по полю с временем активности объявления.
-- Находим MIN, MAX, AVG, MEDIAN.
SELECT 
    min(a.days_exposition) AS min_days_exposition
    , max(a.days_exposition) AS max_days_exposition
    , ROUND(avg(a.days_exposition)) AS avg_days_exposition
    , PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY a.days_exposition) AS median_days_exposition
FROM 
    real_estate.advertisement a ;

-- Рассчитываем долю снятых с продаж объявлений.
-- В датасете имеем 86.55 % проданной недвижимости.
SELECT 
    ROUND(
        count(days_exposition)::NUMERIC * 100
        / count(*)
    , 2) AS ratio_sold_flats
    ,count(days_exposition)
    , count(*)
FROM 
    real_estate.advertisement a;

-- Считаем долю объявлений о продаже квартир в СПб относительно данных всего датасета (СПб + Лен. обл.)
SELECT 
    c.city
    , count(f.id) AS num_flats
    , count(f.id) * 100 / SUM(count(f.id)) OVER() AS ratio_flats_spb
FROM 
    real_estate.flats AS f
JOIN real_estate.TYPE AS t
        USING(type_id)
JOIN real_estate.city AS c
        USING(city_id)
GROUP BY
    c.city
ORDER BY
    num_flats desc;

-- Рассчитываем стоимость квадратного метра
WITH price_flats_per_metre AS (
    SELECT
        a.last_price::numeric / f.total_area AS price_flats_per_metre
    FROM
        real_estate.flats AS f
    JOIN 
        real_estate.advertisement AS a
            USING(id)
)
SELECT 
    min(price_flats_per_metre) AS min_price_per_metre
    , max(price_flats_per_metre) AS max_price_per_metre
    , avg(price_flats_per_metre) AS avg_price_per_metre
    , percentile_cont(0.5) WITHIN GROUP (ORDER BY price_flats_per_metre) AS median_price_per_metre
FROM 
    price_flats_per_metre;

-- Рассчет статистических показателей (MIN, MAX, AVG, MEDIAN, PERС99) по полям:
-- общая площадь недвижимости, количество комнат, балконов,
-- высота потолков, этаж.

-- Общая площадь недвижимости
SELECT 
    min(total_area) AS min_total_area
    , max(total_area) AS max_total_area
    , avg(total_area) AS avg_total_area
    , PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_area) AS median_total_area
    , PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY total_area) AS perc99_total_area
    , PERCENTILE_CONT(0.01) WITHIN GROUP (ORDER BY total_area) AS perc01_total_area
FROM 
    real_estate.flats;

-- Количество комнат
SELECT 
    min(rooms) AS min_rooms
    , max(rooms) AS max_rooms
    , avg(rooms) AS avg_rooms
    , PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY rooms) AS median_rooms
    , PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY rooms) AS perc99_rooms
    , PERCENTILE_CONT(0.01) WITHIN GROUP (ORDER BY rooms) AS perc01_rooms
FROM 
    real_estate.flats;

-- Количество балконов
SELECT 
    min(balcony) AS min_balcony
    , max(balcony) AS max_balcony
    , avg(balcony) AS avg_balcony
    , PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY balcony) AS median_balcony
    , PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY balcony) AS perc99_balcony
    , PERCENTILE_CONT(0.01) WITHIN GROUP (ORDER BY balcony) AS perc01_balcony
FROM 
    real_estate.flats;

-- Высота потолков
SELECT 
    min(ceiling_height) AS min_ceiling_height
    , max(ceiling_height) AS max_ceiling_height
    , avg(ceiling_height) AS avg_ceiling_height
    , PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY ceiling_height) AS median_ceiling_height
    , PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY ceiling_height) AS perc99_ceiling_height
    , PERCENTILE_CONT(0.01) WITHIN GROUP (ORDER BY ceiling_height) AS perc01_ceiling_height
FROM 
    real_estate.flats;

-- Этаж проживания
SELECT 
    min(floor) AS min_floor
    , max(floor) AS max_floor
    , avg(floor) AS avg_floor
    , PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY floor) AS median_floor
    , PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY floor) AS perc99_floor
    , PERCENTILE_CONT(0.01) WITHIN GROUP (ORDER BY floor) AS perc01_floor
FROM 
    real_estate.flats;



-- Раздел 3. Решаем ad hoc задачи.

-- Задача 1. Время активности объявлений



-- Определим аномальные значения (выбросы) по значению перцентилей.
WITH limits AS (
    SELECT
         PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY total_area) AS total_area_limit
        , PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY rooms) AS rooms_limit
        , PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY balcony) AS balcony_limit
        , PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY ceiling_height) AS ceiling_height_limit_h
        , PERCENTILE_DISC(0.01) WITHIN GROUP (ORDER BY ceiling_height) AS ceiling_height_limit_l
    FROM 
        real_estate.flats 
),
-- Найдём id объявлений, которые не содержат выбросы.
filtered_id AS (
    SELECT
        id
    FROM
        real_estate.flats  
    JOIN
        real_estate.advertisement using(id)
    WHERE 
        total_area < (SELECT total_area_limit FROM limits)
        AND (rooms < (SELECT rooms_limit FROM limits) OR rooms IS NULL)
        AND (balcony < (SELECT balcony_limit FROM limits) OR balcony IS NULL)
        AND ((ceiling_height < (SELECT ceiling_height_limit_h FROM limits)
            AND ceiling_height > (SELECT ceiling_height_limit_l FROM limits)) OR ceiling_height IS NULL)
),
-- Объединим таблицы с flats и advertisement
f_a_main AS (
    SELECT
            *
            , a.last_price / f.total_area AS price_per_metre -- Стоимость квадратного метра
    FROM
        -- Фильтруем данные таблицы flats от аномальных значений.
        -- Так же фильтруем данные по типу недвижимости, оставляем только город.
        -- Создаем поле для группировки по принадлежности к СПб или к Лен. обл.
        (
            SELECT
                *
                -- Создаем дополнительное поле с группировкой населенных пунктов по принадлежности к СПб или к Лен. обл.
                , CASE
                    WHEN city_id = (SELECT city_id FROM real_estate.city WHERE city = 'Санкт-Петербург') THEN 'Санкт-Петербург'
                    ELSE 'Ленинградская область'
                END AS subjects 
            FROM
                real_estate.flats 
            JOIN 
                real_estate.TYPE AS t using(type_id)
            WHERE 
                id IN (SELECT * FROM filtered_id)
                AND t.TYPE = 'город'
        ) AS f
    JOIN
        -- Присоединяем таблицу с разбитым по группам временем объявления и ценой продажи недвижимости
        (
            SELECT
                id
                , last_price
                -- Разбили длительность нахождения объявления на сайте по группам
                , CASE 
                    WHEN days_exposition <= 30 THEN '(1) Месяц'
                    WHEN days_exposition <= 30 * 3 THEN '(2) Квартал'
                    WHEN days_exposition <= 30 * 6 THEN '(3) Полгода'
                    WHEN days_exposition > 30 * 6  THEN '(4) Более полугода'
                    ELSE 'Не проданные'
                END AS group_advertisement
            FROM 
                real_estate.advertisement
        ) AS a USING(id)
),
-- Рассчитываем количество объявлений в каждой группе и их долю относительно рассматриваемого субъекта,
-- сгрупированных по сроку продажи недвижимости и по принадлежности к СПб или Лен.обл.
-- Считаем основные статистики недвижимости,
-- сгрупированной по сроку продажи недвижимости и по принадлежности к СПб или Лен.обл.
main_metrics AS (
    SELECT
        subjects
        , group_advertisement
        , count(id) AS num_advertisement                                                            -- Количество объявлений
        , ROUND(
            count(id)::NUMERIC * 100 / SUM(count(id)) OVER(PARTITION BY subjects)
            , 1) AS ratio_advertisement                                                             -- Доля объявлений относительно всех объявлений субъекта
        , percentile_disc(0.50) WITHIN GROUP(ORDER BY last_price) AS median_last_price              -- Медианная стоимость недвижимости
        , ROUND(
            percentile_disc(0.50) WITHIN GROUP(ORDER BY price_per_metre)::NUMERIC
            , -3) AS median_price_per_metre                                                         -- Медианная стоимость квадратного метра
        , percentile_disc(0.01) WITHIN GROUP(ORDER BY last_price) AS perc01_last_price              -- Перцентиль 1% стоимости недвижимости
        , percentile_disc(0.99) WITHIN GROUP(ORDER BY last_price) AS perc99_last_price              -- Перцентиль 99% стоимости недвижимости
        , percentile_disc(0.5) WITHIN GROUP (ORDER BY total_area) AS median_total_area              -- Медианная площадь недвижимости
        , ROUND(avg(kitchen_area)::NUMERIC, 1) AS avg_kitchen_area                                  -- Средняя площадь кухни
        , ROUND(avg(ceiling_height)::NUMERIC, 2) AS avg_ceiling_height                              -- Средняя высота потолка     
        , percentile_disc(0.5) WITHIN GROUP(ORDER BY floors_total) AS median_floors_total           -- Среднее количество этажей в доме
        , percentile_disc(0.5) WITHIN GROUP(ORDER BY floor) AS median_floor                         -- Средний этаж нахождения недвижимости
        , percentile_disc(0.5) WITHIN GROUP(ORDER BY rooms) AS median_rooms                         -- Среднее количество комнат
        , percentile_disc(0.5) WITHIN GROUP(ORDER BY balcony) AS median_balcony                     -- Среднее количество балконов
    FROM
        f_a_main
    GROUP BY 
        subjects   
        , group_advertisement
)
SELECT 
    * 
FROM
    main_metrics 
ORDER BY 
    subjects DESC,
    group_advertisement;
-- Рассчитываем усредненные статистики по регионам, чтобы ответить,
-- как недвижимость в одном регионе отличается от другой
SELECT
    subjects
    , count(id) AS num_advertisement                                                            -- Количество объявлений
    , percentile_disc(0.50) WITHIN GROUP(ORDER BY last_price) AS median_last_price              -- Медианная стоимость недвижимости
    , ROUND(
        percentile_disc(0.50) WITHIN GROUP(ORDER BY price_per_metre)::NUMERIC
        , -3) AS median_price_per_metre                                                         -- Медианная стоимость квадратного метра
    , percentile_disc(0.5) WITHIN GROUP (ORDER BY total_area) AS median_total_area              -- Медианная площадь недвижимости
    , ROUND(avg(kitchen_area)::NUMERIC, 1) AS avg_kitchen_area                                  -- Средняя площадь кухни
    , ROUND(avg(ceiling_height)::NUMERIC, 2) AS avg_ceiling_height                              -- Средняя высота потолка     
    , percentile_disc(0.5) WITHIN GROUP(ORDER BY floors_total) AS median_floors_total           -- Среднее количество этажей в доме
    , percentile_disc(0.5) WITHIN GROUP(ORDER BY floor) AS median_floor                         -- Средний этаж нахождения недвижимости
    , percentile_disc(0.5) WITHIN GROUP(ORDER BY rooms) AS median_rooms                         -- Среднее количество комнат
    , percentile_disc(0.5) WITHIN GROUP(ORDER BY balcony) AS median_balcony                     -- Среднее количество балконов
FROM
    f_a_main
GROUP BY 
    subjects   
ORDER BY 
    subjects DESC;

    
    
-- Задача 2. Сезонность объявлений

    
    
-- Определим аномальные значения (выбросы) по значению перцентилей.
WITH limits AS (
    SELECT
         PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY total_area) AS total_area_limit
        , PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY rooms) AS rooms_limit
        , PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY balcony) AS balcony_limit
        , PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY ceiling_height) AS ceiling_height_limit_h
        , PERCENTILE_DISC(0.01) WITHIN GROUP (ORDER BY ceiling_height) AS ceiling_height_limit_l
    FROM 
        real_estate.flats 
),
-- Найдём id объявлений, которые не содержат выбросы.
-- отфильтруем объявления, оставив только данные с целыми годами.
filtered_id AS (
    SELECT
        id
    FROM
        real_estate.flats  
    JOIN
        real_estate.advertisement using(id)
    WHERE 
        total_area < (SELECT total_area_limit FROM limits)
        AND (rooms < (SELECT rooms_limit FROM limits) OR rooms IS NULL)
        AND (balcony < (SELECT balcony_limit FROM limits) OR balcony IS NULL)
        AND ((ceiling_height < (SELECT ceiling_height_limit_h FROM limits)
            AND ceiling_height > (SELECT ceiling_height_limit_l FROM limits)) OR ceiling_height IS NULL)
        AND EXTRACT(YEAR FROM first_day_exposition) BETWEEN 2015 AND 2018
),
-- Посчитаем количество опубликованных объявлений по месяцам
pub_flats_per_month AS (
    SELECT
        EXTRACT(MONTH FROM a.first_day_exposition) AS month
        , COUNT(*) AS num_ads_per_month
    FROM 
        real_estate.advertisement a
    JOIN 
        real_estate.flats f USING(id)
    JOIN 
        real_estate.type  t ON f.type_id = t.type_id
    WHERE 
        a.id IN (SELECT id FROM filtered_id)
        AND t.type = 'город'
    GROUP BY 
        EXTRACT(MONTH FROM a.first_day_exposition)
),
-- Посчитаем количество проданной недвижимости по месяцам
sales_flats_per_month AS (
    SELECT
        EXTRACT(
            MONTH
            FROM a.first_day_exposition + a.days_exposition * INTERVAL '1 day'
        ) AS month
        , COUNT(*) AS num_purchase_per_month
    FROM 
        real_estate.advertisement a
    JOIN 
        real_estate.flats f USING(id)
    JOIN 
        real_estate.type  t ON f.type_id = t.type_id
    WHERE 
        a.id IN (SELECT id FROM filtered_id)
        AND t.type = 'город'
        AND a.days_exposition IS NOT NULL
    GROUP BY 
        EXTRACT(
            MONTH
            FROM a.first_day_exposition + a.days_exposition * INTERVAL '1 day'
        )
),
--- Выведем id населенных пунктов, удовлетворяющих фильтрации, и для каждого найдем
-- площадь, цену и цену за метр квадратный.
area_per_flats AS (
    SELECT
            *
            , a.last_price / f.total_area AS price_per_metre -- Стоимость квадратного метра
            , EXTRACT(MONTH FROM a.first_day_exposition) AS month
    FROM
        -- Фильтруем данные таблицы flats от аномальных значений.
        -- Так же фильтруем данные по типу недвижимости, оставляем только город.
        (
            SELECT
                id
                , total_area
            FROM
                real_estate.flats 
            JOIN 
                real_estate.TYPE AS t using(type_id)
            WHERE 
                id IN (SELECT * FROM filtered_id)
                AND t.TYPE = 'город'
        ) AS f
    JOIN
        (
            SELECT
                id
                , last_price
                , first_day_exposition
            FROM 
                real_estate.advertisement
        ) AS a USING(id)
),
-- Рассчитываем медианную площадь квартир и стоимости квадратного метра по месяцам.
area_per_month AS (
    SELECT 
        MONTH
        , CASE
            WHEN MONTH = 1 THEN 'январь'
            WHEN MONTH = 2 THEN 'февраль'
            WHEN MONTH = 3 THEN 'март'
            WHEN MONTH = 4 THEN 'апрель'
            WHEN MONTH = 5 THEN 'май'
            WHEN MONTH = 6 THEN 'июнь'
            WHEN MONTH = 7 THEN 'июль'
            WHEN MONTH = 8 THEN 'август'
            WHEN MONTH = 9 THEN 'сентябрь'
            WHEN MONTH = 10 THEN 'октябрь'
            WHEN MONTH = 11 THEN 'ноябрь'
            WHEN MONTH = 12 THEN 'декабрь' 
        END AS name_month   
        , percentile_disc(0.5) WITHIN GROUP (ORDER BY total_area) AS median_total_area                      
        , ROUND(
            percentile_disc(0.5) WITHIN GROUP (ORDER BY price_per_metre)::NUMERIC,
            -3) AS median_price_per_metre                                                                              
    FROM 
        area_per_flats
    GROUP BY 
        MONTH
        , CASE
            WHEN MONTH = 1 THEN 'январь'
            WHEN MONTH = 2 THEN 'февраль'
            WHEN MONTH = 3 THEN 'март'
            WHEN MONTH = 4 THEN 'апрель'
            WHEN MONTH = 5 THEN 'май'
            WHEN MONTH = 6 THEN 'июнь'
            WHEN MONTH = 7 THEN 'июль'
            WHEN MONTH = 8 THEN 'август'
            WHEN MONTH = 9 THEN 'сентябрь'
            WHEN MONTH = 10 THEN 'октябрь'
            WHEN MONTH = 11 THEN 'ноябрь'
            WHEN MONTH = 12 THEN 'декабрь' 
        END
)
-- Собираем общую таблицу, в которой будет количество новых объявлений и продаж по месяцам,
-- медианная площадь квартир и стоимости квадратного метра.
-- Находим ранги по полям с количеством новых объявлений и продаж и высчитываем суммарный ранг
-- для нахождения месяцев, в которых увеличенный спрос на продажу и покупку недвижимости.
SELECT
    MONTH
    , name_month
    , num_ads_per_month                                                                         -- Количество новых объявлений по месяцам
    , ROUND(
        num_ads_per_month::NUMERIC * 100 / SUM(num_ads_per_month) OVER()
        , 1) AS ratio_num_ads_per_month                                                         -- Доля количества новых объявлений по месяцам относительно всех объявлений
    , num_purchase_per_month                                                                    -- Количество продаж по месяцам
    , ROUND(
        num_purchase_per_month::NUMERIC * 100 / SUM(num_purchase_per_month) OVER()
        , 1) AS ratio_num_purchase_per_month                                                    -- Доля количества продаж по месяцам относительно всех объявлений
    , median_total_area                                                                         -- Медианная площадь недвижимости
    , median_price_per_metre                                                                    -- Медианная стоимость одного метра кв.
    , RANK() OVER(ORDER BY num_ads_per_month DESC)
        + RANK() OVER(ORDER BY num_purchase_per_month DESC) AS total_rank_month_ads_purchase    -- Суммарный ранг по продажам и новым объявлениям
FROM
    area_per_month
JOIN 
    pub_flats_per_month using(month)
JOIN 
    sales_flats_per_month using(month)
ORDER BY 
    num_ads_per_month desc;



-- Задача 3. Анализ рынка недвижимости Ленобласти

    
    
 -- Определим аномальные значения (выбросы) по значению перцентилей.
WITH limits AS (
    SELECT
         PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY total_area) AS total_area_limit
        , PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY rooms) AS rooms_limit
        , PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY balcony) AS balcony_limit
        , PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY ceiling_height) AS ceiling_height_limit_h
        , PERCENTILE_DISC(0.01) WITHIN GROUP (ORDER BY ceiling_height) AS ceiling_height_limit_l
    FROM 
        real_estate.flats 
),
-- Найдём id объявлений, которые не содержат выбросы.
filtered_id AS (
    SELECT
        id
    FROM
        real_estate.flats  
    JOIN
        real_estate.advertisement using(id)
    WHERE 
        total_area < (SELECT total_area_limit FROM limits)
        AND (rooms < (SELECT rooms_limit FROM limits) OR rooms IS NULL)
        AND (balcony < (SELECT balcony_limit FROM limits) OR balcony IS NULL)
        AND ((ceiling_height < (SELECT ceiling_height_limit_h FROM limits)
            AND ceiling_height > (SELECT ceiling_height_limit_l FROM limits)) OR ceiling_height IS NULL)
),
-- В данных наблюдаются города с разными типами населенного пункта.
-- Для каждого города произведем группировку по типу.
city_type AS (
    SELECT
        city_id
        , city
        , string_agg(TYPE, ', ') AS type
    FROM (
        SELECT
            city_id
            , city
            , type
        FROM real_estate.flats 
        JOIN real_estate.city using(city_id)
        JOIN real_estate.TYPE using(type_id)
        GROUP BY city_id, city, type) t1
    GROUP BY city_id, city
),
-- Объединим таблицы с flats и advertisement
f_a_main AS (
    SELECT
            *
            , a.last_price / f.total_area AS price_per_metre -- Стоимость квадратного метра
    FROM
        -- Фильтруем данные таблицы flats от аномальных значений.
        -- Так же фильтруем данные по принадлежности к региону, оставляем только Ленинградскую обл.
        (
            SELECT
                id
                , total_area
                , floors_total
                , floor
                , rooms
                , balcony
                , TYPE
                , city
            FROM
                real_estate.flats 
            JOIN 
                city_type using(city_id)
            WHERE 
                id IN (SELECT * FROM filtered_id)
                AND city != 'Санкт-Петербург'
        ) AS f
    JOIN
        (
            SELECT
                id
                , first_day_exposition
                , days_exposition
                , last_price
            FROM 
                real_estate.advertisement
        ) AS a USING(id)
),
-- Группируем данные по населенным пунктам и рассчитываем статистики.
-- Для ответа на интересующие нас вопросы рассмотрим топ-15 населенных пунктов
-- по количеству выставленных объявлений.
-- В выборке как раз оказываются населенные пункты, имеющие количество продаж и выставленных объявлений
-- более 100, что позволит нам не совмеваться в случайности полученных результатов по каждому населенному пункту
-- и позволит получить более усредненную картину с меньшим влиянием пограничных значений.
metrics_top15 AS (
    SELECT
        city
        , type
        , count(id) AS num_advertisement                                                            -- Количество объявлений
        , ROUND(
            count(id)::NUMERIC * 100 / SUM(count(id)) over()
            , 1) AS ratio_num_advertisement                                                         -- Доля новых объявлений относительно всех объявлений
        , count(days_exposition) AS num_purchase                                                    -- Количество продаж недвижимости
        , ROUND(
            count(days_exposition)::NUMERIC * 100 / SUM(count(days_exposition)) over()
            , 1) AS ratio_num_purchase                                                              -- Доля проданной недвижимости относительно всех объявлений
        , ROUND(
            count(days_exposition)::NUMERIC * 100 / count(id)
            , 1) AS ratio_purchase_to_ads                                                           -- Доля проданной недвижимости относительно выставленной на продажу
        , percentile_disc(0.5) WITHIN GROUP (ORDER BY total_area) AS median_total_area              -- Медианная площадь недвижимости
        , ROUND(
            percentile_disc(0.50) WITHIN GROUP(ORDER BY price_per_metre)::NUMERIC
            , -3) AS median_price_per_metre                                                         -- Медианная стоимость квадратного метра
        , percentile_disc(0.5) WITHIN GROUP (ORDER BY days_exposition) AS median_days_exposition    -- Медианное время продажи недвижимости в днях
        , percentile_disc(0.5) WITHIN GROUP (ORDER BY floors_total) AS median_floors_total          -- Медианное количество этажей в доме
        , percentile_disc(0.5) WITHIN GROUP (ORDER BY floor) AS median_floor                        -- Средний этаж нахождения недвижимости 
        , percentile_disc(0.5) WITHIN GROUP (ORDER BY rooms) AS median_rooms                        -- Среднее количество комнат
        , percentile_disc(0.5) WITHIN GROUP (ORDER BY balcony) AS median_balcony                    -- Среднее количество балконов
    FROM
        f_a_main
    GROUP BY 
        city
        , TYPE
    ORDER BY
        num_advertisement DESC 
    LIMIT 15       
),
-- Согласно информации Мурино и Кудрово - это города.
-- Изменим для них тип населенного пункта
metrics_top15_edit AS (
SELECT 
    city
    , CASE 
        WHEN city = 'Мурино' THEN 'город'
        WHEN city = 'Кудрово' THEN 'город'
        ELSE type
    END AS TYPE
    , num_advertisement 
    , ratio_num_advertisement   
    , num_purchase  
    , ratio_num_purchase    
    , ratio_purchase_to_ads  
    , median_total_area  
    , median_price_per_metre    
    , median_days_exposition 
    , median_floors_total  
    , median_floor  
    , median_rooms 
    , median_balcony  
FROM 
    metrics_top15
),
-- Найдем усредненную медиану площади жилья и стоимости метра квадратного
-- по каждому типу населенного пункта среди исследуемых населенных пунктов.
avg_area_top15 AS (
    SELECT
        TYPE
        , ROUND(avg(median_total_area)::NUMERIC, 1) AS avg_median_total_area 
        , ROUND(avg(median_price_per_metre)::NUMERIC) AS avg_price_per_metre  
    FROM 
        metrics_top15_edit
    GROUP BY
        type
),
-- Найдем среднее время продолжительности публикации по типу населенного пункта
-- среди выделенных населенных пунктов.
avg_de_top15 AS (
    SELECT
        TYPE
        , ROUND(avg(median_days_exposition)::NUMERIC) AS avg_de_per_type
    FROM 
        metrics_top15_edit
    GROUP BY
        type
)
SELECT * FROM metrics_top15_edit;
--SELECT * FROM avg_area_top15;
--SELECT * FROM avg_de_top15;







