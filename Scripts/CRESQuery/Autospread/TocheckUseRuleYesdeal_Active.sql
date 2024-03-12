--Select * from cre.Deal where status='323'
select distinct d.dealid,dealname,credealid from cre.deal d
left join cre.note n on n.dealid=d.dealid
where isdeleted<>1 and n.UseRuletoDetermineNoteFunding = 3 and status=323
and n.actualpayoffdate is null