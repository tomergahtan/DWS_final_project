
use belfort;
/* this file will help you to manage the system easier */


-------  INSERTIONS SECTION ------- 
-- here easily you can insert a new broker or get relevant information about a broker


GO
    -- insert new broker easily. 
    -- better to use it then in the regular insert command
    exec sp_InsertBroker
    @brokerID  = NULL,
    @name  = NULL,
    @managerID = NULL,
    @DOB = NULL
go
GO
-- INSERT A CALL
exec sp_newcall
    @broker_id  = NULL, --broker_id
    @iid  = NULL, --investor _id
    @date  = NULL,-- mm.dd.yyyy
    @stock_id  = NULL,
    @quantity  = NULL,
    @sell_buy = 'b' -- (b/s) SELL OR BUY 
GO

 -- INSERT AN INVESTOR

 -- please put proper variables
exec insert_new_investor
@inv_ID = NULL,
@inv_name = 'tomer',
@inv_state = 'israel',
@inv_phone = '972-12',
@inv_email = 'tomerix12@gmail.com',
@inv_ann_salary = NULL


GO
--- UPDATE investor ----
UPDATE tbl_investors 
set country_id = NULL -- possible to change other columns too
WHERE investor_id = NULL

GO 
-- INSERT A COUNTRY

-- All you need to do is to put a **VALID AND NEW** country name
-- it will update the currency and phonecode by itself.

GO
EXEC insert_new_country @country_name = 'sdfsdf';
go

GO



go


------ CFO ----------



select * from mart_monthly_revenue  --revenue per month
SELECT * FROM mart_monthly_profit   --profit per month
SELECT SUM(profit)as profit FROM mart_monthly_profit -- total profit
SELECT * from mart_monthly_salary -- salary per month for each worker

--salaries expence each month
SELECT [month],SUM(salary)as salary from mart_monthly_salary
GROUP by [month] 



go

------ CEO ----------



select * from mart_monthly_revenue  --revenue per month
SELECT * FROM mart_monthly_profit   --profit per month

SELECT SUM(profit)as profit FROM mart_monthly_profit -- total profit


select * from mart_total_sales_per_stock -- total transactions per stock
select * from mart_unproductivity_team -- each manage and each broker unproductivity rate
select * from mart_revenue_team -- total revenue for each team
select * from mart_avg_sale_per_call_per_bkr -- average transaction per call per broker

-- calcualte the total aggregated revenue per worker
select broker_id,sum(total_revenue) as total_revenue from mart_monthly_revenue_per_worker
group by broker_id

GO


--------------- ACCOUNTING MANAGEMENT --------------------------------

GO
SELECT * from mart_monthly_salary
go




--------------- SALES FORCE --------------------------------


GO
    select * from mart_total_sales_per_stock -- total sales per stock
    select * from mart_sales_per_stocktype  -- total sales per stock type
    select *,-- total revenue, num of calls and revenue per income stream by country
    total_rev/num_of_calls as avg_rev from mart_rev_calls_by_country 

go




