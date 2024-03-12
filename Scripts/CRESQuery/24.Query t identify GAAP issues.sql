Select  Distinct nn.crenoteid 
,  Maturity_DateBI =  (Case WHEN  ActualPayoffDate is not null and ActualPayoffDate< getdate() THEn ActualPayoffDate
						When ActualPayoffDate is not null and ActualPayoffDate>= Getdate() THEN ActualPayoffDate
						WHEN ActualPayoffDate is NULL Then (Case when ExtendedMaturityScenario1 >= Getdate()  THEN  ExtendedMaturityScenario1
																WHen ExtendedMaturityScenario2  >= Getdate()  THEN  ExtendedMaturityScenario2
																WHen ExtendedMaturityScenario3  >= Getdate()  THEN  ExtendedMaturityScenario3
																Else FullyExtendedMaturityDate End)
						end)
from cre.NotePeriodicCalc np
inner join cre.note nn on nn.noteid = np.noteid
where ROUND(DiscountPremiumAccrual,2) <> 0
and np.noteid in (Select n.noteid from cre.Note n where ISNULL(n.Discount,0) = 0)


--Funding or Repyament 


 Select Distinct CreNoteid, InitialFundingAmount,
 Maturity_DateBI =  (Case WHEN  ActualPayoffDate is not null and ActualPayoffDate< getdate() THEn ActualPayoffDate
						When ActualPayoffDate is not null and ActualPayoffDate>= Getdate() THEN ActualPayoffDate
						WHEN ActualPayoffDate is NULL Then (Case when ExtendedMaturityScenario1 >= Getdate()  THEN  ExtendedMaturityScenario1
																WHen ExtendedMaturityScenario2  >= Getdate()  THEN  ExtendedMaturityScenario2
																WHen ExtendedMaturityScenario3  >= Getdate()  THEN  ExtendedMaturityScenario3
																Else FullyExtendedMaturityDate End)
						end)
  from Cre.Note N
 inner JOin cre.transactionEntry tr on N.Noteid = tr.Noteid
	where tr.type not in ( 'FundingOrRepayment')  and Tr.[Date] <= EOMONTH(DateAdd(month,2,EOMONTH(n.ClosingDate)))  and InitialFundingAmount < 1
	
	 

	Select EOMONTH(DateAdd(month,2,EOMONTH(n.ClosingDate))) , ClosingDate  from cre.note N

	-- First value is missing
Select nn.noteid,nn.crenoteid,nn.ClosingDate,EOMONTH(nn.ClosingDate) ClosingDate_EOMONTH,

 Maturity_DateBI =  (Case WHEN  ActualPayoffDate is not null and ActualPayoffDate< getdate() THEn ActualPayoffDate
						When ActualPayoffDate is not null and ActualPayoffDate>= Getdate() THEN ActualPayoffDate
						WHEN ActualPayoffDate is NULL Then (Case when ExtendedMaturityScenario1 >= Getdate()  THEN  ExtendedMaturityScenario1
																WHen ExtendedMaturityScenario2  >= Getdate()  THEN  ExtendedMaturityScenario2
																WHen ExtendedMaturityScenario3  >= Getdate()  THEN  ExtendedMaturityScenario3
																Else FullyExtendedMaturityDate End)
						end)


,SUM(ISNULL(EndingGAAPBookValue,0)) 

as EndingGAAPBookValue

from cre.NotePeriodicCalc
 np
inner join cre.note nn on nn.noteid = np.noteid
where  np.periodenddate <= EOMONTH(nn.ClosingDate)
group by nn.noteid,nn.crenoteid,nn.ClosingDate, ActualPayoffDate, ExtendedMaturityScenario1, ExtendedMaturityScenario2, ExtendedMaturityScenario3, FullyExtendedMaturityDate
having SUM(ISNULL(EndingGAAPBookValue,0)) = 0

 