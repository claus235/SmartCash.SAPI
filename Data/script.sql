USE [master]
GO
USE master

IF EXISTS(select * from sys.databases where name='SAPI')
BEGIN
    DROP DATABASE SAPI
END

/****** Object:  Database [SAPI]    Script Date: 30/03/2018 8:19:53 PM ******/
CREATE DATABASE [SAPI]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'SAPI', FILENAME = N'/var/opt/mssql/data/SAPI.mdf' , SIZE = 204800KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'SAPI_log', FILENAME = N'/var/opt/mssql/data/SAPI_log.ldf' , SIZE = 401408KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
GO
ALTER DATABASE [SAPI] SET COMPATIBILITY_LEVEL = 140
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [SAPI].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [SAPI] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [SAPI] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [SAPI] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [SAPI] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [SAPI] SET ARITHABORT OFF 
GO
ALTER DATABASE [SAPI] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [SAPI] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [SAPI] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [SAPI] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [SAPI] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [SAPI] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [SAPI] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [SAPI] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [SAPI] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [SAPI] SET  DISABLE_BROKER 
GO
ALTER DATABASE [SAPI] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [SAPI] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [SAPI] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [SAPI] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [SAPI] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [SAPI] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [SAPI] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [SAPI] SET RECOVERY FULL 
GO
ALTER DATABASE [SAPI] SET  MULTI_USER 
GO
ALTER DATABASE [SAPI] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [SAPI] SET DB_CHAINING OFF 
GO
ALTER DATABASE [SAPI] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [SAPI] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [SAPI] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [SAPI] SET QUERY_STORE = OFF
GO
USE [SAPI]
GO
ALTER DATABASE SCOPED CONFIGURATION SET IDENTITY_CACHE = ON;
GO
ALTER DATABASE SCOPED CONFIGURATION SET LEGACY_CARDINALITY_ESTIMATION = OFF;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET LEGACY_CARDINALITY_ESTIMATION = PRIMARY;
GO
ALTER DATABASE SCOPED CONFIGURATION SET MAXDOP = 0;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET MAXDOP = PRIMARY;
GO
ALTER DATABASE SCOPED CONFIGURATION SET PARAMETER_SNIFFING = ON;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET PARAMETER_SNIFFING = PRIMARY;
GO
ALTER DATABASE SCOPED CONFIGURATION SET QUERY_OPTIMIZER_HOTFIXES = OFF;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET QUERY_OPTIMIZER_HOTFIXES = PRIMARY;
GO
USE [SAPI]
GO
/****** Object:  Table [dbo].[TransactionInput]    Script Date: 30/03/2018 8:19:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TransactionInput](
	[TxidIn] [char](64) NOT NULL,
	[IndexIn] [smallint] NOT NULL,
	[TxidOut] [char](64) NOT NULL,
	[IndexOut] [smallint] NOT NULL,
	[Address] [char](34) MASKED WITH (FUNCTION = 'default()') NOT NULL,
	[Value] [decimal](16, 8) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[TxidIn] ASC,
	[IndexIn] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TransactionOutput]    Script Date: 30/03/2018 8:19:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TransactionOutput](
	[Txid] [char](64) NOT NULL,
	[Index] [smallint] NOT NULL,
	[Address] [char](34) NOT NULL,
	[Value] [decimal](16, 8) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Txid] ASC,
	[Index] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[vAddressSpent]    Script Date: 30/03/2018 8:19:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vAddressSpent]
AS
SELECT tou.*
FROM [dbo].[TransactionOutput] tou
    LEFT JOIN [dbo].[TransactionInput] tin
        ON tou.Txid = tin.TxidOut
           AND tou.[Index] = tin.IndexOut
WHERE tin.TxidOut IS NOT NULL;
GO
/****** Object:  View [dbo].[vAddressUnspent]    Script Date: 30/03/2018 8:19:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vAddressUnspent] WITH SCHEMABINDING
AS
SELECT tou.Txid, tou.[Index], tou.Address, tou.Value
FROM [dbo].[TransactionOutput] tou
    LEFT JOIN [dbo].[TransactionInput] tin
        ON tou.Txid = tin.TxidOut
           AND tou.[Index] = tin.IndexOut
WHERE tin.TxidOut IS NULL;
GO
/****** Object:  Table [dbo].[Transaction]    Script Date: 30/03/2018 8:19:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Transaction](
	[Txid] [char](64) NOT NULL,
	[BlockHash] [char](64) NOT NULL,
	[Version] [tinyint] NOT NULL,
	[Time] [datetime] NOT NULL,
	[IsRemoved] [bit] NULL,
	[IsWebWallet] [bit] NULL,
	[RawTransaction] [varchar](max) NULL,
PRIMARY KEY NONCLUSTERED 
(
	[Txid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO



SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[TransactionBroadcast](
	[TxId] [char](64) NOT NULL,
	[BroadcastTime] [datetime] NOT NULL,
	[RawTransaction] [text] NOT NULL,
 CONSTRAINT [PK_TransactionBroadcast] PRIMARY KEY CLUSTERED 
(
	[TxId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO




/****** Object:  View [dbo].[vAddressBalance]    Script Date: 30/03/2018 8:19:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[vAddressBalance]
AS


SELECT a.[Address],
       SUM(o.[Value]) AS 'Received',
       SUM(o.[Value] - ISNULL(i.[Value], 0)) AS 'Sent',
	   ISNULL(SUM(i.[Value]), 0) AS 'Balance'

FROM
(SELECT DISTINCT [Address] FROM [dbo].[TransactionOutput] AS tou) a
    LEFT JOIN
    (
        SELECT t.[Address],
               SUM(t.[Value]) AS 'Value'
        FROM [dbo].[vAddressUnspent] AS t
        GROUP BY t.[Address]
    ) i
        ON i.[Address] = a.[Address]
    LEFT JOIN
    (
        SELECT [tou].[Address],
               SUM([tou].[Value]) AS 'Value'
        FROM [dbo].[Transaction] AS t
            LEFT JOIN [dbo].[TransactionOutput] AS tou
                ON tou.[Txid] = t.[Txid]
        WHERE tou.[Txid] IS NOT NULL
        GROUP BY [tou].[Address]
    ) o
        ON o.[Address] = a.[Address]
GROUP BY a.[Address];
GO
/****** Object:  Table [dbo].[Block]    Script Date: 30/03/2018 8:19:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Block](
	[Hash] [char](64) NOT NULL,
	[Height] [int] NOT NULL,
	[Confirmation] [int] NOT NULL,
	[Size] [int] NOT NULL,
	[Difficulty] [decimal](16, 8) NOT NULL,
	[Version] [tinyint] NOT NULL,
	[Time] [datetime] NOT NULL,
PRIMARY KEY NONCLUSTERED 
(
	[Hash] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Address]    Script Date: 30/03/2018 8:19:54 PM ******/
