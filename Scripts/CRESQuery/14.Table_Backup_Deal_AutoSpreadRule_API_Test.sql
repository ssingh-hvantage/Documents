-----Take backup of Deal_AutoSpreadRule for deal save automation using API

if exists (select * from sys.objects where name = 'Backup_Deal_AutoSpreadRule_API_Test' and type = 'u')
	drop table  [CRE].Backup_Deal_AutoSpreadRule_API_Test

CREATE TABLE [CRE].[Backup_Deal_AutoSpreadRule_API_Test] 
(  	
    [DealID]             UNIQUEIDENTIFIER NOT NULL,   
    [RequiredEquity]     DECIMAL (28, 15) NULL,
    [AdditionalEquity]   DECIMAL (28, 15) NULL,
);

INSERT INTO [CRE].[Backup_Deal_AutoSpreadRule_API_Test]
(
DealID	,
[RequiredEquity],
[AdditionalEquity]
)

select DealID	,
[RequiredEquity],
[AdditionalEquity]
from  [CRE].[AutoSpreadRule]