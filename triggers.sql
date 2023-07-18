use belfort;

-- Insert into meta_brokers after insetion into the brokers table



-- Insert into tbl_management_tree the following managers
-- id's and their workers under responsibility.







GO
-- when noninating a new manager, it will automatically insert to management tree the following managers with their workers.
create TRIGGER tr_insert_manegment_tree
    ON tbl_managers 
    AFTER INSERT
    AS
    BEGIN
        -- Insert into mart_management_tree
        INSERT INTO mart_management_tree (managerID, brokerID)
        SELECT i.managerID, g.num
        FROM inserted i,[grs_brokers_copy] g
        WHERE i.managerID = g.managerid;

        
    END
GO







GO
-- a trigger that safely delete broker from all relevant tables
CREATE TRIGGER before_delete_brokers
    ON tbl_brokers
    INSTEAD OF DELETE
    AS
    BEGIN
        
        DELETE mmt -- delete from 
        FROM mart_management_tree mmt
        INNER JOIN deleted d ON mmt.managerID = d.BrokerID OR mmt.brokerID = d.BrokerID;
        
        DELETE tm -- delete from mamangers table
        FROM tbl_managers tm 
        INNER JOIN deleted d ON tm.managerID = d.BrokerID;
        
        DELETE tb -- delete from brokers table
        FROM tbl_brokers tb
        INNER JOIN deleted d ON tb.BrokerID = d.BrokerID;


    END;

GO



Go
GO
-- insert country trigger that checks all things are ok.

-- if there is a problem and country name is not ok, or it is already in the table, then it will abort the insertion.
create TRIGGER country_insert ON [meta_countries]
    INSTEAD OF INSERT
    AS
    BEGIN
        DECLARE @co VARCHAR(50)
        SELECT @co = country_name FROM inserted -- country name

        IF EXISTS(SELECT * FROM meta_countries WHERE country_name = @co)
        BEGIN
            declare @m VARCHAR(MAX) = @co + ' is already in the countries table'
            RAISERROR(@m, 16, 1);
            RETURN;
        END;

        IF dbo.GetPhoneCode(@co) IS NOT NULL
        BEGIN
            INSERT INTO [meta_countries] (country_name, cur_code, phone_code)
            SELECT country_name, cur_code, phone_code FROM inserted
        END;
    END;
GO


GO
GO


go
-- trigger that checks all parameters are valid before insert
create TRIGGER check_investors
    ON tbl_investors
    INSTEAD OF INSERT
    AS
    BEGIN
        DECLARE @InvestorID INT; -- investor id 
        DECLARE @Name VARCHAR(50); --investor name
        DECLARE @Email VARCHAR(100); -- investor email
        DECLARE @Phone VARCHAR(50); -- investor phone
        DECLARE @InvAnnSalary INT; -- investor annual_salary
        DECLARE @CountryID INT; -- country_id from the tbl_countries
        DECLARE @country varchar(50); -- country_name
        DECLARE @Counter INT; -- a counter for the while loop

        -- Initialize counter with the minimum investor_id
        SELECT @Counter = MIN(investor_id) FROM inserted;

        WHILE EXISTS (SELECT * FROM inserted WHERE investor_id >= @Counter)
        BEGIN
            --set variables
            SELECT @InvestorID = investor_id,
                @Name = name,
                @Email = email,
                @Phone = phone,
                @InvAnnSalary = annual_salary,
                @CountryID = country_id
                FROM inserted
                WHERE investor_id = @Counter

            select @country = country_name from meta_countries WHERE country_id = @CountryID;
            --set phonecode
            DECLARE @inv_phonecode INT = dbo.GetPhoneCode(@country);

            if @country is NULL or @inv_phonecode is NULL -- problem with country
                BEGIN
                    RAISERROR ('make sure country is in countries table  you can always use the procedure insert_new_country', 16, 1);
                    RETURN;
                END
            

            -- if it is already a registered country
            if exists(select * from tbl_investors where investor_id = @InvestorID) 
                BEGIN
                    RAISERROR ('investor id is already registered', 16, 1);
                    RETURN;
                END
            
            --check name is not null
            if @Name is null
                BEGIN

                    RAISERROR ('name cant be null please provide proper names', 16, 1);
                    RETURN;
                END

            --CHECK email address is valid
            IF dbo.is_valid_email(@Email)=0
        
                BEGIN
                    RAISERROR ('invalid email address or it is already registered', 16, 1);
                    RETURN;
                END
             -- check valid phone number   
            if dbo.is_valid_phone(@Phone,@country) = 0
                BEGIN
                    RAISERROR ('invalid phone number make sure you put \n the right phone code to the country and then the number at this format yyy-xxxxxxx', 16, 1);
                    RETURN;
                END

            if  @InvAnnSalary<0 -- check annual_salary is proper
                BEGIN
                    RAISERROR ('annual salary cant be negative', 16, 1);
                    RETURN;
                END
            
            
            SET @Counter = @Counter + 1;
        end;
        insert into tbl_investors
        SELECT * from inserted
    END;
