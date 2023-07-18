use belfort;

go

-- this view gives the sales force the information about the investor
-- in case he contacts the technical support
create VIEW gen_info_investors
    AS
    select t.investor_id,name,country_name as country,
        t.phone,t.email,t.annual_salary,tc.cur_name
        
        from 
        tbl_investors t 
        inner join meta_countries m on m.country_id = t.country_id
        inner join tbl_currency tc on m.cur_code = tc.cur_id
        
go


GO

-- this view containes the necessary information in the right format in order to insert it to
create VIEW trades_assist
    AS
    SELECT f.BrokerID,f.[date],f.stock_id,f.iid,

    cast(Case
    when CHARINDEX('$',f.[value])>0 then REPLACE(f.[value],'$','')
    when f.[value] is null then null
    else f.[value]*tss.value_in_usd
    end as float)as value_usd -- convert 



    from 

    (SELECT 

        t.BrokerID, -- the brokerID
        c.[date], -- the call date
        CAST(CASE 
            WHEN c.stock IN (SELECT stock_name FROM tbl_stocks) THEN 
                (SELECT CAST(y.stock_id AS varchar(50)) FROM tbl_stocks y WHERE y.stock_name = c.stock)
            WHEN c.[value] IS NULL THEN NULL
            ELSE c.stock
        END  AS int) AS stock_id ,  --stock ID
        c.iid,
        c.[value] -- total amount of 
        FROM CALLS_TRADES_IID c
        JOIN tbl_brokers t
            ON c.broker = CAST(t.BrokerID AS NVARCHAR(50)) 
            OR c.broker = t.name) 
            f
    left join tbl_stock_spots tss  on      
            
    tss.spot_date = f.[date]
    and tss.stock_id = f.stock_id;

    

GO

GO

-- a view that uses as in the trigger rev_salt_insert to calculate the exchage rate
create view view_exchange_rates AS
    SELECT cur_id,date,euro as exchange_rate from tbl_currency, tbl_exchangerates_to_usd
    WHERE cur_id = 2
        union
    SELECT cur_id,date,shekel from tbl_currency, tbl_exchangerates_to_usd
    WHERE cur_id = 3
        union
    SELECT cur_id,date,1 from tbl_currency, tbl_exchangerates_to_usd
    WHERE cur_id = 1

go

go -- helps us to insert easily into tbl_stocktypes
CREATE VIEw stock_types_insert as
    select i.[type],i.selling_fee,i.salary_fee from (
    SELECT *
    FROM 
        (SELECT DISTINCT type FROM [grs.stocks]) g
    CROSS JOIN 
        (SELECT *
        FROM (VALUES 
            ('%Blue%', 0.0025, 0.01), 
            ('%penny%', 0.005, 0.50)
        ) AS T(type_pattern, selling_fee, salary_fee)) f
    WHERE 
        ([type] LIKE type_pattern AND selling_fee = f.selling_fee AND salary_fee = f.salary_fee)
    ) i
go 

GO -- a view that helps us to calculate the salaries later on
create VIEW basic_salary AS
    SELECT [date],salary,broker_id from mart_salaries ms
            INNER JOIN tbl_calls tc on tc.call_id = ms.call_id
             

GO




go --......................FOR ACCOUNTING MANAGMENT DEPARTMENT...............................
-- a dynamic table for accounting management with the workers salaries
create VIEW mart_monthly_salary AS
    SELECT broker_id,MONTH([date]) as month,SUM(salary)as salary from basic_salary
    GROUP BY broker_id,MONTH([date])
go 


GO 

 
 
 
 
 
 -- create a dynamic view that calculates the revenue for each month per broker
 -- this is the revenue that the same broker got into the company from his sellings

create view mart_monthly_revenue_per_worker AS
    SELECT 
    tc.broker_id,MONTH(tc.[date]) as month,
    sum(revenue_from_exchange+revenue_from_trade) as total_revenue
    from mart_revenues mr
    INNER JOIN tbl_calls tc on tc.call_id = mr.call_id
    

    group by tc.broker_id,MONTH(tc.[date])
GO


GO -- UNPRODUCTIVITY ANALYTICS --------------------------------

-- create a dynamic view that shows the dates that broker had 0 sellings
create view mart_unproductivity as
        SELECT broker_id,date,SUM(total_amount) as total_sales_per_day from tbl_calls

            GROUP by broker_id,date
            HAVING SUM(total_amount) = 0
                


GO


GO 
-- create a dynamic view that shows the amount of days each month that broker had 0 sellings
create view mart_unproductivity_amount_days as
    SELECT l.broker_id,l.[month],sum(l.num_of_days) as num_of_days from
        (SELECT h.*,COUNT(*) num_of_days from
        (SELECT broker_id,((month(date))) as month from mart_unproductivity

        )h


        GROUP BY h.broker_id,h.[month]
        
        UNION

        SELECT BrokerID, f.[month],0
        FROM tbl_brokers,
        (SELECT ((month(date))) as month from mart_unproductivity) f)l

        group by l.broker_id,l.[month]
                


