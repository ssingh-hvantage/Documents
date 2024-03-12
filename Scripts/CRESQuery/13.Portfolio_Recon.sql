--SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

DECLARE @AnalysisID AS VARCHAR(100)='c10f3372-0fc2-4861-a9f5-148f1f80804f'  -- c10f3372-0fc2-4861-a9f5-148f1f80804f , 02d20d3e-291a-42f8-afcd-bddfbb9da16b
Declare @AnalysisName nvarchar(256);
SET @AnalysisName = (Select Name from core.analysis where analysisid = @AnalysisID)
DECLARE @TransactionType AS VARCHAR(100)='DeferredFeeYield'
DECLARE @TransactionType2 AS VARCHAR(100)='SpreadPercentage'

Select d.DealName, d.CreDealID, n.CRENoteID, ISNULL(a.Type,b.type) as [Type],SUM(DevAmount) as DevAmount ,SUM(StgAmount) as StagAmount, 
(ISNULL(SUM(DevAmount),0)- ISNULL(SUM(StgAmount),0)) as Delta,
ABS((ISNULL(SUM(DevAmount),0)- ISNULL(SUM(StgAmount),0))) as ABS_Delta, n.ActualPayoffDate, c.Status as Calculation_Status,EndTime as CalculatedOn, le.Name as EnableM61Calculations, @AnalysisName as Scenario
from (
	Select NoteID, Type, SUM(Amount) as DevAmount,AnalysisID  
	from Cre.TransactionEntry te
	Where AnalysisID=@AnalysisID
	Group by NoteID, Type,  AnalysisID 
) a
full outer join (
	Select NoteID, Type, SUM(Amount) as StgAmount, AnalysisID 
	from Dw.Staging_TransactionEntry ste
	Where AnalysisID=@AnalysisID
	Group by NoteID, Type, AnalysisID 
) b on a.NoteID=b.NoteID and a.Type=b.type 

left join cre.Note n on n.NoteID=ISNULL(a.NoteID ,b.noteid)
left join core.account acc on acc.accountID=n.account_accountID
left join cre.Deal d on d.DealID=n.DealID
left join core.Lookup le on le.LookupID=n.EnableM61Calculations
left join (
	Select CreNoteID, l.Name as Status, EndTime from cre.Note n
	left join core.CalculationRequests cr on n.NoteID=cr.NoteId
	left join core.Lookup l on l.LookupID=cr.StatusID 
	Where cr.AnalysisID=@AnalysisID) c on c.CRENoteID=n.CRENoteID

Where acc.isdeleted <> 1 and iSNULL(a.AnalysisID,b.AnalysisID) =@AnalysisID 
--and n.EnableM61Calculations=3
and ABS((ISNULL((DevAmount),0)- ISNULL((StgAmount),0))) > 0
and ISNULL(a.Type,b.type) Not in ( 'EndingPVGAAPBookValue','RawIndexPercentage') --in (@TransactionType)
--and ISNULL(a.Type,b.type) in ( 'FundingOrRepayment', 'InitialFunding')
--and n.CRENoteID in ('14356')
--and d.CREDealID='17-0435'
--and c.Status like '%Failed%'
Group by d.DealName,d.CreDealID, n.CRENoteID, ISNULL(a.Type,b.type), le.Name,  n.ActualPayoffDate, c.Status , n.EnableM61Calculations,EndTime
Order by d.DealName, CRENoteID, Type

--SET TRANSACTION ISOLATION LEVEL READ COMMITTED