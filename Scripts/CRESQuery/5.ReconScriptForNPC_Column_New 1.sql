DECLARE @DevScenario AS UNIQUEIDENTIFIER=(select AnalysisID From core.analysis where [name] = 'Default_CopyC#')
DECLARE @DevScenario_name AS nvarchar(256)=(select [name] From core.analysis where [name] = 'Default_CopyC#')

DECLARE @StgScenario AS UNIQUEIDENTIFIER=(select AnalysisID From core.analysis where [name] = 'Default_CopyV1')
DECLARE @StgScenario_name AS  nvarchar(256)=(select [name] From core.analysis where [name] = 'Default_CopyV1')

IF object_id('tempdb..##PeriodicOutputNPCColumn') is not null drop table ##PeriodicOutputNPCColumn

Select ISNULL(a.dealname,b.dealname) as DealName
,ISNULL(a.credealid,b.credealid) as DealID
,ISNULL(a.crenoteid,b.crenoteid) as NoteID
,ISNULL(a.Name,b.Name) as NoteName
,DevScenarioCalcRequest.Status as DevCalcStatus
,StgScenarioCalcRequest.Status as StgCalcStatus
,DevScenarioCalcRequest.CalcEngineType as DevCalcEngineType
,StgScenarioCalcRequest.CalcEngineType as StgCalcEngineType
,@DevScenario_name as [DevScenarioC#], @StgScenario_name as [StgScenarioV1]
, ISNULL(a.PeriodEndDate,b.PeriodEndDate) as PeriodEndDate

-- Beginning balance (D)
, ISNULL(a.BeginningBalance,0) as DEV_BeginningBalance
, ISNULL(b.BeginningBalance,0) as Stg_BeginningBalance
, (ISNULL(a.BeginningBalance,0) - ISNULL(b.BeginningBalance,0)) as Delta_BeginningBalance

--TotalFutureAdvancesForThePeriod (E)
, ISNULL(a.TotalFutureAdvancesForThePeriod,0) as DEV_TotalFutureAdvancesForThePeriod
, ISNULL(b.TotalFutureAdvancesForThePeriod,0) as Stg_TotalFutureAdvancesForThePeriod
, (ISNULL(a.TotalFutureAdvancesForThePeriod,0) - ISNULL(b.TotalFutureAdvancesForThePeriod,0)) as Delta_TotalFutureAdvancesForThePeriod

--  PIKInterestAppliedForThePeriod (F)
, ISNULL(a.PIKInterestAppliedForThePeriod,0) as DEV_PIKInterestAppliedForThePeriod
, ISNULL(b.PIKInterestAppliedForThePeriod,0) as Stg_PIKInterestAppliedForThePeriod
, (ISNULL(a.PIKInterestAppliedForThePeriod,0) - ISNULL(b.PIKInterestAppliedForThePeriod,0)) as Delta_PIKInterestAppliedForThePeriod

--   ScheduledPrincipal (G)
, ISNULL(a. ScheduledPrincipal,0) as DEV_ScheduledPrincipal
, ISNULL(b.ScheduledPrincipal,0) as Stg_ScheduledPrincipal
, (ISNULL(a.ScheduledPrincipal,0) - ISNULL(b.ScheduledPrincipal,0)) as Delta_ScheduledPrincipal

--   TotalDiscretionaryCurtailmentsforthePeriod   (H)
, ISNULL(a.TotalDiscretionaryCurtailmentsforthePeriod,0) as DEV_TotalDiscretionaryCurtailmentsforthePeriod
, ISNULL(b.TotalDiscretionaryCurtailmentsforthePeriod,0) as Stg_TotalDiscretionaryCurtailmentsforthePeriod
, (ISNULL(a.TotalDiscretionaryCurtailmentsforthePeriod,0) - ISNULL(b.TotalDiscretionaryCurtailmentsforthePeriod,0)) as Delta_TotalDiscretionaryCurtailmentsforthePeriod

--   BalloonPayment  (I)
, ISNULL(a.BalloonPayment,0) as DEV_BalloonPayment
, ISNULL(b.BalloonPayment,0) as Stg_BalloonPayment
, (ISNULL(a.BalloonPayment,0) - ISNULL(b.BalloonPayment,0)) as Delta_BalloonPayment

--    EndingBalance   (J)
, ISNULL(a.EndingBalance,0) as DEV_EndingBalance
, ISNULL(b.EndingBalance,0) as Stg_EndingBalance
, (ISNULL(a.EndingBalance,0) - ISNULL(b.EndingBalance,0)) as Delta_EndingBalance

--   BalanceCheck  =SUM(D3:F3,-G3,H3:I3)-J3 (K)
,  (ISNULL(a.BeginningBalance,0)+ISNULL(a.TotalFutureAdvancesForThePeriod,0)+ISNULL(a.PIKInterestAppliedForThePeriod,0)-ISNULL(a. ScheduledPrincipal,0)+ISNULL(a.TotalDiscretionaryCurtailmentsforthePeriod,0)+ISNULL(a.BalloonPayment,0)-ISNULL(a.EndingBalance,0)) as DEV_BalanceCheck
,  (ISNULL(b.BeginningBalance,0)+ISNULL(b.TotalFutureAdvancesForThePeriod,0)+ISNULL(b.PIKInterestAppliedForThePeriod,0)-ISNULL(b. ScheduledPrincipal,0)+ISNULL(b.TotalDiscretionaryCurtailmentsforthePeriod,0)+ISNULL(b.BalloonPayment,0)-ISNULL(b.EndingBalance,0)) as Std_BalanceCheck
,  ((ISNULL(a.BeginningBalance,0)+ISNULL(a.TotalFutureAdvancesForThePeriod,0)+ISNULL(a.PIKInterestAppliedForThePeriod,0)-ISNULL(a. ScheduledPrincipal,0)+ISNULL(a.TotalDiscretionaryCurtailmentsforthePeriod,0)+ISNULL(a.BalloonPayment,0)-ISNULL(a.EndingBalance,0)) - 
  (ISNULL(b.BeginningBalance,0)+ISNULL(b.TotalFutureAdvancesForThePeriod,0)+ISNULL(b.PIKInterestAppliedForThePeriod,0)-ISNULL(b. ScheduledPrincipal,0)+ISNULL(b.TotalDiscretionaryCurtailmentsforthePeriod,0)+ISNULL(b.BalloonPayment,0)-ISNULL(b.EndingBalance,0)))  as Delta_BalanceCheck
 
 --    GrossDeferredFees   (L)
, ISNULL(a.GrossDeferredFees,0) as DEV_GrossDeferredFees
, ISNULL(b.GrossDeferredFees,0) as Stg_GrossDeferredFees
, (ISNULL(a.GrossDeferredFees,0) - ISNULL(b.GrossDeferredFees,0)) as Delta_GrossDeferredFees

 --    CleanCost   (M)
, ISNULL(a.CleanCost,0) as DEV_CleanCost
, ISNULL(b.CleanCost,0) as Stg_CleanCost
, (ISNULL(a.CleanCost,0) - ISNULL(b.CleanCost,0)) as Delta_CleanCost

 --    AccumulatedAmort   (O)
, ISNULL(a.AccumulatedAmort,0) as DEV_AccumulatedAmort
, ISNULL(b.AccumulatedAmort,0) as Stg_AccumulatedAmort
, (ISNULL(a.AccumulatedAmort,0) - ISNULL(b.AccumulatedAmort,0)) as Delta_AccumulatedAmort

 --    DiscountPremiumAccrual   (P)
, ISNULL(a.DiscountPremiumAccrual,0) as DEV_DiscountPremiumAccrual
, ISNULL(b.DiscountPremiumAccrual,0) as Stg_DiscountPremiumAccrual
, (ISNULL(a.DiscountPremiumAccrual,0) - ISNULL(b.DiscountPremiumAccrual,0)) as Delta_DiscountPremiumAccrual

 --    DiscountPremiumAccumulatedAmort   (Q)
, ISNULL(a.DiscountPremiumAccumulatedAmort,0) as DEV_DiscountPremiumAccumulatedAmort
, ISNULL(b.DiscountPremiumAccumulatedAmort,0) as Stg_DiscountPremiumAccumulatedAmort
, (ISNULL(a.DiscountPremiumAccumulatedAmort,0) - ISNULL(b.DiscountPremiumAccumulatedAmort,0)) as Delta_DiscountPremiumAccumulatedAmort

 --    CapitalizedCostAccrual   (R)
, ISNULL(a.CapitalizedCostAccrual,0) as DEV_CapitalizedCostAccrual
, ISNULL(b.CapitalizedCostAccrual,0) as Stg_CapitalizedCostAccrual
, (ISNULL(a.CapitalizedCostAccrual,0) - ISNULL(b.CapitalizedCostAccrual,0)) as Delta_CapitalizedCostAccrual

 --    CapitalizedCostAccumulatedAmort   (S)
, ISNULL(a.CapitalizedCostAccumulatedAmort,0) as DEV_CapitalizedCostAccumulatedAmort
, ISNULL(b.CapitalizedCostAccumulatedAmort,0) as Stg_CapitalizedCostAccumulatedAmort
, (ISNULL(a.CapitalizedCostAccumulatedAmort,0) - ISNULL(b.CapitalizedCostAccumulatedAmort,0)) as Delta_CapitalizedCostAccumulatedAmort

 --    AmortizedCost   (T)
, ISNULL(a.AmortizedCost,0) as DEV_AmortizedCost
, ISNULL(b.AmortizedCost,0) as Stg_AmortizedCost
, (ISNULL(a.AmortizedCost,0) - ISNULL(b.AmortizedCost,0)) as Delta_AmortizedCost
 
 --    AmortizedCostCheck   (U) =M3+O3+Q3+S3-T3
, (ISNULL(a.CleanCost,0)+ISNULL(a.DiscountPremiumAccrual,0)+ISNULL(a.DiscountPremiumAccumulatedAmort,0)+ISNULL(a.CapitalizedCostAccumulatedAmort,0)-ISNULL(a.AmortizedCost,0)) as DEV_AmortizedCostCheck
, (ISNULL(b.CleanCost,0)+ ISNULL(b.DiscountPremiumAccrual,0)+ISNULL(b.DiscountPremiumAccumulatedAmort,0)+ISNULL(b.CapitalizedCostAccumulatedAmort,0)-ISNULL(b.AmortizedCost,0))as Stg_AmortizedCostCheck
, ((ISNULL(a.CleanCost,0)+ISNULL(a.DiscountPremiumAccrual,0)+ISNULL(a.DiscountPremiumAccumulatedAmort,0)+ISNULL(a.CapitalizedCostAccumulatedAmort,0)-ISNULL(a.AmortizedCost,0)) -
 (ISNULL(b.CleanCost,0)+ ISNULL(b.DiscountPremiumAccrual,0)+ISNULL(b.DiscountPremiumAccumulatedAmort,0)+ISNULL(b.CapitalizedCostAccumulatedAmort,0)-ISNULL(b.AmortizedCost,0))) as Delta_AmortizedCostCheck
   
 --    CurrentPeriodPIKInterestAccrual   (V)
, ISNULL(a.CurrentPeriodPIKInterestAccrual,0) as DEV_CurrentPeriodPIKInterestAccrual
, ISNULL(b.CurrentPeriodPIKInterestAccrual,0) as Stg_CurrentPeriodPIKInterestAccrual
, (ISNULL(a.CurrentPeriodPIKInterestAccrual,0) - ISNULL(b.CurrentPeriodPIKInterestAccrual,0)) as Delta_CurrentPeriodPIKInterestAccrual

 --    CurrentPeriodInterestAccrual   (W)
, ISNULL(a.CurrentPeriodInterestAccrual,0) as DEV_CurrentPeriodInterestAccrual
, ISNULL(b.CurrentPeriodInterestAccrual,0) as Stg_CurrentPeriodInterestAccrual
, (ISNULL(a.CurrentPeriodInterestAccrual,0) - ISNULL(b.CurrentPeriodInterestAccrual,0)) as Delta_CurrentPeriodInterestAccrual

 --    InterestSuspenseAccountBalance   (X)
, ISNULL(a.InterestSuspenseAccountBalance,0) as DEV_InterestSuspenseAccountBalance
, ISNULL(b.InterestSuspenseAccountBalance,0) as Stg_InterestSuspenseAccountBalance
, (ISNULL(a.InterestSuspenseAccountBalance,0) - ISNULL(b.InterestSuspenseAccountBalance,0)) as Delta_InterestSuspenseAccountBalance

 --    EndingGAAPBookValue   (Y)
, ISNULL(a.EndingGAAPBookValue,0) as DEV_EndingGAAPBookValue
, ISNULL(b.EndingGAAPBookValue,0) as Stg_EndingGAAPBookValue
, (ISNULL(a.EndingGAAPBookValue,0) - ISNULL(b.EndingGAAPBookValue,0)) as Delta_EndingGAAPBookValue

 --    GAAPBasisCheck   (Z) =T3+W3-X3+V3-Y3
, (ISNULL(a.AmortizedCost,0)+ISNULL(a.CurrentPeriodInterestAccrual,0)-ISNULL(a.InterestSuspenseAccountBalance,0)+ISNULL(a.CurrentPeriodPIKInterestAccrual,0)-ISNULL(a.EndingGAAPBookValue,0)) as DEV_GAAPBasisCheck
, (ISNULL(b.AmortizedCost,0)+ISNULL(b.CurrentPeriodInterestAccrual,0)-ISNULL(b.InterestSuspenseAccountBalance,0)+ISNULL(b.CurrentPeriodPIKInterestAccrual,0)-ISNULL(b.EndingGAAPBookValue,0)) as Stg_GAAPBasisCheck
, ((ISNULL(a.AmortizedCost,0)+ISNULL(a.CurrentPeriodInterestAccrual,0)-ISNULL(a.InterestSuspenseAccountBalance,0)+ISNULL(a.CurrentPeriodPIKInterestAccrual,0)-ISNULL(a.EndingGAAPBookValue,0)) -
 (ISNULL(b.AmortizedCost,0)+ISNULL(b.CurrentPeriodInterestAccrual,0)-ISNULL(b.InterestSuspenseAccountBalance,0)+ISNULL(b.CurrentPeriodPIKInterestAccrual,0)-ISNULL(b.EndingGAAPBookValue,0))) as Delta_GAAPBasisCheck
 
 --    InvestmentBasis   (AA)
, ISNULL(a.InvestmentBasis,0) as DEV_InvestmentBasis
, ISNULL(b.InvestmentBasis,0) as Stg_InvestmentBasis
, (ISNULL(a.InvestmentBasis,0) - ISNULL(b.InvestmentBasis,0)) as Delta_InvestmentBasis

-- --    PVDeltaAmt   (AB)
--, ISNULL(a.PVDeltaAmt,0) as DEV_EndingGAAPBookValue
--, ISNULL(b.EndingGAAPBookValue,0) as Stg_EndingGAAPBookValue
--, (ISNULL(a.EndingGAAPBookValue,0) - ISNULL(b.EndingGAAPBookValue,0)) as Delta_EndingGAAPBookValue

-- --    PVDeltaPct   (AC)
--, ISNULL(a.PVDeltaPct,0) as DEV_EndingGAAPBookValue
--, ISNULL(b.EndingGAAPBookValue,0) as Stg_EndingGAAPBookValue
--, (ISNULL(a.EndingGAAPBookValue,0) - ISNULL(b.EndingGAAPBookValue,0)) as Delta_EndingGAAPBookValue

 --    CleanCostPrice   (AD)
, ISNULL(a.CleanCostPrice,0) as DEV_CleanCostPrice
, ISNULL(b.CleanCostPrice,0) as Stg_CleanCostPrice
, (ISNULL(a.CleanCostPrice,0) - ISNULL(b.CleanCostPrice,0)) as Delta_CleanCostPrice

 --    AmortizedCostPrice   (AE)
, ISNULL(a.AmortizedCostPrice,0) as DEV_AmortizedCostPrice
, ISNULL(b.AmortizedCostPrice,0) as Stg_AmortizedCostPrice
, (ISNULL(a.AmortizedCostPrice,0) - ISNULL(b.AmortizedCostPrice,0)) as Delta_AmortizedCostPrice

 --    ReversalofPriorInterestAccrual   (AF)
, ISNULL(a.ReversalofPriorInterestAccrual,0) as DEV_ReversalofPriorInterestAccrual
, ISNULL(b.ReversalofPriorInterestAccrual,0) as Stg_ReversalofPriorInterestAccrual
, (ISNULL(a.ReversalofPriorInterestAccrual,0) - ISNULL(b.ReversalofPriorInterestAccrual,0)) as Delta_ReversalofPriorInterestAccrual

 --    InterestReceivedinCurrentPeriod   (AG)
, ISNULL(a.InterestReceivedinCurrentPeriod,0) as DEV_InterestReceivedinCurrentPeriod
, ISNULL(b.InterestReceivedinCurrentPeriod,0) as Stg_InterestReceivedinCurrentPeriod
, (ISNULL(a.InterestReceivedinCurrentPeriod,0) - ISNULL(b.InterestReceivedinCurrentPeriod,0)) as Delta_InterestReceivedinCurrentPeriod

-- --    CurrentPeriodPIKInterestAccrual   (AH)
--, ISNULL(a.CurrentPeriodPIKInterestAccrual,0) as DEV_CurrentPeriodPIKInterestAccrual
--, ISNULL(b.CurrentPeriodPIKInterestAccrual,0) as Stg_CurrentPeriodPIKInterestAccrual
--, (ISNULL(a.CurrentPeriodPIKInterestAccrual,0) - ISNULL(b.CurrentPeriodPIKInterestAccrual,0)) as Delta_CurrentPeriodPIKInterestAccrual

-- --    CurrentPeriodInterestAccrual   (AI)
--, ISNULL(a.CurrentPeriodInterestAccrual,0) as DEV_CurrentPeriodInterestAccrual
--, ISNULL(b.CurrentPeriodInterestAccrual,0) as Stg_CurrentPeriodInterestAccrual
--, (ISNULL(a.CurrentPeriodInterestAccrual,0) - ISNULL(b.CurrentPeriodInterestAccrual,0)) as Delta_CurrentPeriodInterestAccrual

-- --    InterestSuspenseAccountBalance   (AJ)
--, ISNULL(a.InterestSuspenseAccountBalance,0) as DEV_InterestSuspenseAccountBalance
--, ISNULL(b.InterestSuspenseAccountBalance,0) as Stg_InterestSuspenseAccountBalance
--, (ISNULL(a.InterestSuspenseAccountBalance,0) - ISNULL(b.InterestSuspenseAccountBalance,0)) as Delta_InterestSuspenseAccountBalance

 --    TotalGAAPInterestFortheCurrentPeriod   (AK)
, ISNULL(a.TotalGAAPInterestFortheCurrentPeriod,0) as DEV_TotalGAAPInterestFortheCurrentPeriod
, ISNULL(b.TotalGAAPInterestFortheCurrentPeriod,0) as Stg_TotalGAAPInterestFortheCurrentPeriod
, (ISNULL(a.TotalGAAPInterestFortheCurrentPeriod,0) - ISNULL(b.TotalGAAPInterestFortheCurrentPeriod,0)) as Delta_TotalGAAPInterestFortheCurrentPeriod
 
 --    TotalGAAPIncomeCheck   (AL) =SUM(AF3:AI3, -AJ3)-AK3
, (ISNULL(a.ReversalofPriorInterestAccrual,0)+ISNULL(a.InterestReceivedinCurrentPeriod,0)+ISNULL(a.CurrentPeriodPIKInterestAccrual,0)+ISNULL(a.CurrentPeriodInterestAccrual,0)-ISNULL(a.InterestSuspenseAccountBalance,0)-ISNULL(a.TotalGAAPInterestFortheCurrentPeriod,0)) as DEV_TotalGAAPIncomeCheck
, (ISNULL(b.ReversalofPriorInterestAccrual,0)+ISNULL(b.InterestReceivedinCurrentPeriod,0)+ISNULL(b.CurrentPeriodPIKInterestAccrual,0)+ISNULL(b.CurrentPeriodInterestAccrual,0)-ISNULL(b.InterestSuspenseAccountBalance,0)-ISNULL(b.TotalGAAPInterestFortheCurrentPeriod,0)) as Stg_TotalGAAPIncomeCheck
,((ISNULL(a.ReversalofPriorInterestAccrual,0)+ISNULL(a.InterestReceivedinCurrentPeriod,0)+ISNULL(a.CurrentPeriodPIKInterestAccrual,0)+ISNULL(a.CurrentPeriodInterestAccrual,0)-ISNULL(a.InterestSuspenseAccountBalance,0)-ISNULL(a.TotalGAAPInterestFortheCurrentPeriod,0)) -
  (ISNULL(b.ReversalofPriorInterestAccrual,0)+ISNULL(b.InterestReceivedinCurrentPeriod,0)+ISNULL(b.CurrentPeriodPIKInterestAccrual,0)+ISNULL(b.CurrentPeriodInterestAccrual,0)-ISNULL(b.InterestSuspenseAccountBalance,0)-ISNULL(b.TotalGAAPInterestFortheCurrentPeriod,0))) as Delta_TotalGAAPIncomeCheck


-- --    GAAPCalculated   (J)
--, ISNULL(a.GAAPCalculated,0) as DEV_EndingGAAPBookValue
--, ISNULL(b.EndingGAAPBookValue,0) as Stg_EndingGAAPBookValue
--, (ISNULL(a.EndingGAAPBookValue,0) - ISNULL(b.EndingGAAPBookValue,0)) as Delta_EndingGAAPBookValue
--
-- --    Delta   (J)
--, ISNULL(a.Delta,0) as DEV_EndingGAAPBookValue
--, ISNULL(b.EndingGAAPBookValue,0) as Stg_EndingGAAPBookValue
--, (ISNULL(a.EndingGAAPBookValue,0) - ISNULL(b.EndingGAAPBookValue,0)) as Delta_EndingGAAPBookValue

into ##PeriodicOutputNPCColumn
from (
	Select d.dealname,d.credealid,n.CreNoteID,acc.name,nc.Accountid,nc.PeriodEndDate,nc.BeginningBalance,nc.TotalFutureAdvancesForThePeriod,nc.PIKInterestAppliedForThePeriod,ScheduledPrincipal
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
	--and n.CRENoteID = '24208'
) a
full outer join (
	Select d.dealname,d.credealid,n.CreNoteID,acc.name,nc.Accountid,nc.PeriodEndDate,nc.BeginningBalance,nc.TotalFutureAdvancesForThePeriod,nc.PIKInterestAppliedForThePeriod,ScheduledPrincipal
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
	--and n.CRENoteID = '24208'

) b on a.CreNoteID=b.CreNoteID and a.PeriodEndDate=b.PeriodEndDate 

left join cre.Note n on n.CRENoteID=ISNULL(a.CreNoteID ,b.Crenoteid)
left join core.account acc on acc.accountID=n.account_accountID
left join cre.Deal d on d.DealID=n.DealID

left join (
	Select CreNoteID, l1.Name as EnableM61Calculations, l.Name as Status, aa.Name as Analysis,  l3.Name as CalcEngineType
	from cre.Note n
	left join core.CalculationRequests cr on n.Account_AccountID=cr.AccountId
	left join core.Lookup l on l.LookupID=cr.StatusID 
	left join core.Lookup l1 on l1.LookupID=n.EnableM61Calculations
	left join core.Lookup l3 on l3.LookupID=cr.CalcEngineType
	left join core.Analysis aa on aa.AnalysisID=cr.AnalysisID
	Where aa.Analysisid=@StgScenario
) StgScenarioCalcRequest on StgScenarioCalcRequest.CRENoteID=n.CRENoteID

left join (
	Select CreNoteID, l1.Name as EnableM61Calculations, l.Name as Status, aa.Name as Analysis, l3.Name as CalcEngineType
	from cre.Note n
	left join core.CalculationRequests cr on n.Account_AccountID=cr.AccountId
	left join core.Lookup l on l.LookupID=cr.StatusID 
	left join core.Lookup l1 on l1.LookupID=n.EnableM61Calculations
	left join core.Lookup l3 on l3.LookupID=cr.CalcEngineType
	left join core.Analysis aa on aa.AnalysisID=cr.AnalysisID
	Where aa.Analysisid=@DevScenario
) DevScenarioCalcRequest on DevScenarioCalcRequest.CRENoteID=n.CRENoteID

Where DevScenarioCalcRequest.EnableM61Calculations='Y'
and StgScenarioCalcRequest.CalcEngineType='V1 (New)'
--and ISNULL(a.CRENoteID,b.CRENoteID)='12399'
--and ISNULL(a.CREDealeID,b.CREDealID)='18-0344'
--and ABS((ISNULL((a.Value),0)- ISNULL((b.Value),0))) > 0.01

Select * from ##PeriodicOutputNPCColumn
Order by DealName, NoteID, PeriodEndDate
