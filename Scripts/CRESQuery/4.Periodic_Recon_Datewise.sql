--Periodic_Recon_Datewise
DECLARE @AnalysisID_dev AS VARCHAR(100)='C10F3372-0FC2-4861-A9F5-148F1F80804F'
DECLARE @AnalysisID_Stg AS VARCHAR(100)='C10F3372-0FC2-4861-A9F5-148F1F80804F'
DECLARE @AnalysisNameDev nvarchar(256);
DECLARE @AnalysisNameStg nvarchar(256);
SET @AnalysisNameDev = (Select Name from core.analysis where analysisid = @AnalysisID_dev)
SET @AnalysisNameStg = (Select Name from core.analysis where analysisid = @AnalysisID_Stg)

if object_id('tempdb..##PortfolioRecon1') is not null drop table ##PortfolioRecon1
Select d.DealName,d.CREDealID, n.CRENoteID, ISNULL(a.Type,b.type) as [Type],a.date as DEV_Date, b.date as STG_Date, DEV_Amount,STG_Amount, 
(ISNULL(DEV_Amount,0)- ISNULL(STG_Amount,0)) as Delta,
ABS((ISNULL(DEV_Amount,0)- ISNULL(STG_Amount,0))) as ABS_Delta,n.ClosingDate, ISNULL(n.ActualPayoffDate,'') as PayoffDate, l3.Name as DEV_EngineType, c.Status as Calculation_Status, @AnalysisNameDev as Dev_Scenario,@AnalysisNameStg as Staging_Scenario, l2.Name as Note_Status, pik.PIK_Note, le.Name as EnableM61Calculations --, IOTermEndDate_Dev, TransactionDateByRule_Dev, TransactionDateByRule_Stg , RemitDate_Dev,RemitDate_Stg,  FeeTypeName_Dev , FeeTypeName_Stg
into ##PortfolioRecon1
from (
	Select n.NoteID, Type, date,SUM(Amount) as Dev_Amount,AnalysisID ,IOTermEndDate as IOTermEndDate_Dev, transactionDateByRule as transactionDateByRule_Dev, RemitDate as RemitDate_Dev, FeeTypeName as FeeTypeName_Dev
	from Cre.TransactionEntry te
	Inner Join cre.note n on n.account_accountid = te.AccountID
	Where AnalysisID=@AnalysisID_dev
	and type not in ('LIBORPercentage','SpreadPercentage','PIKInterestPercentage','PIKLiborPercentage')
	--and te.noteid = 'B940AD6F-631B-4C5D-8871-9BEF7C6F5AE2'
	Group by n.NoteID, Type, date, AnalysisID , IOTermEndDate, transactionDateByRule , RemitDate , FeeTypeName
) a
full outer join (
	
	Select NoteID, Type,date, SUM(Amount) as Stg_Amount, AnalysisID--, transactionDateByRule as transactionDateByRule_Stg, RemitDate as RemitDate_Stg, FeeTypeName as FeeTypeName_Stg
	from Dw.Staging_TransactionEntry ste
	Where AnalysisID=@AnalysisID_Stg
	and type not in ('LIBORPercentage','SpreadPercentage','PIKInterestPercentage','PIKLiborPercentage')
	--and ste.noteid = 'B940AD6F-631B-4C5D-8871-9BEF7C6F5AE2'
	Group by NoteID, Type,date, AnalysisID , transactionDateByRule, RemitDate , FeeTypeName 

	UNION

	Select ste.NoteID, Type,ste.date, SUM(Amount) as Stg_Amount, ste.AnalysisID--, transactionDateByRule as transactionDateByRule_Stg, RemitDate as RemitDate_Stg, FeeTypeName as FeeTypeName_Stg
	from Dw.Staging_TransactionEntry ste
	inner join(

		Select distinct ste1.NoteID, ste1.date,ste1.AnalysisID
		from Dw.Staging_TransactionEntry ste1
		Where ste1.AnalysisID=@AnalysisID_Stg
		and ste1.type in ('InterestPaid','PIKInterest','PIKInterestPaid','StubInterest','PurchasedInterest')

	)a on a.noteid = ste.noteid and a.analysisid = ste.analysisid and ste.date = a.date

	Where ste.AnalysisID=@AnalysisID_Stg
	and [type] in ('LIBORPercentage','SpreadPercentage','PIKInterestPercentage','PIKLiborPercentage')
	--and ste.noteid = 'B940AD6F-631B-4C5D-8871-9BEF7C6F5AE2'
	Group by ste.NoteID, Type,ste.date, ste.AnalysisID , transactionDateByRule, RemitDate , FeeTypeName 

) b on a.NoteID=b.NoteID and a.Type=b.type and a.date=b.date 

