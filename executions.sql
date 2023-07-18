use belfort;
go

go

-- filling the brokers table, and activating the trigger that fills the meta_brokers table
INSERT INTO tbl_brokers(BrokerID,name,bdate)
SELECT num,name,bdate FROM [grs.brokers]
go

go

-- filling the managers table and the management tree table
insert into [tbl_managers] (managerID)
SELECT distinct managerid from [grs.brokers];


go

go
-- filling the stocktypes table (contains 2 stovktypes.)
-- we have also inserted the relevant stovktype fee that the company takes for any kind of stock


insert into [tbl_stocktypes] (type_name,selling_fee,salary_fee)
select * from stock_types_insert

go

go
--insert into stocks table the stocks information

INSERT into [tbl_stocks](stock_id,stock_name, stock_type)
SELECT num,name,[type_id] from [grs.stocks] g, 
[tbl_stocktypes] y
    WHERE y.type_name = g.[type];


go

go
--insert values into the relevant stockspots table
insert into [tbl_stock_spots] (stock_id, spot_date, value_in_usd)
    SELECT * from [grs.stock_spots]; 

go

go
-- insert to exchangerates table the exchangerates information.

insert into tbl_exchangerates_to_usd
SELECT * from [grs.exchangerates]

go

go


-- insert into tbl_currency the all possilble curriencies
insert into tbl_currency (cur_name)
SELECT distinct cur from [grs.past_investors]


GO
UPDATE tbl_currency -- update the exchange fee to/FROM USD
SET ex_fee = CASE 
    WHEN cur_name = 'dollar' THEN 0
    WHEN cur_name = 'shekel' THEN 0.02
    WHEN cur_name = 'euro' THEN 0.01
    ELSE ex_fee
END;

GO



go
-- insert of the countries into the coutnries table while activating the currnecyid function

insert into meta_countries (country_name,cur_code,phone_code)
select *from 
(SELECT distinct g.[state], dbo.GetCountryCurrencyId(state) as currency,dbo.GetPhoneCode(g.[state]) AS phone_code from [grs.past_investors] g

UNION

SELECT distinct state,dbo.GetCountryCurrencyId(state),dbo.GetPhoneCode(state) from [grs.newinvestors] 
)j
where j.phone_code is not null;

go

go

-- insert the allowed email providers.
INSERT INTO meta_email_providers(provider_name)
VALUES ('walla'), ('yahoo'), ('gmail'),('grazi');



-- insert investors information
go

INSERT into tbl_investors
 SELECT num, name, dbo.country_id_recognizer([state]),email,annual_salary,phone
    FROM [grs.past_investors]



insert into tbl_investors
SELECT 
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) + (SELECT MAX(num) FROM [grs.past_investors]) AS row_num,
        Investor_Name,
        dbo.country_id_recognizer(CASE 
            WHEN [State] = 'Israeli' THEN 'Israel'
            ELSE [State]
        END) AS country,
        REPLACE(Email, ' ', '') AS email,income,
        cast(dbo.GetPhoneCode(CASE 
            WHEN [State] = 'Israeli' THEN 'Israel'
            ELSE [State]
        END) as varchar(50))+'-'+SUBSTRING(phone, CHARINDEX('-', Phone) + 1, LEN(phone)) AS phone
        
    FROM [grs.newinvestors]
AS i



go

go



-- insert the calls

INSERT into tbl_calls
SELECT * from trades_assist









-- Prevent all users from inserting into tbl_investors and meta_investors
--INSERT into meta_countries (country_name,cur_code,phone_code)

--insert into tbl_calls





