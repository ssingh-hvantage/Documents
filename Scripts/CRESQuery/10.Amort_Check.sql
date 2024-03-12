
Select crenoteid,
ABS(Delta_AmortFeeCheck)  as AmortFeeCheck ,
ABS(Delta_AmortDiscountPremiumCheck) as AmortDiscountPremiumCheck ,
ABS(Delta_AmortCapCostCheck)  as AmortCapCostCheck
From(

Select n.crenoteid
		,(ROUND(SUM(TotalAmortAccrualForPeriod),0) - ROUND(ISNULL(tblTr.[IncludedInLevelYield],0),0)) as Delta_AmortFeeCheck
		,(ROUND(SUM(DiscountPremiumAccrual),0) - ROUND(ISNULL(tblTr.[DiscountPremium],0),0)) as Delta_AmortDiscountPremiumCheck
		,(ROUND(SUM(CapitalizedCostAccrual),0) - ROUND(ISNULL(tblTr.[CapitalizedClosingCost],0),0)) as Delta_AmortCapCostCheck
		from Cre.NoteperiodicCalc nc    
		Inner join cre.note n on n.Account_AccountID = nc.AccountID    
		inner join core.account acc on acc.accountid = n.account_accountid
		LEFT JOIN(
			Select noteid,ISNULL([IncludedInLevelYield],0) as [IncludedInLevelYield],ISNULL([DiscountPremium],0) as [DiscountPremium],ISNULL([CapitalizedClosingCost],0) as [CapitalizedClosingCost]
			From(
				
				-------------------------------------------------
				Select z.noteid,z.[Type],SUM(Amount_Inc_reciev) as Amount
				From(
					Select b.noteid,
					(CASE WHEN b.[Type] = 'Discount/Premium' THEN 'DiscountPremium'
					WHEN b.[Type] = 'CapitalizedClosingCost' THEN 'CapitalizedClosingCost'
					ELSE 'IncludedInLevelYield' end ) as [Type]
					, (SUM(Include_Amount)  + ISNULL(tblStrip.Strip_Amount,0)) Amount_Inc_reciev
					From(
						Select n.noteid,ISNULL(Amount,0) as Include_Amount,REPLACE([Type],'IncludedInLevelYield','') as [Type]
						from cre.transactionEntry tr
						Inner join cre.note n on n.Account_AccountID = tr.AccountID  
						Where ([Type] like '%IncludedInLevelYield%'	OR [Type] = 'Discount/Premium' OR [Type] = 'CapitalizedClosingCost')
						and analysisid ='C10F3372-0FC2-4861-A9F5-148F1F80804F'
						--and noteid = '513f799c-281a-4758-9914-55ce4596cf7c'
					)b
					Left Join(
						Select noteid,[Type],SUM(Strip_Amount) as Strip_Amount
						From(
							Select n.noteid,Amount as Strip_Amount,REPLACE(REPLACE([Type],'StripReceivable',''),'OriginationFeeStripping','OriginationFee') as [Type]
							from cre.transactionEntry tr
							Inner join cre.note n on n.Account_AccountID = tr.AccountID 
							Where ([Type] like '%StripReceivable%' OR [Type] = 'OriginationFeeStripping')	
							and analysisid ='C10F3372-0FC2-4861-A9F5-148F1F80804F'
							--and noteid =  '513f799c-281a-4758-9914-55ce4596cf7c'  
						)a
						group by noteid,[Type]

					)tblStrip on tblStrip.noteid = b.noteid and tblStrip.[Type] = b.[Type]
					group by b.noteid,b.[Type],tblStrip.Strip_Amount
				)z
				group by z.noteid,z.[Type]
				-------------------------------------------------

			) AS SourceTable  
			PIVOT  
			(  
				MIN(Amount)  
				FOR [Type] IN ([IncludedInLevelYield],[DiscountPremium],[CapitalizedClosingCost])  
			) AS PivotTable
		)tblTr on tblTr.noteid = n.noteid
		where nc.[Month] is not null    and acc.isdeleted <> 1
		and nc.AnalysisID = 'C10F3372-0FC2-4861-A9F5-148F1F80804F'
		--and nc.noteid ='513f799c-281a-4758-9914-55ce4596cf7c'
		group by n.crenoteid, n.noteid,tblTr.[IncludedInLevelYield],tblTr.[DiscountPremium],tblTr.[CapitalizedClosingCost]


)y