Select * from (
	Select d.credealid,df.Date,df.PurposeID,l.name as PurposeType,SUM(df.Amount) as legal_Amount ,ph.Phantom_Amount,(SUM(df.Amount) - ph.Phantom_Amount) as Delta
	from cre.DealFunding df
	inner join cre.deal d on d.dealid = df.dealid
	left join core.Lookup l on l.lookupid = df.PurposeID
	inner join(
		Select d.credealid,d.linkeddealid,df.Date,df.PurposeID,SUM(df.Amount) as Phantom_Amount 
		from cre.DealFunding df
		inner join cre.deal d on d.dealid = df.dealid	
		where d.IsDeleted <> 1 
		and d.Status =325
		and d.linkeddealid is not null
		group by d.dealid,d.credealid,df.Date,df.PurposeID,d.linkeddealid
	)ph on d.CREDealID = ph.LinkedDealID and df.[Date] = ph.[Date] and df.PurposeID = ph.PurposeID 

	where d.IsDeleted <> 1  
	and d.Status =323
	group by d.dealid,d.credealid,df.Date,df.PurposeID,ph.Phantom_Amount,l.name
)a
where a.Delta <> 0 
and a.CREDealID in (

	Select distinct d.CREDealID from cre.deal d
	inner join cre.note n on n.DealID = d.dealid
	inner join core.Account acc on acc.AccountID = n.Account_AccountID
	where n.ActualPayoffDate is null and acc.IsDeleted <>1 and d.IsDeleted <> 1
	and d.Status =323
)


order by a.credealid,a.date