GO



GO
create TRIGGER update_investors
    ON tbl_investors
    INSTEAD OF UPDATE
    AS
    BEGIN
        DECLARE @inv_phone VARCHAR(50); -- investor's phone number
        DECLARE @inv_email VARCHAR(100); -- invest's email address
        DECLARE @inv_state VARCHAR(50); -- investor's state
        DECLARE @inv_ID int; -- investor's id
        DECLARE @inv_ann_salary int; --investor's salary

        DECLARE @RowCount INT;

        SELECT @RowCount = COUNT(*) FROM inserted;


        -- allow to update only 1 investor each time.
        IF @RowCount > 1
        BEGIN
            RAISERROR ('More than 1 row exists in the table. it is possible to update
            only 1 client information each time', 16, 1);
            RETURN;
        END

        -- Get phone, email, and investor_id from inserted row
        SELECT @inv_phone = phone,
            @inv_email = email, 
            @inv_ID = investor_id,
            @inv_ann_salary = annual_salary from inserted;

        -- Get country from gen_info_investors table
        SELECT @inv_state = country from gen_info_investors g 
            WHERE g.investor_id = @inv_ID;


        if not exists(select * from gen_info_investors g where g.investor_id = @inv_ID)

            BEGIN
                RAISERROR ('investor id is not in the system', 16, 1);
                RETURN;
            END
        -- Validate phone
        IF dbo.is_valid_phone(@inv_phone, @inv_state) = 0
            and  not exists 
            (SELECT * from gen_info_investors where phone = @inv_phone)
            BEGIN
                RAISERROR ('Invalid phone number. Make sure you put the right phone code for the country and then the number in this format yyy-xxxxxxx', 16, 1);
                RETURN;
            END

        -- Validate email
        IF dbo.is_valid_email(@inv_email) = 0
            and  not exists 
            (SELECT * from gen_info_investors where email = @inv_email)
            BEGIN
                RAISERROR ('Invalid email address or it is already registered', 16, 1);
                RETURN;
            END
        

        if  @inv_ann_salary<0 -- check annual_salary is proper
        BEGIN
            RAISERROR ('annual salary cant be negative', 16, 1);
            RETURN;
        END
        -- If phone and email are valid, proceed with update
        UPDATE tbl_investors
        SET phone = @inv_phone, email = @inv_email,annual_salary = @inv_ann_salary
        WHERE investor_id = @inv_ID;    
    END;
GO



GO
-- the trigger inserts the salaries and revenues to the relevant tables
create TRIGGER rev_sal_INSERT
    on tbl_calls
    INSTEAD OF INSERT
    
    AS
    BEGIN
        DECLARE @brok_id int; -- broker_id
        DECLARE @call_date date; -- call date
        DECLARE @st_id int; -- stock id
        DECLARE @inv_ID int; -- investor_id
        DECLARE @tot_amount float; -- total amount
        DECLARE @counter int = 1; -- counter
        DECLARE @ex_fee float; --the exchange fee according to the currency in %
        DECLARE @ex_rate float; -- exchange rate 
        -- please see there is a difference between the fee and the rate.
        DECLARE @salary float; -- salary of the broker
        declare @salary_fee float; -- the salary fee from the trade in %
        DECLARE @trade_fee float; -- @trade_fee according to the currency
        declare @inv_country varchar(50); 
        declare @cur_id float; -- currency id from 
        declare @exchange_revenue float; --the revenues from exchange
        DECLARE @trade_revenue float; -- the revenue from the trade
        


        WHILE @counter <= (SELECT COUNT(*) from inserted)
            BEGIN
                WITH NumberedRows AS (
            SELECT *, ROW_NUMBER()  OVER (ORDER BY (SELECT NULL)) RowNumber
            FROM inserted)

            SELECT -- define the variables
                @brok_id = broker_id,
                @call_date = [date],
                @st_id = stock_id,
                @inv_ID = investor_id,
                @tot_amount = total_amount 

                FROM NumberedRows
                WHERE RowNumber = @counter;

                
            set @ex_fee = dbo.getexchangefee(@inv_ID)

            SELECT @cur_id = dbo.GetCurrencyId(cur_name) from gen_info_investors
                    WHERE investor_id = @inv_ID

            SELECT @ex_rate = v.exchange_rate from view_exchange_rates v
                    WHERE v.date = @call_date and v.cur_id = @cur_id

            if @st_id is null -- means there wasn't any trade
                BEGIN
                    set @trade_fee = 0
                    SET @salary_fee = 0
                    set @tot_amount = 0
                END

            ELSE
                BEGIN
                    SELECT @trade_fee = tst.selling_fee,@salary_fee=tst.salary_fee from tbl_stocks ts,tbl_stocktypes tst
                        WHERE tst.type_id = ts.stock_type 
                        AND ts.stock_id = @st_id
                      
                     
                END    
            


            SET @salary = ABS(@salary_fee * @tot_amount) -- calculate salary fee
            
            SET @exchange_revenue = ABS(@ex_fee * @tot_amount) -- calculate exchange revenue

            SET @trade_revenue = ABS(@trade_fee * @tot_amount) -- calculate trade revenue
            
            

            --insert into calls table
            INSERT into tbl_calls (broker_id,[date],stock_id,investor_id,total_amount)
            VALUES (@brok_id,@call_date,@st_id,@inv_ID,@tot_amount);

            DECLARE @call_id int;
            SELECT @call_id = max(call_id) from tbl_calls -- get the generate call_id
            

            --insert into mart_revenues
            exec sp_in_mart_rev     
                @call_id = @call_id,
                @exchange_revenue =@exchange_revenue, --the revenues from exchange
                @trade_revenue=@trade_revenue

            -- here we will add 100$ if it is the first sale call of a worker in a specific day.
            if not exists ( SELECT * from basic_salary b
            where b.date = @call_date and b.broker_id = @brok_id)
                BEGIN
                    SET @salary = @salary + 100;
                END

            -- insert into mart_salaries
            exec sp_in_mart_salary     
                @call_id = @call_id,
                @salary = @salary


            set @counter = @counter+1;
            END;

    END;
GO    

GO


CREATE TRIGGER update_call
    on tbl_calls

    INSTEAD of UPDATE

    AS


    BEGIN

        RAISERROR('in order to avoid errors we do not allow to update calls table
    . please delete the problematic call and re-insert it',16,1)
        




    END


go

---next 3 triggers prevents any update.
-- if required, you can delete and reinsert the call
CREATE TRIGGER update_call1
    on mart_revenues

    INSTEAD of UPDATE

    AS


    BEGIN

        RAISERROR('in order to avoid errors we do not allow to update calls table
    . please delete the problematic call and re-insert it',16,1)
        


    END

go
CREATE TRIGGER update_call2
    on mart_salaries

    INSTEAD of UPDATE

    AS


    BEGIN

        RAISERROR('in order to avoid errors we do not allow to update calls table
    . please delete the problematic call and re-insert it',16,1)
        
    END
go    

-- trigger that deletes the call documentation from salaries and revenues table.
CREATE TRIGGER Delete_tbl_calls_Trigger
    ON tbl_calls
    INSTEAD OF DELETE
    AS
    BEGIN
        IF (SELECT COUNT(*) FROM DELETED) > 1
        BEGIN
            RAISERROR('Cannot delete more than one row at a time', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Deletes from mart_revenues
        DELETE FROM mart_revenues
        WHERE call_id IN (SELECT call_id FROM DELETED);

        -- Deletes from mart_salaries
        DELETE FROM mart_salaries
        WHERE call_id IN (SELECT call_id FROM DELETED);

        -- Now delete from tbl_calls
        DELETE FROM tbl_calls
        WHERE call_id IN (SELECT call_id FROM DELETED);
    END;



