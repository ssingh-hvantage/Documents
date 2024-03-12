 
 
 Select distinct DealName,CREDealID
From(
    Select d.dealname,d.credealid,df.Date,df.Amount,df.PurposeID,count(df.DealID) cnt
    from cre.dealfunding df 
    inner join cre.deal d on d.dealid = df.dealid
    where d.isdeleted <> 1
    --and d.dealid = '44C53501-A61F-4EAF-A736-14E8CFD27F8B'
    group by d.dealname,d.credealid,df.Date,df.Amount,df.PurposeID
    Having count(df.DealID) > 1
)a