1.Считаем, сколько компаний закрылось:

select count(c.id)
from company as c
where status='closed'
_______________________________________

2.Отобразим количество привлечённых средств для новостных компаний США. Использую данные из таблицы company. 
Отсортирую таблицу по убыванию значений в поле funding_total:

select c.funding_total
from company as c
where category_code='news' 
and country_code='USA'
order by funding_total desc
_______________________________________

3.Найдем общую сумму сделок по покупке одних компаний другими в долларах. 
Отберем сделки, которые осуществлялись только за наличные с 2011 по 2013 год включительно.

select sum(a.price_amount)
from acquisition as a
where term_code='cash'
and acquired_at between '2011-01-01' and '2013-12-31'
_______________________________________

4.Отобразим имя, фамилию и названия аккаунтов людей в твиттере, у которых названия аккаунтов начинаются на 'Silver'.

select p.first_name,
       p.last_name,
       p.twitter_username 
from people as p
where twitter_username like 'Silver%'
_______________________________________

5.Выведем на экран всю информацию о людях, у которых названия аккаунтов в твиттере содержат подстроку 'money', а фамилия начинается на 'K'.

select *
from people as p
where twitter_username like '%money%'
and last_name like 'K%'
_______________________________________

6. Для каждой страны отобразим общую сумму привлечённых инвестиций, которые получили компании, зарегистрированные в этой стране.
Страну, в которой зарегистрирована компания, можно определить по коду страны. Отсортируем данные по убыванию суммы.

select c.country_code,
       sum(c.funding_total) 
from company as c
group by c.country_code
order by sum(c.funding_total) desc
_______________________________________

7.Составляем таблицу, в которую войдёт дата проведения раунда, а также минимальное и максимальное значения суммы инвестиций, привлечённых в эту дату.
Оставим в итоговой таблице только те записи, в которых минимальное значение суммы инвестиций не равно нулю и не равно максимальному значению.

select fr.funded_at,
       min(fr.raised_amount),
       max(fr.raised_amount)
from funding_round as fr
group by fr.funded_at
having min(fr.raised_amount)!=0
and min(fr.raised_amount)!=max(fr.raised_amount)
_______________________________________

8.
Создаем поле с категориями:
Для фондов, которые инвестируют в 100 и более компаний, назначим категорию high_activity.
Для фондов, которые инвестируют в 20 и более компаний до 100, назначим категорию middle_activity.
Если количество инвестируемых компаний фонда не достигает 20, назначим категорию low_activity.
Отобразим все поля таблицы fund и новое поле с категориями.

select *,
       case
       when f.invested_companies>= 100 then 'high_activity'
       when f.invested_companies>= 20 and  f.invested_companies< 100 then 'middle_activity'
       else 'low_activity'
       end
from fund as f
_______________________________________

9.Для каждой из категорий, назначенных в предыдущем задании, посчитаем округлённое до ближайшего целого числа среднее количество 
инвестиционных раундов, в которых фонд принимал участие. 
Выведем на экран категории и среднее число инвестиционных раундов. Отсортируем таблицу по возрастанию среднего.

select case
           when invested_companies>=100 then 'high_activity'
           when invested_companies>=20 then 'middle_activity'
           else 'low_activity'
        end as activity,
       round(avg(investment_rounds)) 
from fund
group by activity
order by round(avg(investment_rounds));
_______________________________________

10.Проанализирую, в каких странах находятся фонды, которые чаще всего инвестируют в стартапы. 
Для каждой страны посчитае минимальное, максимальное и среднее число компаний, в которые инвестировали фонды этой страны, 
основанные с 2010 по 2012 год включительно. 
Исключим страны с фондами, у которых минимальное число компаний, получивших инвестиции, равно нулю. 
Выгрузим десять самых активных стран-инвесторов: отсортирую таблицу по среднему количеству компаний от большего к меньшему. 
Затем добавлю сортировку по коду страны в лексикографическом порядке.

select country_code,
       min(invested_companies),
       avg(invested_companies),
       max (invested_companies)
from fund
where extract (year from founded_at) between 2010 and 2012
group by country_code
having min(invested_companies)!=0
order by avg(invested_companies) desc,country_code
limit 10
_______________________________________

