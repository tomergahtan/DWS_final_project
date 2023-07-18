use belfort;


GO

-- a procedure that will let us to add a new broker.
-- the procedure will get all the relevant data like
-- it appears in grs.brokers and insert it to the relevant tables


create PROCEDURE sp_InsertBroker
    @brokerID INT,
    @name VARCHAR(50),
    @managerID INT,
    @DOB DATE
    AS
    BEGIN
        -- Check if brokerID already exists in tbl_brokers
        IF EXISTS (SELECT * FROM tbl_brokers WHERE BrokerID = @brokerID)
        BEGIN
            RAISERROR ('Error: brokerID already exists in tbl_brokers.', 16, 1);
            RETURN;  -- End procedure
        END


        -- in case the new broker is a manager

        if @managerID = @brokerID
            BEGIN
                INSERT INTO [grs_brokers_copy] VALUES(@brokerID,@name,@managerID,@DOB);
                INSERT into [tbl_brokers] VALUES(@brokerID,@name,@DOB);
                INSERT into [tbl_managers] VALUES(@managerID);
                delete from grs_brokers_copy where num = @brokerID
                RETURN;
            END


        -- in case the manager is not the broker and not registered
        if not exists(SELECT managerID from tbl_managers WHERE managerID = @managerID)
            BEGIN
                RAISERROR ('Error: this manager is not registered', 16, 1);
                RETURN;
            END   


        -- in case the manager is registered and not the broker.
        INSERT INTO [grs_brokers_copy] VALUES(@brokerID,@name,@managerID,@DOB);
        INSERT into [tbl_brokers] VALUES(@brokerID,@name,@DOB); 
        INSERT into [mart_management_tree] VALUES(@managerID,@brokerID);
        delete from grs_brokers_copy where num = @brokerID
        RETURN;
        
    END;
GO




GO
--this procedure is intended for insertion of a country 

-- all you need to do is enter the country name
create PROCEDURE insert_new_country
    @country_name VARCHAR(50)

    AS
    BEGIN
        -- a note. please pay attention that country name is valid. we check it.
        INSERT INTO [meta_countries] (country_name,cur_code,phone_code) VALUES
        (@country_name , dbo.GetCountryCurrencyId(@country_name), dbo.GetPhoneCode(@country_name))
        
    END;
GO



GO

-- a procedure that easily inserts a new investor.

create PROCEDURE insert_new_investor
    @inv_ID int, -- investorID
    @inv_name VARCHAR(50), -- name
    @inv_state VARCHAR(50), -- country
    @inv_phone VARCHAR(50), -- phone
    @inv_email VARCHAR(50), -- email
    @inv_ann_salary INT = null --annual salary
    AS
    BEGIN
        
        -- check if all values are fitted
        
        if dbo.country_id_recognizer(@inv_state) is NULL -- making sure that country is in the countries table.
            BEGIN
                EXEC insert_new_country @country_name = @inv_state; 
            END

        insert into tbl_investors 
        (investor_id,name,country_id,email,annual_salary,phone)
        VALUES (@inv_ID,@inv_name,dbo.country_id_recognizer(@inv_state),@inv_email,@inv_ann_salary,@inv_phone);

        
        
        -- check that information successfully inserted
  
            RETURN;
    END;
GO 



GO

-- a procedure that will help us to insert new call

CREATE procedure sp_newcall
    @broker_id int, 
    @iid int, -- INVESTOR ID
    @date DATE,
    @stock_id int = NULL,
    @quantity INT, -- quantity
    
    @sell_buy VARCHAR(50) -- (s/b) SELL OR BUY


    
    AS
        BEGIN
        DECLARE @tot_amount FLOAT;
        DECLARE @stock_price float;


            -- check there is a real purchase
            if @stock_id is NULL
                or @quantity = 0
                    BEGIN
                        SET @stock_id = NULL;
                        set @tot_amount = NULL;
                    END
            else 
                BEGIN
                -- CHECK STOCKSPOT IS VALID
                    if not EXISTS(SELECT * from tbl_stock_spots where stock_id =@stock_id and spot_date = @date )
                        BEGIN      
                            RAISERROR('that stockspot is not exist check stock number and date',16,1)
                            RETURN;
                        END;

                    --else
                    SELECT @stock_price = value_in_usd from tbl_stock_spots WHERE stock_id = @stock_id
                            and spot_date = @date
                    SET @tot_amount = @stock_price  * @quantity        
                END

            -- CHECK COMMAND IS VALID
            IF @sell_buy = 'sell' or @sell_buy = 's'
            -- SET A SELL COMMAND

                BEGIN
                    SET @tot_amount = @tot_amount * (-1);
                END


            
            if not @sell_buy = 'buy' and not @sell_buy = 'b' and not @sell_buy = 's' and not @sell_buy = 'sell'


                BEGIN
                    RAISERROR('command is invalid. can be only sell or buy',16,1)
                    RETURN;
                END

            
            -- CHECK QUANTITY IS NOT NEGQATIVE
            if @quantity < 0

                BEGIN
                    RAISERROR('quantity cant be negative',16,1)
                    RETURN;
                END
            
            -- INVESTOR IS VALID
            if not exists(select * from tbl_investors where investor_id = @iid) 

                BEGIN
                    RAISERROR('investor id is not exists. please insert a valid investor',16,1)
                    RETURN;
                END

            
            -- BROKER IS VALID
            if not exists(select * from tbl_brokers where BrokerID = @broker_id) 

                BEGIN
                    RAISERROR('investor id is not exists. please insert a valid investor',16,1)
                    RETURN;
                END


            insert into tbl_calls (broker_id,[date],stock_id,investor_id,total_amount)
            VALUES(@broker_id,@date,@stock_id,@iid,@tot_amount) 
        END;
go

go

go

--insert into mart_salaries
CREATE PROCEDURE sp_in_mart_salary
    @salary float,
    @call_id int
    AS

    BEGIN
            INSERT into mart_salaries (call_id,salary)
            VALUES (@call_id,@salary)
    END


GO

-- insert into mart_revenues
CREATE PROCEDURE sp_in_mart_rev
    
    @call_id int,
    @exchange_revenue float, --the revenues from exchange
    @trade_revenue float
    AS

    BEGIN
            INSERT into mart_revenues(call_id,revenue_from_trade,revenue_from_exchange)
            VALUES (@call_id,@trade_revenue,@exchange_revenue);
    END


GO