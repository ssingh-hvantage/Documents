Declare @Scenario_Default UNIQUEIDENTIFIER = (Select AnalysisID from core.analysis where name = 'Default')
Declare @Scenario_Other UNIQUEIDENTIFIER = (Select AnalysisID from core.analysis where name = 'Current Maturity Date (without Prepay, FWCV)')

IF OBJECT_ID('tempdb..[#tblTransactionEntry]') IS NOT NULL                                         
	DROP TABLE [#tblTransactionEntry]  

Create table [#tblTransactionEntry]
(
dealname nvarchar(256),
noteid UNIQUEIDENTIFIER,
crenoteid nvarchar(256),
date date,
type nvarchar(256),
Amount decimal(28,15),
AnalysisID UNIQUEIDENTIFIER
)

INSERT INTO [#tblTransactionEntry] (dealname,noteid,crenoteid,date,type,Amount,AnalysisID)
Select d.dealname,n.noteid,n.crenoteid,tr.date,tr.type,Amount,tr.AnalysisID
from cre.transactionentry tr
Inner join cre.note n on n.Account_AccountID = tr.AccountId
Inner join core.account acc on acc.accountid = n.account_accountid
Inner join cre.deal d on d.dealid = n.dealid
Where acc.isdeleted <> 1 and d.isdeleted <> 1
and tr.AnalysisID in (@Scenario_Default, @Scenario_Other)
and tr.date <= EOMONTH(dateadd(month,-1,getdate()))
---and n.crenoteid = '4851'
-----=================================================================
IF OBJECT_ID('tempdb..[#tblTransactionEntryFinal]') IS NOT NULL                                         
	DROP TABLE [#tblTransactionEntryFinal]  

Create table [#tblTransactionEntryFinal]
(
Dealname nvarchar(256),
CREnoteid nvarchar(256),
Date date,
Type nvarchar(256),
Amount_Scenario_Default decimal(28,15),
Amount_Scenario_Other decimal(28,15),
Delta decimal(28,15),
ABS_Delta decimal(28,15),
)

INSERT INTO [#tblTransactionEntryFinal] (dealname,CreNoteid,Date,Type,Amount_Scenario_Default,Amount_Scenario_Other ,Delta,ABS_Delta)

Select tr.Dealname,tr.crenoteid as NoteID,tr.Date,tr.Type,SUM(tr.Amount) Amount_Scenario_Default ,a.amount as Amount_Scenario_Other,(SUM(tr.Amount)-a.amount ) as Delta, ABS((SUM(tr.Amount)-a.amount )) as ABS_Delta
from [#tblTransactionEntry] tr
Left Join(
	Select dealname,noteid,crenoteid,date,type,SUM(Amount) amount
	from [#tblTransactionEntry] tr
	Where tr.AnalysisID = @Scenario_Other
	Group by tr.dealname,tr.noteid,tr.crenoteid,tr.date,tr.type
)a on a.noteid = tr.noteid and a.date = tr.date and a.type = tr.type

Where tr.AnalysisID = @Scenario_Default  
Group by tr.dealname,tr.crenoteid,a.amount,tr.date,tr.type

Select * from #tblTransactionEntryFinal
Where CreNoteID='23198'and ABS_Delta>0.1
Order by DealName, crenoteid, Date, Type

--order by tr.dealname,tr.crenoteid,tr.date,tr.type





 