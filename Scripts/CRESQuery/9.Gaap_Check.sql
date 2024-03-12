Select CreNoteid ,
			PeriodEndDate ,
			EndingGAAPBookValue ,
			CalcGAAP= (Cleancost-InterestSuspenseAccountBalance+[AccumaltedDiscountPremiumBI]+ [CurrentPeriodPIKInterestAccrualPeriodEnddate]+[CurrentPeriodInterestAccrualPeriodEnddate]+ AccumulatedAmort+[AccumalatedCapitalizedCostBI]),
			EndingGAAPBookValue-((Cleancost-InterestSuspenseAccountBalance+[AccumaltedDiscountPremiumBI]+ [CurrentPeriodPIKInterestAccrualPeriodEnddate]+[CurrentPeriodInterestAccrualPeriodEnddate]+ AccumulatedAmort+[AccumalatedCapitalizedCostBI])) as Delta,
			CleanCost,
			InterestSuspenseAccountBalance,
			AccumaltedDiscountPremiumBI ,
			CurrentPeriodPIKInterestAccrualPeriodEnddate ,
			CurrentPeriodInterestAccrualPeriodEnddate ,
			AccumulatedAmort ,
			AccumalatedCapitalizedCostBI
			From(
			Select
			CreNoteid
			,n.[NoteID]
			, [PeriodEndDate]
			, EndingGAAPBookValue
			,ISNULL(CleanCost,0) as CleanCost
			,ISNULL([CurrentPeriodPIKInterestAccrualPeriodEnddate],0) as CurrentPeriodPIKInterestAccrualPeriodEnddate
			,SUM(ISNULL(nc.CapitalizedCostAccrual,0)) OVER(PARTITION BY nc.AnalysisID,n.NoteID ORDER BY nc.AnalysisID,n.NoteID,nc.PeriodEndDate ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS AccumalatedCapitalizedCostBI
			,ISNULL([CurrentPeriodInterestAccrualPeriodEnddate],0) as CurrentPeriodInterestAccrualPeriodEnddate
			,SUM(ISNULL(nc.DiscountPremiumAccrual,0)) OVER(PARTITION BY nc.AnalysisID,n.NoteID ORDER BY nc.AnalysisID,n.NoteID,nc.PeriodEndDate ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS AccumaltedDiscountPremiumBI
			,ISNULL(AccumulatedAmort,0) as AccumulatedAmort
			,ISNULL(InterestSuspenseAccountBalance,0) as InterestSuspenseAccountBalance		

			from [cre].[NotePeriodicCalc] Nc 
			Inner join cre.Note n on n.Account_AccountID = nc.AccountID
			Inner JOin core.account acc on acc.accountid = n.account_accountid
			Where acc.isdeleted <> 1
			and nc.Month is not null		
			and Periodenddate = eomonth (Periodenddate,0)
			and Periodenddate <> ISNULL(eomonth(n.ActualPayoffdate,0),eomonth(n.FullyextendedMaturitydate,0))	
			and Analysisid = 'c10f3372-0fc2-4861-a9f5-148f1f80804f' 
			--and EndingGAAPBookValue <> 0
			--and n.CRENoteID = '10000'
			and EnableM61Calculations=3
			)a
			Order by CRENoteID, PeriodEndDate