left join cre.Note n on n.NoteID=ISNULL(a.NoteID ,b.noteid)
left join core.account acc on acc.accountID=n.account_accountID
left join cre.Deal d on d.DealID=n.DealID
left join core.Lookup le on le.LookupID=n.EnableM61Calculations
left join core.Lookup l2 on l2.LookupID=acc.StatusID
left join core.Lookup l3 on l3.LookupID=d.CalcEngineType
left join (
Select CreNoteID, l.Name as Status from cre.Note n
	left join core.CalculationRequests cr on n.Account_accountid=cr.AccountID
	left join core.Lookup l on l.LookupID=cr.StatusID 
	Where cr.AnalysisID=@AnalysisID_dev
) c on c.CRENoteID=n.CRENoteID 
left join (  Select CRENoteID, 'PIK' as PIK_Note from(
	select n.noteid,n.crenoteid,
	(Select count(piks.StartDate) from Core.[PIKSchedule] piks
	inner join core.Event e on e.EventID = piks.EventId
	inner join core.Account acc on acc.AccountID = e.AccountID
	where e.EventTypeID = 12 and acc.IsDeleted<>1
	and acc.AccountID = n.account_accountid) PIKSchedule
	from cre.Note n
	)a
	where a.PIKSchedule = 1 
) pik on pik.CRENoteID=n.CRENoteID 

Where acc.isdeleted <> 1 
and (iSNULL(a.AnalysisID,b.AnalysisID) =@AnalysisID_dev  OR iSNULL(a.AnalysisID,b.AnalysisID) =@AnalysisID_Stg)
and n.EnableM61Calculations=3

--and ISNULL(a.Type,b.type)  like '%PIKInt%'
and ISNULL(a.Type,b.type) NOT in( 'EndingPVGAAPBookValue','UnusedFeeExcludedFromLevelYield','PIKInterestPercentage','LIBORPercentage','SpreadPercentage','PIKInterestPercentage','PIKLiborPercentage')
and ABS((ISNULL(Dev_Amount,0)- ISNULL(Stg_Amount,0))) > 0.1
--and n.ClosingDate>= '2022-06-01 00:00:00.000'
--and c.Status='Completed'
--and n.CRENoteID in ('23198')
--and n.CRENoteID in (
--		Select CreNoteID 
--		from Cre.Note n
--		left join core.Account acc on acc.AccountID=n.Account_AccountID
--		Where acc.IsDeleted<>1 and PIKInterestAddedToBalanceBasedOnBusinessAdjustedDate is not NULL)
--and d.DealName not like '%Copy%'
--and d.CREDealID not in ('23-0575','21-1871','22-3554','19-1166','21-2694')
--and d.CREDealID in (
		----Select CREDealID
		----from cre.Deal d
		----Where CalcEngineType=798 and d.IsDeleted<>1
--)
--and c.Status like '%Failed%'
--Order by d.DealName, CRENoteID,[Type]

Select * from ##PortfolioRecon1
Order by DealName, CRENoteID, ISNULL(DEV_Date, STG_Date), [Type]

--select Distinct DealName , CRENoteID, Calculation_Status from ##PortfolioRecon1
--Group by DealName, CRENoteID, Calculation_Status
--Order by DealName, CRENoteID