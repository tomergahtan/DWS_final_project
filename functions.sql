
use belfort;

GO
-- this function gets a currency name and returns its serial number
create FUNCTION GetCurrencyId(@CurName VARCHAR(50))
    RETURNS INT
    AS
        BEGIN
            DECLARE @CurId INT;

            if not exists (select * from tbl_currency
            where cur_name = @CurName)
                BEGIN
                    
                    SELECT @CurId = cur_id 
                    FROM tbl_currency
                    WHERE cur_name = 'euro';
                    RETURN @CurId;
                END

            

            SELECT @CurId = cur_id 
            FROM tbl_currency
            WHERE cur_name = @CurName;

            RETURN @CurId;
        END;
GO



GO
CREATE FUNCTION GetCountryCurrencyId(@CountryName VARCHAR(50))
    RETURNS INT
    AS
    BEGIN
        DECLARE @CurName VARCHAR(50)

        -- Determine the currency name based on the country
        IF @CountryName = 'USA'
            SET @CurName = 'dollar'
        ELSE IF @CountryName = 'Israel'
            SET @CurName = 'shekel'
        ELSE
            SET @CurName = 'euro'

        -- Get the currency ID
        DECLARE @CurId INT
        SELECT @CurId = dbo.GetCurrencyId(@CurName)

        -- Return the currency ID
        RETURN @CurId
    END;
GO


GO