CREATE NONCLUSTERED INDEX [IX_Address] ON [dbo].[TransactionOutput]
(
	[Address] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_TransactionInput]    Script Date: 30/03/2018 8:19:54 PM ******/
CREATE NONCLUSTERED COLUMNSTORE INDEX [IX_TransactionInput] ON [dbo].[TransactionInput]
(
	[Address]
)WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_TransactionOutput]    Script Date: 30/03/2018 8:19:54 PM ******/
CREATE NONCLUSTERED COLUMNSTORE INDEX [IX_TransactionOutput] ON [dbo].[TransactionOutput]
(
	[Address]
)WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0) ON [PRIMARY]
GO

/****** Object:  Index [IX_Address_Value]    Script Date: 31/03/2018 1:18:13 AM ******/
CREATE NONCLUSTERED INDEX [IX_Address_Value] ON [dbo].[TransactionOutput]
(
	[Address] ASC
)
INCLUDE ( 	[Value]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Object:  Index [IX_TxId_Index]    Script Date: 31/03/2018 1:19:45 AM ******/
CREATE NONCLUSTERED INDEX [IX_TxId_Index] ON [dbo].[TransactionInput]
(
	[TxidOut] ASC,
	[IndexOut] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO




USE [master]
GO
ALTER DATABASE [SAPI] SET  READ_WRITE 
GO

USE [SAPI]
GO

CREATE PROCEDURE [Transaction_Create]  
(  
    -- Add the parameters for the stored procedure here  
 @Txid char(64),  
 @BlockHash char(64),  
 @Version tinyint,  
 @Time datetime,  
 @IsWebWallet bit = null,  
 @RawTransaction varchar(max) = null  
)  
AS  
BEGIN  
    -- SET NOCOUNT ON added to prevent extra result sets from  
    -- interfering with SELECT statements.  
    SET NOCOUNT ON  
  
IF(SELECT COUNT(*) FROM [SAPI].[dbo].[Transaction] WHERE txId =@Txid) = 0  
BEGIN  
  
 INSERT INTO [SAPI].[dbo].[Transaction]  
      ([Txid]  
      ,[BlockHash]  
      ,[Version]  
      ,[Time]  
      ,[IsWebWallet]  
      ,[RawTransaction])  
   VALUES  
      (@Txid,  
      @BlockHash,  
      @Version,  
      @Time,  
      @IsWebWallet,  
      @RawTransaction)  
END  
ELSE  
BEGIN  
 UPDATE [SAPI].[dbo].[Transaction] SET [BlockHash] = @BlockHash, [Version] = @Version, [Time] = @Time, IsRemoved = NULL WHERE[Txid] = @Txid AND BlockHash = ''  
END  
  
END
GO


CREATE PROCEDURE [Address_Deposit_History]
	@address char(34),
	@dateFrom Datetime = null,
	@dateTo Datetime = null,
	@PageNumber INT = 1,
	@PageSize   INT = 10
AS
BEGIN


IF(@dateFrom is null)
	SET @dateFrom = DATEADD(DAY, -365, GETUTCDATE())

IF(@dateTo is null)
	SET @dateTo = GETUTCDATE()

PRINT @dateFrom

PRINT @dateTo


 SELECT t.txId,   
   t.Time as TimeStamp,   
   o.Value as Amount
   FROM [Transaction] t  
   INNER JOIN TransactionOutput o  
   ON t.txId = o.txId  
   WHERE o.Address = @address
     AND t.Time BETWEEN  @dateFrom AND @dateTo
     AND t.txId NOT IN (SELECT t.txId 
						  FROM [Transaction] t  
						 INNER JOIN TransactionInput i  
						    ON t.txId = i.txIdin  
						  LEFT JOIN TransactionOutput o  
						    ON t.txId = o.txId  
						 WHERE i.Address = @address   
						  AND o.Address <> @address )
   ORDER BY TimeStamp DESC
 OFFSET @PageSize * (@PageNumber - 1) ROWS
  FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
END

GO





CREATE PROCEDURE [sp_RebuildIndex]
(
    @Rebuild bit = 0,
    @TableName varchar(100) = ''
)
AS
BEGIN
 
	SET NOCOUNT ON;
 
	DECLARE  @Version                           [numeric] (18, 10)
			,@SQLStatementID                    [int]
			,@CurrentTSQLToExecute              [nvarchar](max)
			,@FillFactor                        [int]        = 100 -- Change if needed
			,@PadIndex                          [varchar](3) = N'OFF' -- Change if needed
			,@SortInTempDB                      [varchar](3) = N'OFF' -- Change if needed
			,@OnlineRebuild                     [varchar](3) = N'OFF' -- Change if needed
			,@LOBCompaction                     [varchar](3) = N'ON' -- Change if needed
			,@DataCompression                   [varchar](4) = N'NONE' -- Change if needed
			,@MaxDOP                            [int]        = NULL -- Change if needed
			,@IncludeDataCompressionArgument    [char](1);
 
	IF OBJECT_ID(N'TempDb.dbo.#Work_To_Do') IS NOT NULL
		DROP TABLE #Work_To_Do
	CREATE TABLE #Work_To_Do
		(
		  [sql_id] [int] IDENTITY(1, 1)
						 PRIMARY KEY ,
		  [tsql_text] [varchar](1024) ,
		  [completed] [bit]
		)
 
	SET @Version = CAST(LEFT(CAST(SERVERPROPERTY(N'ProductVersion') AS [nvarchar](128)), CHARINDEX('.', CAST(SERVERPROPERTY(N'ProductVersion') AS [nvarchar](128))) - 1) + N'.' + REPLACE(RIGHT(CAST(SERVERPROPERTY(N'ProductVersion') AS [nvarchar](128)), LEN(CAST(SERVERPROPERTY(N'ProductVersion') AS [nvarchar](128))) - CHARINDEX('.', CAST(SERVERPROPERTY(N'ProductVersion') AS [nvarchar](128)))), N'.', N'') AS [numeric](18, 10))
 
	IF @DataCompression IN (N'PAGE', N'ROW', N'NONE')
		AND (
			@Version >= 10.0
			AND SERVERPROPERTY(N'EngineEdition') = 3
			)
	BEGIN
		SET @IncludeDataCompressionArgument = N'Y'
	END
 
	IF @IncludeDataCompressionArgument IS NULL
	BEGIN
		SET @IncludeDataCompressionArgument = N'N'
	END
 
	INSERT INTO #Work_To_Do ([tsql_text], [completed])
	SELECT 'ALTER INDEX [' + i.[name] + '] ON' + SPACE(1) + QUOTENAME(t2.[TABLE_CATALOG]) + '.' + QUOTENAME(t2.[TABLE_SCHEMA]) + '.' + QUOTENAME(t2.[TABLE_NAME]) + SPACE(1) + 'REBUILD WITH (' + SPACE(1) + + CASE
			WHEN @PadIndex IS NULL
				THEN 'PAD_INDEX =' + SPACE(1) + CASE i.[is_padded]
						WHEN 1
							THEN 'ON'
						WHEN 0
							THEN 'OFF'
						END
			ELSE 'PAD_INDEX =' + SPACE(1) + @PadIndex
			END + CASE
			WHEN @FillFactor IS NULL
				THEN ', FILLFACTOR =' + SPACE(1) + CONVERT([varchar](3), REPLACE(i.[fill_factor], 0, 100))
			ELSE ', FILLFACTOR =' + SPACE(1) + CONVERT([varchar](3), @FillFactor)
			END + CASE
			WHEN @SortInTempDB IS NULL
				THEN ''
			ELSE ', SORT_IN_TEMPDB =' + SPACE(1) + @SortInTempDB
			END + CASE
			WHEN @OnlineRebuild IS NULL
				THEN ''
			ELSE ', ONLINE =' + SPACE(1) + @OnlineRebuild
			END + ', STATISTICS_NORECOMPUTE =' + SPACE(1) + CASE st.[no_recompute]
			WHEN 0
				THEN 'OFF'
			WHEN 1
				THEN 'ON'
			END + ', ALLOW_ROW_LOCKS =' + SPACE(1) + CASE i.[allow_row_locks]
			WHEN 0
				THEN 'OFF'
			WHEN 1
				THEN 'ON'
			END + ', ALLOW_PAGE_LOCKS =' + SPACE(1) + CASE i.[allow_page_locks]
			WHEN 0
				THEN 'OFF'
			WHEN 1
				THEN 'ON'
			END + CASE
			WHEN @IncludeDataCompressionArgument = N'Y'
				THEN CASE
						WHEN @DataCompression IS NULL
							THEN ''
						ELSE ', DATA_COMPRESSION =' + SPACE(1) + @DataCompression
						END
			ELSE ''
			END + CASE
			WHEN @MaxDop IS NULL
				THEN ''
			ELSE ', MAXDOP =' + SPACE(1) + CONVERT([varchar](2), @MaxDOP)
			END + SPACE(1) + ')'
		,0
	FROM [sys].[tables] t1
	INNER JOIN [sys].[indexes] i ON t1.[object_id] = i.[object_id]
		AND i.[index_id] > 0
		AND i.[type] IN (1, 2)
	INNER JOIN [INFORMATION_SCHEMA].[TABLES] t2 ON t1.[name] = t2.[TABLE_NAME]
		AND t2.[TABLE_TYPE] = 'BASE TABLE'
	INNER JOIN [sys].[stats] AS st WITH (NOLOCK) ON st.[object_id] = t1.[object_id]
		AND st.[name] = i.[name]
	WHERE t2.[TABLE_NAME] = @TableName OR @TableName = ''
 
	SELECT @SQLStatementID = MIN([sql_id])
	FROM #Work_To_Do
	WHERE [completed] = 0
 
	WHILE @SQLStatementID IS NOT NULL
	BEGIN
		SELECT @CurrentTSQLToExecute = [tsql_text]
		FROM #Work_To_Do
		WHERE [sql_id] = @SQLStatementID
 
		PRINT @CurrentTSQLToExecute
 
		IF @Rebuild = 1
		BEGIN
			PRINT 'Executed'
			EXEC [sys].[sp_executesql] @CurrentTSQLToExecute
		END 
		
 
		UPDATE #Work_To_Do
		SET [completed] = 1
		WHERE [sql_id] = @SQLStatementID
 
		SELECT @SQLStatementID = MIN([sql_id])
		FROM #Work_To_Do
		WHERE [completed] = 0
	END

		IF @Rebuild = 1
		BEGIN
			PRINT 'Updating Statistics...'
			EXEC sp_updatestats
		END 

END
GO



BULK INSERT SAPI.dbo.Block FROM '/smartdata/blocks.txt' WITH (FIRSTROW = 2,FIELDTERMINATOR = ',',ROWTERMINATOR = '\n') 
GO

BULK INSERT SAPI.dbo.[transaction] FROM '/smartdata/transaction.txt' WITH (FIRSTROW = 2,FIELDTERMINATOR = ',',ROWTERMINATOR = '\n') 
GO

BULK INSERT SAPI.dbo.[transactioninput] FROM '/smartdata/transactioninput.txt' WITH (FIRSTROW = 2,FIELDTERMINATOR = ',',ROWTERMINATOR = '\n') 
GO

BULK INSERT SAPI.dbo.[transactionoutput] FROM '/smartdata/transactionoutput.txt' WITH (FIRSTROW = 2,FIELDTERMINATOR = ',',ROWTERMINATOR = '\n') 
GO

PRINT 'Rebuilding index'

EXEC sp_RebuildIndex 1

SELECT * FROM SAPI.dbo.[vAddressBalance] WHERE Address = 'SXun9XDHLdBhG4Yd1ueZfLfRpC9kZgwT1b'


GO
