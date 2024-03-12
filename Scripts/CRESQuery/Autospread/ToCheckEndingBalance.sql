Declare @Dealid [nvarchar] (256) ,@date DateTime , @AutospreadStartDate DateTime
set @Dealid ='19-1182'
set @Date ='1/31/2021'
set @AutospreadStartDate ='2/8/2021'


select CREDealID, Periodenddate, Sum(Endingbalance) from
(
select 
CreDealid, Crenoteid, Periodenddate, EndingBalance from cre.noteperiodicCalc C
Inner join cre.note N on N.Noteid =c.Noteid
Inner join[core].[Analysis] A on A.analysisid=c.Analysisid
Inner Join cre.Deal D on D.DealID=N.DealId
where Eomonth(Periodenddate,0)=Periodenddate
and A.name ='Default'
)
X
Where credealid =@DealId and Periodenddate= @Date
Group By Credealid, periodenddate

Select CREDealId,Sum(Amount) from Cre.TransactionEntry T
Inner Join Cre.Note N on N.Noteid= T.Noteid
Inner Join [Core].[Analysis] A on A.analysisid=T.Analysisid
Inner join Cre.Deal D on D.DealID =N.DealID
Where Type in ('FundingRepayment', 'Amortization', 'PIKInterest')
and A.name ='Default'
And Date between @date and @AutospreadStartDate and CredealId =@Dealid
Group by credealId