-- this function is used to get the phone code for each country.
create FUNCTION dbo.GetPhoneCode(@CountryName VARCHAR(255))
    RETURNS int
    AS
        BEGIN
            DECLARE @PhoneCode INT;

            SET @PhoneCode =
            CASE -- a list of all countries that exists on earth for 2023
               -- we didnt write DPKR because threre is a ban on international calls there.
               -- united arab emirates is UAE and united states is USA
                WHEN @CountryName = 'Mongolia' THEN 976
                WHEN @CountryName = 'Israel' THEN 972
                WHEN @CountryName = 'Greece' THEN 30
                WHEN @CountryName = 'USA' THEN 1
                WHEN @CountryName = 'England' THEN 44
                WHEN @CountryName = 'Spain' THEN 34
                WHEN @CountryName = 'Germany' THEN 49
                WHEN @CountryName = 'France' THEN 33
                WHEN @CountryName = 'Italy' THEN 39
                WHEN @CountryName = 'Canada' THEN 1
                WHEN @CountryName = 'Mexico' THEN 52
                WHEN @CountryName = 'Brazil' THEN 55
                WHEN @CountryName = 'Australia' THEN 61
                WHEN @CountryName = 'New Zealand' THEN 64
                WHEN @CountryName = 'India' THEN 91
                WHEN @CountryName = 'China' THEN 86
                WHEN @CountryName = 'Japan' THEN 81
                WHEN @CountryName = 'South Korea' THEN 82
                WHEN @CountryName = 'Russia' THEN 7
                WHEN @CountryName = 'South Africa' THEN 27
                WHEN @CountryName = 'Nigeria' THEN 234
                WHEN @CountryName = 'Egypt' THEN 20
                WHEN @CountryName = 'Turkey' THEN 90
                WHEN @CountryName = 'Argentina' THEN 54
                WHEN @CountryName = 'Chile' THEN 56
                WHEN @CountryName = 'Peru' THEN 51
                WHEN @CountryName = 'Colombia' THEN 57
                WHEN @CountryName = 'Venezuela' THEN 58
                WHEN @CountryName = 'Sweden' THEN 46
                WHEN @CountryName = 'Norway' THEN 47
                WHEN @CountryName = 'Finland' THEN 358
                WHEN @CountryName = 'Denmark' THEN 45
                WHEN @CountryName = 'Iceland' THEN 354
                WHEN @CountryName = 'Switzerland' THEN 41
                WHEN @CountryName = 'Austria' THEN 43
                WHEN @CountryName = 'Belgium' THEN 32
                WHEN @CountryName = 'Netherlands' THEN 31
                WHEN @CountryName = 'Poland' THEN 48
                WHEN @CountryName = 'Czech Republic' THEN 420
                WHEN @CountryName = 'Hungary' THEN 36
                WHEN @CountryName = 'Romania' THEN 40
                WHEN @CountryName = 'Bulgaria' THEN 359
                WHEN @CountryName = 'Serbia' THEN 381
                WHEN @CountryName = 'Croatia' THEN 385
                WHEN @CountryName = 'Slovenia' THEN 386
                WHEN @CountryName = 'Slovakia' THEN 421
                WHEN @CountryName = 'Ukraine' THEN 380
                WHEN @CountryName = 'Belarus' THEN 375
                WHEN @CountryName = 'Lithuania' THEN 370
                WHEN @CountryName = 'Latvia' THEN 371
                WHEN @CountryName = 'Estonia' THEN 372
                WHEN @CountryName = 'Ireland' THEN 353
                WHEN @CountryName = 'Portugal' THEN 351
                WHEN @CountryName = 'Cyprus' THEN 357
                WHEN @CountryName = 'Malta' THEN 356
                WHEN @CountryName = 'Luxembourg' THEN 352
                WHEN @CountryName = 'Andorra' THEN 376
                WHEN @CountryName = 'Monaco' THEN 377
                WHEN @CountryName = 'Indonesia' THEN 62
                WHEN @CountryName = 'Malaysia' THEN 60
                WHEN @CountryName = 'Philippines' THEN 63
                WHEN @CountryName = 'Singapore' THEN 65
                WHEN @CountryName = 'Thailand' THEN 66
                WHEN @CountryName = 'Vietnam' THEN 84
                WHEN @CountryName = 'Myanmar' THEN 95
                WHEN @CountryName = 'Cambodia' THEN 855
                WHEN @CountryName = 'Laos' THEN 856
                WHEN @CountryName = 'Bangladesh' THEN 880
                WHEN @CountryName = 'Pakistan' THEN 92
                WHEN @CountryName = 'Afghanistan' THEN 93
                WHEN @CountryName = 'Iran' THEN 98
                WHEN @CountryName = 'Iraq' THEN 964
                WHEN @CountryName = 'Saudi Arabia' THEN 966
                WHEN @CountryName = 'UAE' THEN 971
                WHEN @CountryName = 'Qatar' THEN 974
                WHEN @CountryName = 'Kuwait' THEN 965
                WHEN @CountryName = 'Bahrain' THEN 973
                WHEN @CountryName = 'Oman' THEN 968
                WHEN @CountryName = 'Yemen' THEN 967
                WHEN @CountryName = 'Syria' THEN 963
                WHEN @CountryName = 'Jordan' THEN 962
                WHEN @CountryName = 'Lebanon' THEN 961
                WHEN @CountryName = 'Palestine' THEN 970
                WHEN @CountryName = 'Albania' THEN 355
                WHEN @CountryName = 'Armenia' THEN 374
                WHEN @CountryName = 'Azerbaijan' THEN 994
                WHEN @CountryName = 'Georgia' THEN 995
                WHEN @CountryName = 'Kazakhstan' THEN 7
                WHEN @CountryName = 'Bosnia and Herzegovina' THEN 387
                WHEN @CountryName = 'Moldova' THEN 373
                WHEN @CountryName = 'Macao' THEN 853
                WHEN @CountryName = 'North Macedonia' THEN 389
                WHEN @CountryName = 'Montenegro' THEN 382
                WHEN @CountryName = 'San Marino' THEN 378
                WHEN @CountryName = 'Liechtenstein' THEN 423
                WHEN @CountryName = 'Algeria' THEN 213
                WHEN @CountryName = 'Angola' THEN 244
                WHEN @CountryName = 'Benin' THEN 229
                WHEN @CountryName = 'Botswana' THEN 267
                WHEN @CountryName = 'Burkina Faso' THEN 226
                WHEN @CountryName = 'Burundi' THEN 257
                WHEN @CountryName = 'Cabo Verde' THEN 238
                WHEN @CountryName = 'Cameroon' THEN 237
                WHEN @CountryName = 'Central African Republic' THEN 236
                WHEN @CountryName = 'Chad' THEN 235
                WHEN @CountryName = 'Comoros' THEN 269
                WHEN @CountryName = 'Congo' THEN 242
                WHEN @CountryName = 'Djibouti' THEN 253
                WHEN @CountryName = 'Equatorial Guinea' THEN 240
                WHEN @CountryName = 'Ethiopia' THEN 251
                WHEN @CountryName = 'Gabon' THEN 241
                WHEN @CountryName = 'Gambia' THEN 220
                WHEN @CountryName = 'Ghana' THEN 233
                WHEN @CountryName = 'Guinea' THEN 224
                WHEN @CountryName = 'Guinea-Bissau' THEN 245
                WHEN @CountryName = 'Ivory Coast' THEN 225
                WHEN @CountryName = 'Kenya' THEN 254
                WHEN @CountryName = 'Lesotho' THEN 266
                WHEN @CountryName = 'Liberia' THEN 231
                WHEN @CountryName = 'Libya' THEN 218
                WHEN @CountryName = 'Madagascar' THEN 261
                WHEN @CountryName = 'Malawi' THEN 265
                WHEN @CountryName = 'Mali' THEN 223
                WHEN @CountryName = 'Mauritania' THEN 222
                WHEN @CountryName = 'Mayotte' THEN 262
                WHEN @CountryName = 'Mauritius' THEN 230
                WHEN @CountryName = 'Morocco' THEN 212
                WHEN @CountryName = 'Mozambique' THEN 258
                WHEN @CountryName = 'Namibia' THEN 264
                WHEN @CountryName = 'Niger' THEN 227
                WHEN @CountryName = 'Niue' THEN 683
                WHEN @CountryName = 'Northern Mariana Islands' THEN 1670
                WHEN @CountryName = 'Pitcairn' THEN 0872
                WHEN @CountryName = 'Reunion' THEN 262
                WHEN @CountryName = 'Rwanda' THEN 250
                WHEN @CountryName = 'Sao Tome and Principe' THEN 239
                WHEN @CountryName = 'Senegal' THEN 221
                WHEN @CountryName = 'Seychelles' THEN 248
                WHEN @CountryName = 'Sierra Leone' THEN 232
                WHEN @CountryName = 'Somalia' THEN 252
                WHEN @CountryName = 'South Sudan' THEN 211
                WHEN @CountryName = 'Sudan' THEN 249
                WHEN @CountryName = 'Swaziland' THEN 268
                WHEN @CountryName = 'Tanzania' THEN 255
                WHEN @CountryName = 'Togo' THEN 228
                WHEN @CountryName = 'Tunisia' THEN 216
                WHEN @CountryName = 'Uganda' THEN 256
                WHEN @CountryName = 'Zambia' THEN 260
                WHEN @CountryName = 'Zimbabwe' THEN 263
                WHEN @CountryName = 'Antigua and Barbuda' THEN 1
                WHEN @CountryName = 'Barbados' THEN 1
                WHEN @CountryName = 'Costa Rica' THEN 506
                WHEN @CountryName = 'Cuba' THEN 53
                WHEN @CountryName = 'Dominica' THEN 1
                WHEN @CountryName = 'Dominican Republic' THEN 1
                WHEN @CountryName = 'El Salvador' THEN 503
                WHEN @CountryName = 'Grenada' THEN 1
                WHEN @CountryName = 'Guatemala' THEN 502
                WHEN @CountryName = 'Haiti' THEN 509
                WHEN @CountryName = 'Hong Kong' THEN 852
                WHEN @CountryName = 'Honduras' THEN 504
                WHEN @CountryName = 'Jamaica' THEN 1
                WHEN @CountryName = 'Nicaragua' THEN 505
                WHEN @CountryName = 'Panama' THEN 507
                WHEN @CountryName = 'Saint Kitts and Nevis' THEN 1
                WHEN @CountryName = 'Saint Lucia' THEN 1
                WHEN @CountryName = 'Saint Vincent and the Grenadines' THEN 1
                WHEN @CountryName = 'Trinidad and Tobago' THEN 1
                WHEN @CountryName = 'Bolivia' THEN 591
                WHEN @CountryName = 'Ecuador' THEN 593
                WHEN @CountryName = 'Guyana' THEN 592
                WHEN @CountryName = 'Bhutan' THEN 975
                WHEN @CountryName = 'Brunei' THEN 673
                WHEN @CountryName = 'Maldives' THEN 960
                WHEN @CountryName = 'Nepal' THEN 977
                WHEN @CountryName = 'Sri Lanka' THEN 94
                WHEN @CountryName = 'Timor-Leste' THEN 670
                WHEN @CountryName = 'Papua New Guinea' THEN 675
                WHEN @CountryName = 'Solomon Islands' THEN 677
                WHEN @CountryName = 'Vanuatu' THEN 678
                WHEN @CountryName = 'Fiji' THEN 679
                WHEN @CountryName = 'Tonga' THEN 676
                WHEN @CountryName = 'Kiribati' THEN 686
                WHEN @CountryName = 'Micronesia' THEN 691
                WHEN @CountryName = 'Montserrat' THEN 664
                WHEN @CountryName = 'Nauru' THEN 674
                WHEN @CountryName = 'Palau' THEN 680
                WHEN @CountryName = 'Marshall Islands' THEN 692
                WHEN @CountryName = 'Samoa' THEN 685
                WHEN @CountryName = 'Tuvalu' THEN 688
                WHEN @CountryName = 'Eritrea' THEN 291
                WHEN @CountryName = 'Paraguay' THEN 595
                WHEN @CountryName = 'Vatican City' THEN 379
                WHEN @CountryName = 'Kosovo' THEN 383
                WHEN @CountryName = 'Greenland' THEN 299
                WHEN @CountryName = 'Faroe Islands' THEN 298
                WHEN @CountryName = 'Gibraltar' THEN 350
                WHEN @CountryName = 'Isle of Man' THEN 44
                WHEN @CountryName = 'Guernsey' THEN 44
                WHEN @CountryName = 'Jersey' THEN 44
                WHEN @CountryName = 'Saint Helena' THEN 290
                WHEN @CountryName = 'Western Sahara' THEN 212
                WHEN @CountryName = 'Mongolia' THEN 976
                WHEN @CountryName = 'Tajikistan' THEN 992
                WHEN @CountryName = 'Kyrgyzstan' THEN 996
                WHEN @CountryName = 'Turkmenistan' THEN 993
                WHEN @CountryName = 'Uzbekistan' THEN 998
                WHEN @CountryName = 'Bahamas' THEN 1
                WHEN @CountryName = 'Belize' THEN 501
                WHEN @CountryName = 'Suriname' THEN 597
                WHEN @CountryName = 'Uruguay' THEN 598


                                
                ELSE NULL
            END;

            RETURN @PhoneCode;
        END;
