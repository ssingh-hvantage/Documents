Select n.crenoteid, tr.noteid,SUM(tr.Amount) as SumPikAmount
	from cre.transactionEntry Tr
	inner join cre.note n on n.noteid=tr.noteid 
	where tr.analysisID =  'C10F3372-0FC2-4861-A9F5-148F1F80804F' and tr.[Type] in ('PikPrincipalPaid','PIKPrincipalFunding')
	--and tr.date <= CAST(getdate() as date)
	and n.dealid = 'b0d68793-ba74-4097-8349-8e837711b70f'
	group by tr.noteid,n.crenoteid