11.Отобразим имя и фамилию всех сотрудников стартапов. 
Добавим поле с названием учебного заведения, которое окончил сотрудник, если эта информация известна.

select p.first_name,
       p.last_name,
       instituition
from people as p
left outer join education as ed on p.id=ed.person_id
_______________________________________

12.Для каждой компании найдем количество учебных заведений, которые окончили её сотрудники. 
Выведем название компании и число уникальных названий учебных заведений. 
Составим топ-5 компаний по количеству университетов.

select c.name,
       count(distinct e.instituition)
from education as e 
right outer join people as p on e.person_id=p.id
join company as c on p.company_id=c.id
group by c.name
order by count(distinct e.instituition) desc
limit 5
_______________________________________

13.Составим список с уникальными названиями закрытых компаний, для которых первый раунд финансирования оказался последним.
with
a as (select distinct c.name as name,
      c.id as id
from company as c
where status = 'closed'),

b as (select distinct fr.company_id as bid
     from funding_round as fr
     where is_first_round=1 and
     is_last_round=1)
     
select distinct a.name
from a join b on a.id=b.bid
_______________________________________

14.Составим список уникальных номеров сотрудников, которые работают в компаниях, отобранных в предыдущем задании.

select distinct id
from people
where company_id in (with
a as (select distinct c.name as name,
      c.id as id
from company as c
where status = 'closed'),

b as (select distinct fr.company_id as bid
     from funding_round as fr
     where is_first_round=1 and
     is_last_round=1)
     
select distinct a.id
from a join b on a.id=b.bid)
_______________________________________

15.Составим таблицу, куда войдут уникальные пары с номерами сотрудников из предыдущей задачи и учебным заведением, которое окончил сотрудник.
select distinct p.id,
       e.instituition
from education as e
join people as p on e.person_id=p.id
where p.id in (select distinct id as p_id
from people
where company_id in (with
a as (select distinct c.name as name,
      c.id as id
from company as c
where status = 'closed'),

b as (select distinct fr.company_id as bid
     from funding_round as fr
     where is_first_round=1 and
     is_last_round=1)
     
select distinct a.id
from a join b on a.id=b.bid))
_______________________________________

16. Посчитаем количество учебных заведений для каждого сотрудника из предыдущего задания. 
При подсчёте учитем, что некоторые сотрудники могли окончить одно и то же заведение дважды.
select p.id,
       count(e.instituition)
from education as e
join people as p on e.person_id=p.id
where p.id in (select distinct id as p_id
from people
where company_id in (with
a as (select distinct c.name as name,
      c.id as id
from company as c
where status = 'closed'),

b as (select distinct fr.company_id as bid
     from funding_round as fr
     where is_first_round=1 and
     is_last_round=1)
     
select distinct a.id
from a join b on a.id=b.bid))
group by p.id
_______________________________________

7. Дополним предыдущий запрос и выведем среднее число учебных заведений (всех, не только уникальных), 
которые окончили сотрудники разных компаний. Нужно вывести только одну запись, группировка здесь не понадобится.
select avg(inst)
from (select p.id,
       count(e.instituition) as inst
from education as e
join people as p on e.person_id=p.id
where p.id in (select distinct id as p_id
from people
where company_id in (with
a as (select distinct c.name as name,
      c.id as id
from company as c
where status = 'closed'),

b as (select distinct fr.company_id as bid
     from funding_round as fr
     where is_first_round=1 and
     is_last_round=1)
     
select distinct a.id
from a join b on a.id=b.bid))
group by p.id) as count_inst
_______________________________________

18.Напишим похожий запрос: выведем среднее число учебных заведений (всех, не только уникальных), которые окончили сотрудники Facebook*.
*(сервис, запрещённый на территории РФ)

select avg(inst_count)
from (select p.id,
       count(e.instituition) as inst_count
from education as e
join people as p on p.id=e.person_id
where p.id in (select p.id
from people as p
inner join company as c on p.company_id=c.id
where c.name ='Facebook')
group by p.id) as p_id_count_ins_facebook
_______________________________________

19. Составим таблицу из полей:
name_of_fund — название фонда;
name_of_company — название компании;
amount — сумма инвестиций, которую привлекла компания в раунде.
В таблицу войдут данные о компаниях, в истории которых было больше шести важных этапов, а раунды финансирования проходили с 2012 по 2013 год включительно.