GO

GO

-- this function checks the amount of times a char apears in a string.
CREATE FUNCTION dbo.char_frequency
    (
        @input VARCHAR(MAX),
        @char CHAR(1)
    )
    RETURNS INT
    AS
    BEGIN
        RETURN (LEN(@input) - LEN(REPLACE(@input, @char, '')))
    END;
GO




GO
 -- gets a country name and returns it's ID
create FUNCTION country_id_recognizer
    (@country VARCHAR(50))
    RETURNS INT 
    AS
    BEGIN
        -- If the country doesn't exist in the 'meta_countries' table and its phone code is null, return NULL.
        if not exists (SELECT * from meta_countries where country_name = @country)
        BEGIN
            RETURN NULL;
        END
        -- Return the 'country_id' of the provided country.
        RETURN (SELECT country_id FROM meta_countries WHERE country_name = @country);
    END;

GO




-- check validity of an email address
GO
create FUNCTION dbo.is_valid_email (@inv_email VARCHAR(100))
    RETURNS INT
    AS
    BEGIN
        if CHARINDEX('.', @inv_email) = 0
            or CHARINDEX('.', @inv_email) = LEN(@inv_email)

            BEGIN
                RETURN 0;
            END

        DECLARE @provider VARCHAR(50);
        SET @provider = SUBSTRING(@inv_email, CHARINDEX('@', @inv_email) + 1, CHARINDEX('.', @inv_email, CHARINDEX('@', @inv_email)) - CHARINDEX('@', @inv_email) - 1);

        IF dbo.char_frequency(@inv_email,'@') <> 1 -- check @ frequency

            -- check if provider is in the email providers
            OR NOT EXISTS (SELECT 1 FROM meta_email_providers WHERE provider_name = @provider)
            
            -- check if there is an address before @
            OR (CHARINDEX('@', @inv_email) = 1)
            
            -- check if there is an identical email address
            OR EXISTS(SELECT * FROM tbl_investors WHERE email = @inv_email)
            
            -- check if email is null
            or @inv_email is null
            
            --check a
            or PATINDEX('%[^a-zA-Z0-9@._-]%', @inv_email) <> 0
            
        BEGIN
            RETURN 0; -- Invalid or already existing email
        END

        RETURN 1; -- Valid email
    END;
