
DECLARE @DevScenario AS UNIQUEIDENTIFIER=(select AnalysisID From core.analysis where [name] = 'Default')
DECLARE @DevScenario_name AS nvarchar(256)=(select [name] From core.analysis where [name] = 'Default')

DECLARE @StgScenario AS UNIQUEIDENTIFIER=(select AnalysisID From core.analysis where [name] = 'Default_CopyV1')
DECLARE @StgScenario_name AS  nvarchar(256)=(select [name] From core.analysis where [name] = 'Default_CopyV1')


IF object_id('tempdb..##PeriodicOutputNPCColumn') is not null drop table ##PeriodicOutputNPCColumn

Select ISNULL(a.dealname,b.dealname) as DealName
, ISNULL(a.credealid,b.credealid) as DealID
, ISNULL(a.crenoteid,b.crenoteid) as NoteID
, c.EnableM61Calculations,c.Status, @DevScenario_name as [DevScenario], @StgScenario_name as [StgScenario]
, ISNULL(a.PeriodEndDate,b.PeriodEndDate) as PeriodEndDate
-- Beginning balance
, ISNULL(a.BeginningBalance,0) as DEV_BeginningBalance
, ISNULL(b.BeginningBalance,0) as Stg_BeginningBalance
, (ISNULL(a.BeginningBalance,0) - ISNULL(b.BeginningBalance,0)) as Delta_BeginningBalance
--TotalFutureAdvancesForThePeriod
, ISNULL(a.TotalFutureAdvancesForThePeriod,0) as DEV_TotalFutureAdvancesForThePeriod
, ISNULL(b.TotalFutureAdvancesForThePeriod,0) as Stg_TotalFutureAdvancesForThePeriod
, (ISNULL(a.TotalFutureAdvancesForThePeriod,0) - ISNULL(b.TotalFutureAdvancesForThePeriod,0)) as Delta_TotalFutureAdvancesForThePeriod
-- 

into ##PeriodicOutputNPCColumn
from (
	Select d.dealname,d.credealid,n.CreNoteID,nc.Accountid,nc.PeriodEndDate,nc.BeginningBalance,nc.TotalFutureAdvancesForThePeriod,nc.PIKInterestAppliedForThePeriod,ScheduledPrincipal
	,nc.TotalDiscretionaryCurtailmentsforthePeriod,nc.BalloonPayment,nc.EndingBalance,nc.GrossDeferredFees,nc.CleanCost,nc.TotalAmortAccrualForPeriod
	,nc.AccumulatedAmort,nc.DiscountPremiumAccrual,nc.DiscountPremiumAccumulatedAmort,nc.CapitalizedCostAccrual,nc.CapitalizedCostAccumulatedAmort
	,nc.AmortizedCost, nc.CurrentPeriodPIKInterestAccrual
	,nc.InvestmentBasis
	,nc.PVAmortForThePeriod, nc.CleanCostPrice,nc.AmortizedCostPrice,nc.ReversalofPriorInterestAccrual,nc.InterestReceivedinCurrentPeriod	
	,nc.CurrentPeriodInterestAccrual,nc.InterestSuspenseAccountBalance,nc.TotalGAAPInterestFortheCurrentPeriod,nc.EndingGAAPBookValue 
	from cre.NotePeriodicCalc nc
	Inner Join cre.note n on n.account_accountid = nc.accountid
	Inner join core.account acc on acc.accountID=n.account_accountID
	inner Join cre.deal d on d.dealid = n.dealid
	Where acc.isdeleted <> 1 and [month] is not null
	and nc.AnalysisID=@DevScenario
	and n.CRENoteID = '24208'
) a
full outer join (
	Select d.dealname,d.credealid,n.CreNoteID,nc.Accountid,nc.PeriodEndDate,nc.BeginningBalance,nc.TotalFutureAdvancesForThePeriod,nc.PIKInterestAppliedForThePeriod,ScheduledPrincipal
	,nc.TotalDiscretionaryCurtailmentsforthePeriod,nc.BalloonPayment,nc.EndingBalance,nc.GrossDeferredFees,nc.CleanCost,nc.TotalAmortAccrualForPeriod
	,nc.AccumulatedAmort,nc.DiscountPremiumAccrual,nc.DiscountPremiumAccumulatedAmort,nc.CapitalizedCostAccrual,nc.CapitalizedCostAccumulatedAmort
	,nc.AmortizedCost, nc.CurrentPeriodPIKInterestAccrual	
	,nc.InvestmentBasis
	,nc.PVAmortForThePeriod, nc.CleanCostPrice,nc.AmortizedCostPrice,nc.ReversalofPriorInterestAccrual,nc.InterestReceivedinCurrentPeriod	
	,nc.CurrentPeriodInterestAccrual,nc.InterestSuspenseAccountBalance,nc.TotalGAAPInterestFortheCurrentPeriod,nc.EndingGAAPBookValue 
	from cre.NotePeriodicCalc nc
	Inner Join cre.note n on n.account_accountid = nc.accountid
	Inner join core.account acc on acc.accountID=n.account_accountID
	inner Join cre.deal d on d.dealid = n.dealid
	Where acc.isdeleted <> 1 and [month] is not null
	and nc.AnalysisID=@StgScenario
	and n.CRENoteID = '24208'

) b on a.CreNoteID=b.CreNoteID and a.PeriodEndDate=b.PeriodEndDate 

left join cre.Note n on n.CRENoteID=ISNULL(a.CreNoteID ,b.Crenoteid)
left join core.account acc on acc.accountID=n.account_accountID
left join cre.Deal d on d.DealID=n.DealID
left join (
	Select CreNoteID, l1.Name as EnableM61Calculations, l.Name as Status, aa.Name as Analysis, PaymentDateBusinessDayLag 
	from cre.Note n
	left join core.CalculationRequests cr on n.Account_AccountID=cr.AccountId
	left join core.Lookup l on l.LookupID=cr.StatusID 
	left join core.Lookup l1 on l1.LookupID=n.EnableM61Calculations
	left join core.Analysis aa on aa.AnalysisID=cr.AnalysisID
	Where aa.Analysisid=@DevScenario
) c on c.CRENoteID=n.CRENoteID

Where c.EnableM61Calculations='Y'
--and d.CalcEngineType=798
--and ABS((ISNULL((a.Value),0)- ISNULL((b.Value),0))) > 0.01




Select * from ##PeriodicOutputNPCColumn
Order by DealName, NoteID, PeriodEndDate
