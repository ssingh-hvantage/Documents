select * from(


Select d.Credealid,n.Crenoteid,fs.date,LPurposeID.Name PurposeText ,Applied,SUM(fs.Value) as Int_Amount,stagFF.amount as Stag_Amount,(SUM(fs.Value) - stagFF.amount) as Delta
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
		and acc.IsDeleted = 0
		and eve.StatusID = (Select LookupID from Core.Lookup where name = 'Active' and ParentID = 1)
		GROUP BY n.Account_AccountID,EventTypeID,eve.StatusID
) sEvent
ON sEvent.AccountID = e.AccountID and e.EffectiveStartDate = sEvent.EffectiveStartDate  and e.EventTypeID = sEvent.EventTypeID
left JOIN [CORE].[Lookup] LEventTypeID ON LEventTypeID.LookupID = e.EventTypeID
left JOIN [CORE].[Lookup] LPurposeID ON LPurposeID.LookupID = fs.PurposeID 
INNER JOIN [CORE].[Account] acc ON acc.AccountID = e.AccountID
INNER JOIN [CRE].[Note] n ON n.Account_AccountID = acc.AccountID
Inner JOin cre.deal d on d.dealid = n.dealid
Left Join(
	Select	[NoteID],[TransactionDate] as date,[WireConfirm],[PurposeBI],SUM([Amount]) as Amount
	From [DW].[Staging_NoteFunding]
	where [WireConfirm] = 1
	group by [NoteID],[TransactionDate],[WireConfirm],[PurposeBI]
)stagFF on stagFF.noteid = n.noteid and stagFF.date = fs.date and stagFF.[PurposeBI] = LPurposeID.Name

where sEvent.StatusID = e.StatusID  and acc.IsDeleted = 0
and Applied = 1
group by d.Credealid,n.Crenoteid,fs.date,LPurposeID.Name,Applied,stagFF.amount



)a
--where a.delta <> 0
Order by a.Credealid,a.Crenoteid,a.date