select f.name as name_of_fund,
        c.name as name_of_company,
        fr.raised_amount as amount
from company as c
inner join investment as i on c.id=i.company_id
inner join fund as f on i.fund_id=f.id
inner join funding_round as fr on i.funding_round_id=fr.id
where c.milestones > 6
and extract(year from fr.funded_at) between 2012 and 2013
_______________________________________

20. Выгрузим таблицу, в которой будут такие поля:
- название компании-покупателя;
- сумма сделки;
- название компании, которую купили;
- сумма инвестиций, вложенных в купленную компанию;
- доля, которая отображает, во сколько раз сумма покупки превысила сумму вложенных в компанию инвестиций, округлённая до ближайшего целого числа.
Не учитываем те сделки, в которых сумма покупки равна нулю. Если сумма инвестиций в компанию равна нулю, исключаем такую компанию из таблицы. 
Отсортируем таблицу по сумме сделки от большей к меньшей, а затем по названию купленной компании в лексикографическом порядке. 
Ограничим таблицу первыми десятью записями.

with
buyer as (select c.name as acquiring,
     a.price_amount  as price,
     a.id as key
from company as c
left join acquisition as a on a.acquiring_company_id=c.id
where a.price_amount>0),

sold as (select c.name as acquired,
         c.funding_total as investment,
         a.id as key
from acquisition as a
left join company as c on a.acquired_company_id=c.id
where c.funding_total>0)

select buyer.acquiring,
       buyer.price,
       sold.acquired,
       sold.investment,
       round(buyer.price/sold.investment) as uplift
from buyer
join sold  on buyer.key=sold.key
order by buyer.price desc
limit 10
_______________________________________

21. Выгрузим таблицу, в которую войдут названия компаний из категории social, получившие финансирование с 2010 по 2013 год включительно.
Проверим, что сумма инвестиций не равна нулю. Выведем также номер месяца, в котором проходил раунд финансирования.

select c.name as social_comp,
       extract(month from fr.funded_at) as month
from company as c
left join funding_round as fr on c.id=fr.company_id
where category_code='social'
and fr.funded_at between'2010-01-01' and '2013-12-31'
and fr.raised_amount!=0
_______________________________________

22. Отберем данные по месяцам с 2010 по 2013 год, когда проходили инвестиционные раунды. 
Сгруппируем данные по номеру месяца и получите таблицу, в которой будут поля:
- номер месяца, в котором проходили раунды;
- количество уникальных названий фондов из США, которые инвестировали в этом месяце;
- количество компаний, купленных за этот месяц;
- общая сумма сделок по покупкам в этом месяце.

with 
f as (select extract (month from fr.funded_at) as month,
              count(distinct f.id )as funds
from funding_round as fr
left join investment as i on i.funding_round_id=fr.id
left join fund as f on f.id=i.fund_id
where extract (year from fr.funded_at) between 2010 and 2013
and f.country_code='USA'
group by month),
      
a as (select extract(month from acquired_at) as f_month,
      count(acquired_company_id) as bought,
      sum(price_amount)as sum_total
from acquisition
where extract (year from acquired_at) between 2010 and 2013
group by f_month)

select f.month,
      f.funds,
      a.bought,
      a.sum_total
from f left join a on f.month=a.f_month
_______________________________________

23. Составим сводную таблицу и выведем среднюю сумму инвестиций для стран, в которых есть стартапы, зарегистрированные в 2011, 2012 и 2013 годах. 
Данные за каждый год должны быть в отдельном поле. Отсортируем таблицу по среднему значению инвестиций за 2011 год от большего к меньшему.
with
a as (select country_code as country,
                avg(funding_total) as total
         from company
         where extract(year from founded_at)=2011
         group by country_code),
         
b as (select country_code as country,
                avg(funding_total) as total
         from company
         where extract(year from founded_at)=2012
         group by country_code),     
         
c as (select country_code as country,
                avg(funding_total) as total
         from company
         where extract(year from founded_at)=2013
         group by country_code)
         
select a.country as country_name,
       a.total as total_11,
       b.total as total_12,
       c.total as total_13
from a join b on a.country=b.country
join c on b.country=c.country
order by a.total desc
_______________________________________

