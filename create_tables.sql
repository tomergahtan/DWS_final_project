
use belfort;

--initializing the grs tables into tbl meta and mart tables


go


SELECT * --create the copy for grs.brokers that will use us.
INTO grs_brokers_copy
FROM [grs.brokers];


go
go
create TABLE tbl_brokers( -- brokers table
    BrokerID INT PRIMARY KEY, -- id
    name VARCHAR(50) not null, --name
    bdate DATE -- begin date
);

go



go

CREATE TABLE tbl_management_tree(
     --table of the managers and who they are managing
    managerID INT,
    brokerID INT,
    PRIMARY KEY (managerID, brokerID),
    FOREIGN KEY (managerID) REFERENCES tbl_brokers(BrokerID),
    FOREIGN KEY (brokerID) REFERENCES tbl_brokers(BrokerID)
);


go
go


CREATE TABLE tbl_managers( --table of the managers

    managerID INT PRIMARY KEY,
    FOREIGN KEY (managerID) REFERENCES tbl_brokers(BrokerID)

);


go
go


CREATE TABLE mart_management_tree( 
    --table of the managers and who they are managing
    managerID INT,
    brokerID INT,
    PRIMARY KEY (managerID, brokerID),
    FOREIGN KEY (managerID) REFERENCES tbl_brokers(BrokerID),
    FOREIGN KEY (brokerID) REFERENCES tbl_brokers(BrokerID)
);

go
go

create TABLE tbl_stocktypes
( -- this table is used to contain the stock type information
    type_id INT IDENTITY (1,1) PRIMARY KEY,
    type_name VARCHAR(50),
    selling_fee FLOAT not null, -- the selling fee for the company
    salary_fee FLOAT not null -- the salary fee for the worker
);

go
go

CREATE TABLE tbl_stocks( -- create the table of stocks that also connected with stocktypes table
    stock_id INT PRIMARY KEY,
    stock_name VARCHAR(50),
    stock_type int NOT NULL, --penny or blue chip
    FOREIGN KEY (stock_type) REFERENCES tbl_stocktypes(type_id)
);


go
go

CREATE TABLE tbl_stock_spots( -- create the table of stocks spots.
    stock_id int not null,
    spot_date DATE NOT NULL,
    PRIMARY KEY (stock_id,spot_date),
    value_in_usd FLOAT NOT NULL,
    FOREIGN KEY (stock_id) REFERENCES tbl_stocks(stock_id)
);

go
go

-- creating a meta talbe that says for USD per day,
-- how many ILS and EURO it worths every day.
SELECT [date], (1/s_to_d) as usd_to_ils, (1/e_to_d) as usd_to_euro
INTO meta_usd_value_comparison
FROM [grs.exchangerates];


-- make date as aprimary key in the new table we have just created.
ALTER TABLE meta_usd_value_comparison
ADD CONSTRAINT PK_meta_usd_value_comparison PRIMARY KEY ([date]);

go
go


-- creating the table for currencies.
create table tbl_currency(
    cur_id int IDENTITY(1,1) PRIMARY KEY,
    cur_name varchar(50) UNIQUE not NULL
);

GO
go

ALTER TABLE tbl_currency
ADD ex_fee float; -- a part of 
GO

--create the exchange rate table for future use.
create TABLE tbl_exchangerates_to_usd (
    DATE date PRIMARY KEY,
    shekel float not NULL,
    euro FLOAT NOT NULL
);

go
go

create TABLE tbl_exchangerates (
     day_id INT IDENTITY (1,1) PRIMARY KEY,
     date DATE NOT NULL UNIQUE,
     ils_to_usd FLOAT not null,
     eur_to_usd FLOAT not null

);

go
go

-- creating the countries table
CREATE TABLE meta_countries (
    country_id int IDENTITY (1,1) PRIMARY KEY,
    country_name VARCHAR(50) not null unique,
    cur_code INT NOT NULL,
    phone_code int NOT NULL unique,
    FOREIGN KEY (cur_code) REFERENCES tbl_currency (cur_id) -- each country has only 1 currency type and it has to be in the system.
);


go

GO
-- create the table of allowed email providers
CREATE TABLE meta_email_providers(
    provider_id INT IDENTITY (1,1) PRIMARY KEY not null,
    provider_name VARCHAR(50) NOT NULL unique
);


-- creating the table of country phonecodes
go
go

-- creating the investors table
CREATE TABLE tbl_investors
(
    investor_id INT NOT NULL PRIMARY KEY, -- primary key column
    name [VARCHAR](50) NOT NULL,
    country_id int NOT NULL,
    email [VARCHAR](100) not null,
    annual_salary int ,
    phone [VARCHAR](50) NOT NULL,
    FOREIGN key (country_id) 
    REFERENCES meta_countries(country_id)
    
);





go






go

CREATE TABLE tbl_calls(
    call_id INT IDENTITY(4001, 1) PRIMARY KEY,
    broker_id INT, -- droker id
    date DATE,-- date of trade
    stock_id int NULL,
    investor_id INT,
    total_amount FLOAT NULL,
    FOREIGN KEY (broker_id) REFERENCES tbl_brokers(BrokerID),
    FOREIGN KEY (stock_id) REFERENCES tbl_stocks(stock_id),
    FOREIGN KEY (investor_id) REFERENCES tbl_investors(investor_id)
);
go

go


CREATE TABLE mart_revenues (
    call_id INT PRIMARY KEY,
    FOREIGN KEY (call_id) REFERENCES tbl_calls(call_id),
    revenue_from_trade FLOAT not null,
    revenue_from_exchange FLOAT not null

);
go

go
CREATE TABLE mart_salaries(
    call_id INT PRIMARY KEY,
    FOREIGN KEY (call_id) REFERENCES tbl_calls(call_id),
    salary FLOAT not null
);
go



