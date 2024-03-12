//query for Holiday adjustment
select * from cre.deal where dealid='429ddc1c-337f-497e-bcce-9004a8349a3e'

Select 
F.Crenoteid
, F.Date
, Amount 
from [dbo].[NoteFundingSchedule] F
Inner join Note N on F.CRENoteID = N.NoteID
inner Join [dbo].[Calendar] C on F.Date = C.Date
where [IsHoliday] = 1
and actualpayoffdate is null
