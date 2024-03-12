DECLARE @StgScenario AS VARCHAR(100)='Default'
DECLARE @DevScenario AS VARCHAR(100)='Default'

if object_id('tempdb..##PeriodicOutputRecon') is not null drop table ##PeriodicOutputRecon

Select ISNULL(a.dealname,b.dealname) as DealName, ISNULL(a.credealid,b.credealid) as DealID, ISNULL(a.crenoteid,b.crenoteid) as NoteID, ISNULL(a.Type,b.Type) as Type, ISNULL(a.PeriodEndDate,b.PeriodEndDate) as PeriodEndDate, SUM(a.Value) as DevAmount ,SUM(b.Value) as StagAmount, 
(ISNULL(SUM(a.Value),0)- ISNULL(SUM(b.Value),0)) as Delta, 
ABS((ISNULL(SUM(a.Value),0)- ISNULL(SUM(b.Value),0))) as ABS_Delta, l3.Name as DEV_EngineType, ISNULL(c.Status,0) as Status, ISNULL(a.Scenario,NULL) as [DevScenario], ISNULL(b.Scenario,NULL) as [StgScenario], c.EnableM61Calculations
into ##PeriodicOutputRecon
from (
	Select * from dbo.vw_NotePariodicCalc_Unpivot
	Where Scenario=@DevScenario
) a
full outer join (
	Select * from dbo.vw_NotePariodicCalc_Unpivot_Staging
	Where Scenario=@StgScenario
) b on a.CreNoteID=b.CreNoteID and a.Type=b.type and a.PeriodEndDate=b.PeriodEndDate --and a.Scenario=b.Scenario

left join cre.Note n on n.CRENoteID=ISNULL(a.CreNoteID ,b.Crenoteid)
left join core.account acc on acc.accountID=n.account_accountID
left join cre.Deal d on d.DealID=n.DealID
left join core.Lookup l3 on l3.LookupID=d.CalcEngineType
left join (
	Select CreNoteID, l1.Name as EnableM61Calculations, ISNULL(l.Name,'') as Status, aa.Name as Analysis, PaymentDateBusinessDayLag 
	from cre.Note n
	left join core.CalculationRequests cr on n.Account_accountid=cr.accountid
	left join core.Lookup l on l.LookupID=cr.StatusID 
	left join core.Lookup l1 on l1.LookupID=n.EnableM61Calculations
	left join core.Analysis aa on aa.AnalysisID=cr.AnalysisID
	Where aa.Name='Default'
	) c on c.CRENoteID=n.CRENoteID

Where
ABS((ISNULL((a.Value),0)- ISNULL((b.Value),0))) > 0.1
 and c.EnableM61Calculations='Y'
and ISNULL(a.Type,b.type) in ('BeginningBalance','TotalFutureAdvancesForThePeriod','TotalDiscretionaryCurtailmentsforthePeriod','ScheduledPrincipal','PIKInterestAppliedForThePeriod','PIKPrincipalPaidForThePeriod','BalloonPayment','EndingBalance','ReversalofPriorInterestAccrual','CurrentPeriodInterestAccrual','CurrentPeriodPIKInterestAccrual','InterestReceivedinCurrentPeriod','TotalGAAPInterestFortheCurrentPeriod','CleanCost','GrossDeferredFees','AmortizedCost','TotalAmortAccrualForPeriod','CapitalizedCostAccrual','DiscountPremiumAccrual','AccumulatedAmort','DiscountPremiumAccumulatedAmort','CapitalizedCostAccumulatedAmort','InterestSuspenseAccountBalance','EndingGAAPBookValue')
--and n.ClosingDate>= '2022-06-01 00:00:00.000'
--and c.Status='Completed'
--and n.CRENoteID in ('24600')
--and a.type like '%AccumulatedAmort%'
 --and d.CREDealID not in ('18-0344')
Group by ISNULL(a.crenoteid,b.crenoteid), ISNULL(a.Scenario,NULL), ISNULL(b.Scenario,NULL), ISNULL(a.dealname,b.dealname),ISNULL(a.credealid,b.credealid),  ISNULL(a.crenoteid,b.crenoteid), ISNULL(a.Type,b.type), 
ISNULL(a.PeriodEndDate,b.PeriodEndDate),  l3.Name, c.EnableM61Calculations, c.Status

Select * from ##PeriodicOutputRecon
Order by DealName, NoteID, PeriodEndDate, Type
