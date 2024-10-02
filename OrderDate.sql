GUIDANCE:{@StageID_Other}/*Original Order Date*/,GUIDANCE:{Date}/*New Order Date*/
SELECT top 200 (epi_lastname + ', ' + epi_firstname) AS 'NAME',epi_id,epi_status,epi_mrnum,epi_mi,epi_startofepisode AS SOE,epi_EndOfEpisode AS EOE,epi_SocDate,CEBP_BENEFITPERIOD AS BP, epi_paid  ,epi_slid
FROM CLIENT_EPISODES_ALL  
JOIN CLIENT_EPISODE_BENEFIT_PERIOD ON cebp_epiid = epi_id 
where  ({names_clause})


select top 200 (epi_lastname + ', ' + epi_firstname) as 'NAME', epi_id, epi_paid, epi_status, LEFT (epi_mrnum, 3) AS 'BRANCH', epi_mi, EPI_SLID,ps_freq,
CONVERT(date, epi_STARTofepisode, 101) as SOE
,CONVERT(date, epi_ENDofepisode, 101) as EOE,
CONVERT(date, epi_SOCdate, 101) as SOC,CEBP_BENEFITPERIOD AS BP from CLIENT_EPISODES_ALL 
JOIN CLIENT_EPISODE_BENEFIT_PERIOD ON cebp_epiid = epi_id
JOIN client_episode_fs ON cefs_epiid = epi_id
join payor_sources on ps_id = cefs_psid
where epi_mrnum IN ({MRnum})
order by 2


--Order info:


 --GETORDERS
 SELECT CONCAT(cea.epi_lastname, ', ', cea.epi_firstname) AS patient_name ,o_id,o_cevid, o_deleted,o_epiid, o_orderdate, o_VerbalOrderDate ,CONVERT(date, cea.epi_StartOfEpisode) SOE,o_otid,cevn_VisitType as CODE ,o_nursedate,o_voidedby,o_declinedby,o_approvedby, o_dateapproved, o_sendtophysician,o_sendtomeddir,o_howsent,o_physiciansentdate,o_physicianexpecteddate,o_physiciansigneddate,o_meddirhowsent,o_meddirsentdate
 FROM client_orders_all
   JOIN ORDER_TYPES ON OT_ID = O_OTID
 left JOIN client_episodes_all AS cea ON o_epiid = cea.epi_id
 full join CLIENT_EPISODE_VISIt_notes on cevn_cevid = o_cevid
   WHERE O_epiID in ({episode_id})
  and cast (o_orderdate AS DATE) = {@StageID_Other}
  order by 4


SELECT CONCAT(cea.epi_lastname, ', ', cea.epi_firstname) AS patient_name,o_epiid, o_orderdate,o_VerbalOrderDate, o_verbalorder,CONVERT(date, cea.epi_StartOfEpisode) SOE, o_id,o_cevid,o_otid, o_nursedate,o_voidedby,o_declinedby,o_approvedby, o_dateapproved,o_physiciansigneddate,
o_meddirsigneddate,o.o_phid,o.o_primarysignedphid,  o.o_meddirsignedphid , o_sendtophysician,o_sendtomeddir,o_howsent,o_physiciansentdate,o_physicianexpecteddate, o_meddirhowsent,o_meddirsentdate,o_desc
FROM client_orders AS o
JOIN client_episodes_all AS cea ON o.o_epiid = cea.epi_id
WHERE o.o_id IN ({order_id})




 DECLARE  @oid int = {order_id}
DECLARE @NEW_DATE DATE = {Date}
DECLARE @NEW_ORDER_DATE DATETIME = (
    SELECT DATETIMEFROMPARTS(
        YEAR(@NEW_DATE),
        MONTH(@NEW_DATE),
        DAY(@NEW_DATE),
        DATEPART(HOUR, o_orderdate),
        DATEPART(MINUTE, o_orderdate),
        DATEPART(SECOND, o_orderdate),
        DATEPART(MILLISECOND, o_orderdate)
    )
    FROM CLIENT_ORDERS
    WHERE o_id = @oid
);

DECLARE @PCPSIGN DATETIME = (select o_physiciansigneddate from CLIENT_ORDERS where o_id = @oid)
DECLARE @MDSIGN DATETIME = (select o_meddirsigneddate from CLIENT_ORDERS where o_id = @oid)

select o_orderdate as OldDate from client_orders_all where o_id = @oid
Select @NEW_ORDER_DATE as NewDate

 BEGIN
 ------------------------------------------------------------------------------------------
 
  --Change Order Date
BEGIN TRAN
UPDATE CLIENT_ORDERS_ALL
SET O_ORDERDATE = @NEW_ORDER_DATE
--, o_VerbalOrderDate = @NEW_ORDER_DATE
--,o_VerbalOrder = 1
WHERE O_ID = @oid		
select o_orderdate,o_dateapproved, o_otid from CLIENT_ORDERS where o_id = @oid
COMMIT
  
------------------------------------------------------------------------------------------

 select o_orderdate,o_VerbalOrderDate, o_verbalorder, o_otid from CLIENT_ORDERS where o_id in (@oid)
 select o_id, o_physiciansigneddate, o_meddirsigneddate from client_orders where o_id in (@oid)


 ------------------------------------------------------------------------------------------
 		 
 --NULL DATE
 				 BEGIN TRAN
 				 
 				 UPDATE CLIENT_ORDERS
 				 SET 
				 o_physiciansigneddate= null
				 ,
				 o_meddirsigneddate = null
 				 WHERE O_ID in (@oid)
 				 
 				 SELECT o_physiciansigneddate,o_meddirsigneddate
 				 FROM client_orders
 				 WHERE o_id in (@oid)
 				 
 				 COMMIT
 				 
 --RE-ENTER DATE
 				 BEGIN TRAN
 				 
 				 UPDATE CLIENT_ORDERS
 				 SET  
				 o_physiciansigneddate= @PCPSIGN
				 ,
				 o_meddirsigneddate = @MDSIGN
 				 WHERE O_ID in (@oid)
 				 
 				 SELECT o_physiciansigneddate,o_meddirsigneddate
 				 FROM client_orders
 				 WHERE o_id in (@oid)
 				 
 				 COMMIT
END
 