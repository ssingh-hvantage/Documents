//Tofindinterestpaid from cashflow

select kuchbhi.crenoteid ,tr.[date],tr.amount from CRE.TransactionEntry  tr
inner join cre.note kuchbhi on kuchbhi.NoteID  = tr.noteid
 where [Type] ='InterestPaid'  and tr.NoteID in (select NoteID from CRE.Note where DealID='450F52ED-270F-49A4-9C52-8BC3D036FB6A') and AnalysisID ='C10F3372-0FC2-4861-A9F5-148F1F80804F'
order by  kuchbhi.crenoteid, date