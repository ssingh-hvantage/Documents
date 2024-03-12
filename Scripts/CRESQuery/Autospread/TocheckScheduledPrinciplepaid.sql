Declare @AnalysisID UNIQUEIDENTIFIER;
SET @AnalysisID = (Select AnalysisID from core.analysis where name = 'Default')

Select d.dealid as DealID,tr.Date,[Type],SUM(tr.Amount) as Amount
from cre.TransactionEntry tr
inner join cre.note n on n.noteid = tr.noteid
inner join cre.deal d on d.dealid = n.dealid
where tr.AnalysisID ='C10F3372-0FC2-4861-A9F5-148F1F80804F
'
and [type] in ('PIKPrincipalFunding','PIKPrincipalPaid','ScheduledPrincipalPaid')
and d.dealid = 'af44b297-36fb-4217-bbd3-0283652aa1fb'
group by d.dealid,tr.Date,[Type] 