1.update cre.TranscationReconciliation set PostedDate=null

delete from [IO].[FileBatchLog]

delete from [IO].[FileBatchDetail]

delete from  IO.[L_Remittance]

delete from  cre.TranscationReconciliation

delete from [CRE].[TransactionAuditLog]
