

 select coh_oid, coh_orderdate, coh_modifiedby, coh_datemodified, * from client_order_history where coh_oid IN ({order_id})
 --and cast (coh_datemodified as date) = {Date}
 order by 4 asc


------------------------------------------------------- Update Snapshot/Remove Signatures --------------------

 
 DECLARE @PCPSIGN DATETIME = (select o_physiciansigneddate from CLIENT_ORDERS where o_id = {order_id})
 DECLARE @MDSIGN DATETIME = (select o_meddirsigneddate from CLIENT_ORDERS where o_id = {order_id})
 
 select o_orderdate,o_VerbalOrderDate, o_otid from CLIENT_ORDERS where o_id in ({order_id})
 
 select o_id, o_physiciansigneddate, o_meddirsigneddate from client_orders where o_id in ({order_id})


 ------------------------------------------------------------------------------------------
 		 
--NULL DATE
BEGIN TRAN
 				 
UPDATE CLIENT_ORDERS
SET 
o_physiciansigneddate= null
,
o_meddirsigneddate = null
WHERE O_ID in ({order_id})
 				 
SELECT o_physiciansigneddate,o_meddirsigneddate
FROM client_orders
WHERE o_id in ({order_id})
 				 
COMMIT
 				 
--RE-ENTER DATE
BEGIN TRAN
 				 
UPDATE CLIENT_ORDERS
SET  
o_physiciansigneddate= @PCPSIGN
,
o_meddirsigneddate = @MDSIGN
WHERE O_ID in ({order_id})
 				 
SELECT o_physiciansigneddate,o_meddirsigneddate
FROM client_orders
WHERE o_id in ({order_id})
 				 
COMMIT
 				 


