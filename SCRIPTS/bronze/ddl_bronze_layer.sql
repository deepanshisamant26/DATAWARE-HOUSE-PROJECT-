--- DATA WAREHOUSE PROJECT---
USE MASTER ;
IF EXISTS (SELECT 1 FROM SYS.DATABASES WHERE NAME='DATA_WAREHOUSE')
BEGIN ALTER DATABASE DATA_WAREHOUSE SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
DROP DATABASE DATA_WAREHOUSE;
END;
GO


CREATE DATABASE DATA_WAREHOUSE;
USE DATA_WAREHOUSE

CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;


CREATE TABLE bronze.crm_cust_info
(
cst_id int,
cst_key nvarchar(50),
cst_firstname nvarchar(50),
cst_lastname nvarchar(50),
cst_matrial_status nvarchar(50),
cst_gndr nvarchar(10),
cst_create_date DATE
)



IF OBJECT_ID('bronze.crm_prd_info', 'U') IS NOT NULL
    DROP TABLE bronze.crm_prd_info;
GO

CREATE TABLE bronze.crm_prd_info (
    prd_id       INT,
    prd_key      NVARCHAR(50),
    prd_nm       NVARCHAR(50),
    prd_cost     INT,
    prd_line     NVARCHAR(50),
    prd_start_dt DATETIME,
    prd_end_dt   DATETIME
);
GO

IF OBJECT_ID('bronze.crm_sales_details', 'U') IS NOT NULL
    DROP TABLE bronze.crm_sales_details;
GO

CREATE TABLE bronze.crm_sales_details (
    sls_ord_num  NVARCHAR(50),
    sls_prd_key  NVARCHAR(50),
    sls_cust_id  INT,
    sls_order_dt INT,
    sls_ship_dt  INT,
    sls_due_dt   INT,
    sls_sales    INT,
    sls_quantity INT,
    sls_price    INT
);
GO

IF OBJECT_ID('bronze.erp_loc_a101', 'U') IS NOT NULL
    DROP TABLE bronze.erp_loc_a101;
GO

CREATE TABLE bronze.erp_loc_a101 (
    cid    NVARCHAR(50),
    cntry  NVARCHAR(50)
);
GO

IF OBJECT_ID('bronze.erp_cust_az12', 'U') IS NOT NULL
    DROP TABLE bronze.erp_cust_az12;
GO

CREATE TABLE bronze.erp_cust_az12 (
    cid    NVARCHAR(50),
    bdate  DATE,
    gen    NVARCHAR(50)
);
GO

IF OBJECT_ID('bronze.erp_px_cat_g1v2', 'U') IS NOT NULL
    DROP TABLE bronze.erp_px_cat_g1v2;
GO

CREATE TABLE bronze.erp_px_cat_g1v2 (
    id           NVARCHAR(50),
    cat          NVARCHAR(50),
    subcat       NVARCHAR(50),
    maintenance  NVARCHAR(50)
);
GO

create or alter procedure bronze.load_bronze as
begin
declare @start_time DATETIME ,@end_time DATETIME, @batch_start DATETIME , @batch_end DATETIME ;
begin try 
    set @batch_start=getdate();
    
    set @start_time=getdate();
    
   truncate table bronze.crm_cust_info;
    BULK INSERT bronze.crm_cust_info 
    from 'C:\Users\Dell\Desktop\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
    with (
    firstrow=2,
    fieldterminator=',',
    tablock
    )
     set @end_time=getdate();
     print '>>load duration: '+ cast(datediff(second,@start_time,@end_time) as nvarchar)+ 'seconds';
     print '---------------------'
    select count(*) 
    from bronze.crm_cust_info

     set @start_time=getdate();
   
    truncate table bronze.crm_prd_info;
    BULK INSERT bronze.crm_prd_info 
    from 'C:\Users\Dell\Desktop\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
    with (
    firstrow=2,
    fieldterminator=',',
    tablock
    )
         print '>>load duration: '+ cast(datediff(second,@start_time,@end_time) as nvarchar)+ 'seconds';
     print '---------------------'
    
     set @start_time=getdate();
   
    truncate table bronze.crm_sales_details;
    BULK INSERT bronze.crm_sales_details 
    from 'C:\Users\Dell\Desktop\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
    with (
    firstrow=2,
    fieldterminator=',',
    tablock
    )
         print '>>load duration: '+ cast(datediff(second,@start_time,@end_time) as nvarchar)+ 'seconds';
     print '---------------------'
      set @start_time=getdate();
   
    truncate table bronze.erp_CUST_AZ12;
    BULK INSERT bronze.erp_CUST_AZ12 
    from 'C:\Users\Dell\Desktop\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
    with (
    firstrow=2,
    fieldterminator=',',
    tablock
    )
         print '>>load duration: '+ cast(datediff(second,@start_time,@end_time) as nvarchar)+ 'seconds';
     print '---------------------'

      set @start_time=getdate();
   
    truncate table bronze.erp_loc_a101;
    BULK INSERT bronze.erp_loc_a101 
    from 'C:\Users\Dell\Desktop\sql-data-warehouse-project\datasets\source_erp\loc_a101.csv'
    with (
    firstrow=2,
    fieldterminator=',',
    tablock
    )
         print '>>load duration: '+ cast(datediff(second,@start_time,@end_time) as nvarchar)+ 'seconds';
     print '---------------------'
    
     set @start_time=getdate();
   
    truncate table bronze.erp_px_cat_g1v2;
    BULK INSERT bronze.erp_px_cat_g1v2 
    from 'C:\Users\Dell\Desktop\sql-data-warehouse-project\datasets\source_erp\px_cat_g1v2.csv'
    with (
    firstrow=2,
    fieldterminator=',',
    tablock)
         print '>>load duration: '+ cast(datediff(second,@start_time,@end_time) as nvarchar)+ 'seconds';
     print '---------------------';
    set @batch_end=getdate()
     print '---------------------';
    print 'bronze layer loading time'
     print '>>load duration: '+ cast(datediff(second,@batch_start,@batch_end) as nvarchar)+ 'seconds';
     print '---------------------';
   
end try 
begin catch
PRINT ('an error occured');
PRINT ('an error message'+ error_message());
PRINT ('an error number'+cast (error_number() as nvarchar));
PRINT ('an error line'+ cast(error_message()as nvarchar));
PRINT ('an error procedure'+ error_procedure())
end catch
end
    



exec bronze.load_bronze
