SELECT * 
FROM (		
		SELECT  dd.DealID
			   ,dd.DealName 
			   ,dd.credealid
			   ,SUM(Amount) as DealFundingAmount
			   ,NoteFundingAmount
			   ,(SUM(Amount) - NoteFundingAmount) as Delta
		FROM  [CRE].[DealFunding] df
		inner join cre.deal dd on dd.dealid = df.dealid
		INNER JOIN 
			(
			Select 
			 d.DealID,
			 SUM(fs.Value) as NoteFundingAmount
			from [CORE].FundingSchedule fs
			INNER JOIN [CORE].[Event] e on e.EventID = fs.EventId
			INNER JOIN 
						(
							Select 
								(Select AccountID from [CORE].[Account] ac where ac.AccountID = n.Account_AccountID) AccountID ,
								MAX(EffectiveStartDate) EffectiveStartDate,EventTypeID ,eve.StatusID
								from [CORE].[Event] eve
								INNER JOIN [CRE].[Note] n ON n.Account_AccountID = eve.AccountID
								INNER JOIN [CORE].[Account] acc ON acc.AccountID = n.Account_AccountID
								where EventTypeID = (Select LookupID from CORE.[Lookup] where Name = 'FundingSchedule')
								--and n.CRENoteID = '3394' 
								and acc.IsDeleted = 0
								and eve.StatusID = (Select LookupID from Core.Lookup where name = 'Active' and ParentID = 1)
								GROUP BY n.Account_AccountID,EventTypeID,eve.StatusID
						) sEvent
			
			ON sEvent.AccountID = e.AccountID and e.EffectiveStartDate = sEvent.EffectiveStartDate  and e.EventTypeID = sEvent.EventTypeID
			left JOIN [CORE].[Lookup] LEventTypeID ON LEventTypeID.LookupID = e.EventTypeID
			left JOIN [CORE].[Lookup] LPurposeID ON LPurposeID.LookupID = fs.PurposeID 
			INNER JOIN [CORE].[Account] acc ON acc.AccountID = e.AccountID
			INNER JOIN [CRE].[Note] n ON n.Account_AccountID = acc.AccountID
			INNER JOIN [CRE].[Deal] d ON d.DealID = n.DealID
			where sEvent.StatusID = e.StatusID  
			and acc.IsDeleted = 0
			GROUP BY d.DealID
			) notefunding ON notefunding.DealID = dd.DealID
			where dd.DealName <> 'Sizer test 01'
		GROUP BY dd.DealID,dd.DealName, NoteFundingAmount,dd.credealid
     ) _delta
WHERE abs(Delta)>1

and dealid in (
	Select Distinct d.dealid from cre.deal d
	inner join cre.note n on n.dealid = d.dealid
	where n.actualpayoffdate is null
)