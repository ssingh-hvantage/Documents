  
--[dbo].[usp_GetFixedPaymentAmortizationByDealID]  'b0e6697b-3534-4c09-be0a-04473401ab93',  '6d0c511d-b1b5-4387-ab48-bffaa698639c',266644.3501,'13646,13657,13647'  
  
CREATE PROCEDURE [dbo].[usp_GetFixedPaymentAmortizationByDealID]    
(  
    @UserID UNIQUEIDENTIFIER,  
    @DealID UNIQUEIDENTIFIER,  
 @FixedPayment decimal(28,15),  
 @MultipleNoteids nvarchar(max)  
)   
AS  
BEGIN  
 SET NOCOUNT ON;  
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
  
IF OBJECT_ID('tempdb..[#tblListNotes]') IS NOT NULL                                           
 DROP TABLE [#tblListNotes]  
  
CREATE TABLE #tblListNotes(  
 CRENoteID VARCHAR(256)  
)  
INSERT INTO #tblListNotes(CRENoteID)  
select Value from fn_Split(@MultipleNoteids);  
--=================  
  
  
Declare  @ColPivot nvarchar(max),@ColPivot1 nvarchar(max),@query nvarchar(max),@AnalysisID UNIQUEIDENTIFIER  
  
  
SET @AnalysisID = (Select AnalysisID from core.analysis where [name] = 'Default')  
  
SET @ColPivot = STUFF((SELECT  ',' + QUOTENAME(cast(acc.Name as nvarchar(256)) )                 
      from [CRE].[Note] n  
      INNER JOIN [CORE].[Account] acc ON acc.AccountID = n.Account_AccountID  
      and n.DealID = @DealID  
      and acc.IsDeleted = 0  
      and n.CRENoteID in (Select CRENoteID from #tblListNotes)  
      order by ISNULL(n.lienposition,99999), n.Priority,n.InitialFundingAmount desc, acc.Name          
      FOR XML PATH(''), TYPE  
      ).value('.', 'NVARCHAR(MAX)')   
      ,1,1,'')  
  
SET @ColPivot1 = STUFF((SELECT  ',ROUND(' + QUOTENAME(cast(acc.Name as nvarchar(256)) ) +',2) as ' + QUOTENAME(cast(acc.Name as nvarchar(256)) )                 
      from [CRE].[Note] n  
      INNER JOIN [CORE].[Account] acc ON acc.AccountID = n.Account_AccountID  
      and n.DealID = @DealID  
      and acc.IsDeleted = 0  
      and n.CRENoteID in (Select CRENoteID from #tblListNotes)  
      order by ISNULL(n.lienposition,99999), n.Priority,n.InitialFundingAmount desc, acc.Name          
      FOR XML PATH(''), TYPE  
      ).value('.', 'NVARCHAR(MAX)')   
      ,1,1,'')  
  
SET @query = N'  
  
CREATE TABLE #tblListNotes(  
 CRENoteID VARCHAR(256)  
)  
INSERT INTO #tblListNotes(CRENoteID)  
select Value from fn_Split('''+ Cast(@MultipleNoteids as nvarchar(256)) + ''');  
  
  
Select ISNULL(dm.DealAmortizationScheduleID,''00000000-0000-0000-0000-000000000000'' ) DealAmortizationScheduleID,p.dealid,p.Date,ROUND(('+ Cast(@FixedPayment as nvarchar(256)) + ' - Total),2) as Amount, ' + @ColPivot1 + '  
From(  
 Select dealid,[Date],Amount,Name   
 from(  
  Select d.dealid,tr.date,tr.amount ,acc.name  
  from cre.transactionEntry tr  
  left join cre.note n on n.noteid = tr.noteid  
  INNER JOIN [CORE].[Account] acc ON acc.AccountID = n.Account_AccountID  
  inner join cre.deal d on d.dealid = n.dealid  
  where AnalysisID = '''+ Cast(@AnalysisID as nvarchar(256)) + '''   
  and tr.[type] = ''InterestPaid''  
  and d.dealid = '''+ Cast(@DealID as nvarchar(256)) + '''  
  and n.CRENoteID in (Select CRENoteID from #tblListNotes)  
  
  UNION ALL  
  
  Select d.dealid,tr.date,Sum(tr.amount) amount ,''Total'' as [name]  
  from cre.transactionEntry tr  
  left join cre.note n on n.noteid = tr.noteid  
  inner join cre.deal d on d.dealid = n.dealid  
  where AnalysisID = '''+ Cast(@AnalysisID as nvarchar(256)) + '''  
  and tr.[type] = ''InterestPaid''  
  and d.dealid = '''+ Cast(@DealID as nvarchar(256)) + '''  
  and n.CRENoteID in (Select CRENoteID from #tblListNotes)  
  group by tr.date,d.dealid  
 )a   
) x      
pivot      
(    
 sum(amount)     
 for      
 name in (' + @ColPivot + ',[Total] )       
) p  
left join [cre].[DealAmortizationSchedule] dm on dm.DealID = '''+ Cast(@DealID as nvarchar(256)) + ''' and dm.Date = p.Date  
order by p.date  
'  
  
  
PRINT @query  
EXEC (@query)  
  
  
  
--,(CASE   
--When (ROW_NUMBER() over (order by date)) = 1 THEN (Total - @FixedPaymentAmort)   
--ELSE IIF((coalesce(lag((@FixedPaymentAmort-Total)) over (order by date), 0) - Total) < 0, 0,(coalesce(lag((@FixedPaymentAmort-Total)) over (order by date), 0) - Total))  
--END) as VV  
  
  
END  