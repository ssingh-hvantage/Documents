IF OBJECT_ID('tempdb..#tblCFDownload') IS NOT NULL         
	DROP TABLE #tblCFDownload

CREATE TABLE #tblCFDownload(  
DealName	nvarchar(256)	 ,
DealID	nvarchar(256)	 ,
NoteId	nvarchar(256)	 ,
NoteName	nvarchar(256)	 ,
[Date]	Date	 ,
[Value]	decimal(28,15)	 ,
ValueType	nvarchar(256)	 ,
Spread	decimal(28,15)	 ,
OriginalIndex	decimal(28,15)	 ,
IndexValue	decimal(28,15)	 ,
EffectiveRate	decimal(28,15)	 ,
TransactionDate	date	 ,
DueDate	date	 ,
RemitDate	date	 ,
AccountingCloseDate	date	 ,
FeeName	nvarchar(256)	 ,
Description	nvarchar(256)	 ,
Cash_NonCash	nvarchar(256)	 ,
AdjustmentType	nvarchar(256)	 ,
PurposeType	nvarchar(256)	 ,

)

INSERT INTO #tblCFDownload(DealName,DealID,NoteId,NoteName,[Date],[Value],ValueType,Spread,OriginalIndex,IndexValue,EffectiveRate,TransactionDate,DueDate,RemitDate,AccountingCloseDate,FeeName,[Description],Cash_NonCash,AdjustmentType,PurposeType)
EXEC [dbo].[usp_GetNoteCashflowsExportData_All] 'c10f3372-0fc2-4861-a9f5-148f1f80804f'


select 
cf.DealName
,cf.DealID
,cf.NoteId
,cf.NoteName
,cf.[Date]
,cf.[Value]
,cf.ValueType
,cf.Spread
,cf.OriginalIndex
,cf.IndexValue
,cf.EffectiveRate
,cf.TransactionDate
,cf.DueDate
,cf.RemitDate
,cf.AccountingCloseDate
,cf.FeeName
,cf.[Description]
,cf.Cash_NonCash
,cf.AdjustmentType
,cf.PurposeType

,n.ClosingDate
,lRateType.name as RateType
,n.InitialIndexValueOverride
,lenablem61Calculations.name as enablem61Calculations
,lCalcEngineType.name as CalcEngineType

from #tblCFDownload cf
inner Join cre.note n on n.crenoteid = cf.noteid
left join core.lookup lenablem61Calculations on lenablem61Calculations.lookupid = n.enablem61Calculations
left join core.lookup lRateType on lRateType.lookupid = n.RateType
left join core.CalculationRequests cr on cr.accountid = n.account_accountid and cr.analysisid = 'C10F3372-0FC2-4861-A9F5-148F1F80804F'
left join core.lookup lCalcEngineType on lCalcEngineType.lookupid = cr.CalcEngineType

where (Spread is null OR OriginalIndex is null OR IndexValue is null OR EffectiveRate is null)
and lenablem61Calculations.name = 'Y'
and [ValueType] in (
'StubInterest',
'PIKPrincipalFunding',
'PIKInterestPaid',
'PIKInterest',
'InterestPaid'
)