GO

go 

-- we have checked the number of days that each broker worked without having sales.
-- and calculated the salary for those days (100$) as a % of the total monthly salary.
create view mart_unproductivity_rate_per_month
    AS
    SELECT mu.broker_id,mu.[month],cast(10000*mu.num_of_days/mm.salary as varchar(50)) +'%' as unproductivity_rate


    from mart_unproductivity_amount_days mu,mart_monthly_salary mm
        
    WHERE mm.broker_id = mu.broker_id
    and mu.[month] = mm.[month]
go 



GO

-- here we did the same but aggragetly fol all calls.
create view mart_unproductivity_per_brk
    as 
    SELECT f.broker_id,cast(10000*f.num_of_days/g.salary as varchar)+'%' as unproductivity_percenage from 
        (SELECT broker_id,sum(num_of_days) as num_of_days from mart_unproductivity_amount_days
        GROUP by broker_id)f,

        (SELECT broker_id,SUM(salary) as salary from mart_monthly_salary
        GROUP by broker_id) g 
        WHERE g.broker_id = f.broker_id

GO
-- measures the sum and amount of transaction each broker did in each mpnth
create view amount_per_calls_monthly as 
    SELECT 
        t.broker_id,month(t.[date]) as month,
        SUM(ABS(t.total_amount)) as total_amount_sum,
        COUNT(t.broker_id) as total_calls
    FROM 
        tbl_calls t
    GROUP BY 
        t.broker_id,month(t.[date]);


 GO     

 -- checks for each broker what is the avarage amount that he transact per call.
 create VIEW   mart_avg_sale_per_call_per_bkr
    as 
        SELECT broker_id,
        sum(total_amount_sum)/sum(total_calls) as avarage_transaction_per_call
        FROM amount_per_calls_monthly
        GROUP by broker_id

GO

-- checks monthly revenue
CREATE VIEW mart_monthly_revenue as 
    SELECT month(t.[date])as MONTH,
    sum(m.revenue_from_exchange) as rev_from_exchange,
    sum(m.revenue_from_trade) as rev_from_trade,
    sum(m.revenue_from_exchange+m.revenue_from_trade)as total_revenue
    from
    mart_revenues m,tbl_calls t
    where m.call_id = t.call_id

    GROUP by month(t.[date])
go


 -- gets the monthly profi
go
CREATE VIEW mart_monthly_profit as 
    SELECT mm.[month],sum(mr.total_revenue-mm.salary) as profit from mart_monthly_revenue_per_worker mr,mart_monthly_salary mm
        WHERE mr.broker_id = mm.broker_id
        and mr.[month] = mm.[month]
        GROUP by mm.[month]


go

CREATE VIEW mart_total_sales_per_stock as 
    select t.stock_id,SUM(abs(t.total_amount)) as total_sales
    from tbl_calls t
    WHERE stock_id is not null


    GROUP by t.stock_id

GO

create VIEW mart_sales_per_stocktype AS 
    SELECT t.stock_type,sum(m.total_sales) as total_sales from mart_total_sales_per_stock m,tbl_stocks t
    WHERE m.stock_id = t.stock_id
    group by t.stock_type


go
 -- unproductivity per team
create VIEW mart_unproductivity_team AS
    SELECT mm.managerID, mu.*
    FROM mart_unproductivity_per_brk mu, mart_management_tree mm
    where mm.brokerID = mu.broker_id


go


go
 -- monthly_revenue per team
create VIEW mart_mon_revenue_team AS
    SELECT mm.managerID, mu.[month],SUM(total_revenue) as total_revenue
    FROM mart_monthly_revenue_per_worker mu, mart_management_tree mm
    where mm.brokerID = mu.broker_id
    GROUP BY mm.managerID,mu.[month]
go


go
 -- revenue per team (not monthly)
create VIEW mart_revenue_team AS
    SELECT mm.managerID,SUM(total_revenue) as total_revenue
    FROM mart_monthly_revenue_per_worker mu, mart_management_tree mm
    where mm.brokerID = mu.broker_id
    GROUP BY mm.managerID
go

create VIEW mart_rev_calls_by_country AS

    SELECT g.country,COUNT(country) num_of_calls,
    sum(m.revenue_from_exchange) as rev_from_exchange
    ,sum(m.revenue_from_trade) as rev_from_trade,
    sum(m.revenue_from_exchange+m.revenue_from_trade) as total_rev
    from tbl_calls t,gen_info_investors g,mart_revenues m
    WHERE g.investor_id = t.investor_id
    and m.call_id = t.call_id
    GROUP by g.country

GO



