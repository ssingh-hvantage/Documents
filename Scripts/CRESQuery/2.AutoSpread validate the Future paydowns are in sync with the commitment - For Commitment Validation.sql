Select * from(

Select dealname,credealid,UseRuletoDetermineNoteFunding,FuturePayDn
--,EndingBalance,FF
,AdjustedTotalCommitment,FuturePIKFunding
,ROUND(LHS,2) LHS,RHS_Commit,

ROUND(LHS,2) - ROUND(RHS_Commit ,2) as Delta,

(CASE WHEN ROUND(LHS,2) <= ROUND(RHS_Commit ,2) THEN 'No Validation' ELSE 'Validation' end) as Vaidation_Flag
from(
	Select Distinct d.dealname,d.credealid,(CASE WHEN tbl_Y_Deal.dealid is not null THEn 'Y' Else 'N' end) UseRuletoDetermineNoteFunding
	,ISNULL(tblFuPaydn.FuturePayDn,0) as FuturePayDn
	,ISNULL(tblCurrBls.EndingBalance,0) as EndingBalance
	,ISNULL(tblFuFund.FF,0) as FF
	,ISNULL(tblPIKTr.FuturePIKFunding,0) as FuturePIKFunding
	,ISNULL(tblAdComm.AdjustedTotalCommitment,0) as AdjustedTotalCommitment

	,ISNULL(tblFuPaydn.FuturePayDn,0) * -1 as LHS
	,ISNULL(tblCurrBls.EndingBalance,0) + ISNULL(tblFuFund.FF,0) + ISNULL(tblPIKTr.FuturePIKFunding,0)  as RHS_Bls

	,ISNULL(tblAdComm.AdjustedTotalCommitment,0)  + ISNULL(tblPIKTr.FuturePIKFunding,0)  as RHS_Commit
	from cre.deal d
	inner join cre.note n on n.dealid = d.dealid
	inner join core.account acc on acc.accountid = n.account_accountid
	left join(
		Select dealid,SUM(Amount) as FuturePayDn from cre.dealfunding 
		where purposeid <> 629 and Amount < 0 and [date] > getdate()
		group by dealid
	)tblFuPaydn on tblFuPaydn.dealid = d.dealid
	Left Join (
		 select n.dealid,SUM(ISNULL(EndingBalance,0))  as EndingBalance
		 from [CRE].[NotePeriodicCalc] np  
		 inner join cre.note n on n.noteid = np.noteid
		 where np.noteid = n.noteid 
		 and AnalysisID = 'C10F3372-0FC2-4861-A9F5-148F1F80804F'
		 and PeriodEndDate = CAST(getdate() as Date)  
		 group by n.dealid
	)tblCurrBls on tblCurrBls.dealid = d.dealid

	left join(
		Select dealid,SUM(Amount) as FF
		from cre.dealfunding 
		where Amount > 0 and [date] > getdate()
		group by dealid
	)tblFuFund on tblFuFund.dealid = d.dealid

	Left Join(
		Select d.dealid,(CASE WHEN SUM(tr.Amount) < 0 THEN SUM(tr.Amount) * -1 ELSE SUM(tr.Amount) END) as FuturePIKFunding 
		from cre.TransactionEntry tr
		inner join cre.note n on n.noteid = tr.noteid
		inner join cre.deal d on d.dealid = n.dealid
		where tr.AnalysisID ='C10F3372-0FC2-4861-A9F5-148F1F80804F'
		and [type] in ('PIKPrincipalFunding','PIKPrincipalPaid')
		--and tr.date > getdate()
		group by d.dealid
	)tblPIKTr on tblPIKTr.dealid = d.dealid 
	Left JOin(
		Select d.dealid,SUM(n.AdjustedTotalCommitment) as AdjustedTotalCommitment
		from cre.deal d
		inner join cre.note n on n.dealid = d.dealid
		inner join core.account acc on acc.accountid = n.account_accountid		 
		group by d.dealid
	)tblAdComm on tblAdComm.dealid = d.dealid 
	
	Left Join(
		Select Distinct d.dealid
		from cre.Note n
		inner join cre.Deal d on n.DealID = d.DealID
		where UseRuletoDetermineNoteFunding = 3
	)tbl_Y_Deal on tbl_Y_Deal.DealID = d.DealID

	where acc.isdeleted <> 1 and d.isdeleted <> 1
	and n.actualpayoffdate is null
	--and d.dealid = '7e1af9ce-4354-4e06-bfcc-4bd1b8dd78d2'
	
)a

)b where Vaidation_Flag = 'Validation' and ABS(Delta) > 1