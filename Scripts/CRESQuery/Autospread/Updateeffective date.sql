Declare @EarliestPossibleRepaymentDate date = '03/02/2020',
		@LatestPossibleRepaymentDate date = '03/04/2020',
		@AutoPrepayEffectiveDate date = '03/06/2020',
		@PossibleRepaymentdayofthemonth int = 30,
		@Repaymentallocationfrequency int = 2;

UPDATE CRe.Deal set EarliestPossibleRepaymentDate=@EarliestPossibleRepaymentDate,
					LatestPossibleRepaymentDate =@LatestPossibleRepaymentDate,
		            AutoPrepayEffectiveDate = @AutoPrepayEffectiveDate,
					PossibleRepaymentdayofthemonth =@PossibleRepaymentdayofthemonth,
					Repaymentallocationfrequency =@Repaymentallocationfrequency
	Where CREDealID ='18-2204'