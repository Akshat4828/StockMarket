-- Create table stock_data
CREATE TABLE stock_data (
    Date DATE,
    Company VARCHAR(255),
    Open NUMERIC,
    Close NUMERIC,
    High NUMERIC,
    Low NUMERIC,
    Volume BIGINT,
    CONSTRAINT PK_stock_data PRIMARY KEY CLUSTERED (Date, Company)  -- Primary key on Date and Company
);

--Indexing Strategy
--Based on the above queries, here’s how you should index your stock_data table:

--Primary Key
--Since you have Date and Company as your main filtering and joining columns, make them the primary key. This will ensure data integrity and optimize retrieval by these columns.

--Secondary Indexes
--Create a secondary index on Company to optimize queries that filter by company.
--Depending on the performance needs and query frequency, consider indexing Date if filtering by date range is common or beneficial.


-- Create secondary index on Company
CREATE INDEX idx_company ON stock_data (Company);

-- Optional: Create index on Date if frequently filtered by date
CREATE INDEX idx_date ON stock_data (Date);





-- Query to get daily variation of prices for a specific company
SELECT Date, Company, (Close - Open) AS DailyVariation
FROM stock_data WITH(INDEX(PK_stock_data))  -- Use the primary key index hint
WHERE Company = 'Company_Name'
ORDER BY Date;


-- Query to get daily volume change for a specific company
SELECT Date, Company, Volume
FROM stock_data WITH(INDEX(PK_stock_data))  -- Use the primary key index hint
WHERE Company = 'Company_Name'
ORDER BY Date;

-- Query to calculate median daily variation across all companies for a specific date
WITH RankedVariations AS (
    SELECT Date, Company, (Close - Open) AS DailyVariation,
           ROW_NUMBER() OVER (PARTITION BY Date ORDER BY (Close - Open)) AS RowNum,
           COUNT(*) OVER (PARTITION BY Date) AS TotalRows
    FROM stock_data WITH(INDEX(idx_date))  -- Use index hint on idx_date for date filtering
)
SELECT Date, 
       AVG(DailyVariation) AS MedianDailyVariation
FROM RankedVariations
WHERE RowNum IN (CEILING(TotalRows / 2.0), FLOOR(TotalRows / 2.0) + 1)
GROUP BY Date;