GO



go


-- check the phone is valid

create FUNCTION dbo.is_valid_phone (@inv_phone VARCHAR(50), @inv_state VARCHAR(50))
    RETURNS INT
    AS
    BEGIN
        DECLARE @inv_phonecode INT = dbo.GetPhoneCode(@inv_state); -- the phone code

        IF NOT CHARINDEX('-', @inv_phone) > 1 -- check there is a valid country code
            --check the next conditions for a valid phone number
            OR @inv_phonecode != CAST(SUBSTRING(@inv_phone, 1, CHARINDEX('-', @inv_phone) - 1) AS INT)
            OR NOT dbo.char_frequency(@inv_phone, '-') = 1
            OR PATINDEX('%[^0-9-]%', @inv_phone) > 0 -- if there are non digit or "-" characters.
            OR EXISTS ( SELECT * FROM tbl_investors WHERE phone = @inv_phone)
            or SUBSTRING(@inv_phone,LEN(@inv_phone),1)='-'
            or @inv_phone is null
            or @inv_phonecode is null

        BEGIN
            RETURN 0; -- Invalid or already existing phone number
        END

        RETURN 1; -- Valid phone number
    END;
GO

-- get the relevant exchange rate for each investor 
GO
create FUNCTION dbo.getexchangefee(@inv_id int)
        RETURNS FLOAT AS

            BEGIN
                RETURN 
                (SELECT ex_fee from tbl_currency t,gen_info_investors g
                where g.investor_id = @inv_id
                and t.cur_name = g.cur_name)

            END
GO



