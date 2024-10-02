GUIDANCE:{StageID_Other}/*Stage ID*/,GUIDANCE:{EventID}/*Event ID*/,GUIDANCE:{CaseNum}/*CevID*/,
select top 200 (epi_lastname + ', ' + epi_firstname) as 'NAME', epi_id, epi_paid, epi_status, LEFT (epi_mrnum, 3) AS 'BRANCH', epi_mi, EPI_SLID,ps_freq,
CONVERT(date, epi_STARTofepisode, 101) as SOE
,CONVERT(date, epi_ENDofepisode, 101) as EOE,
CONVERT(date, epi_SOCdate, 101) as SOC,CEBP_BENEFITPERIOD AS BP from CLIENT_EPISODES_ALL 
JOIN CLIENT_EPISODE_BENEFIT_PERIOD ON cebp_epiid = epi_id
JOIN client_episode_fs ON cefs_epiid = epi_id
join payor_sources on ps_id = cefs_psid
where epi_mrnum= {MRnum}
order by 2


--Orders and Visits by episode
SELECT 
  cev.cev_id AS CEV,
  cev.cev_epiid AS EPI_VISIT,
  cevn.cevn_VisitType AS CODE,
  FORMAT(cev.CEV_VISITDATE, 'MM-dd-yyyy') AS DATE,
  cev.CEV_CSVID AS CSV,
  csv.csv_synchid AS SCHEDULEID,
  cevn.cevn_id AS cevN,
  co.o_id AS ORDER_ID,
  CASE 
    WHEN co.o_epiid = cev.cev_epiid THEN 'SAME'
    ELSE CAST(co.o_epiid AS VARCHAR(255))  
  END AS 'Same epi as visit?',
  co.o_epiid AS EPI_ORDER,
  cev.CEV_AGID AS WORKER,
  cev.CEV_VISITNUMBER AS VN#,
  cev.cev_deleted
FROM CLIENT_EPISODE_VISIT_notes cevn
JOIN CLIENT_EPISODE_VISITS_ALL cev ON cev.cev_id = cevn.cevn_cevid
JOIN SERVICECODES sc ON sc.sc_id = cev.CEV_SC_ID
JOIN workers w ON cev.CEV_AGID = w.wkr_id
LEFT JOIN client_sched_visits csv ON cev.CEV_CSVID = csv.csv_id
LEFT JOIN CLIENT_ORDERS co ON co.o_cevid = cev.cev_id
JOIN CLIENT_EPISODES_ALL cea ON cev.CEV_EPIID = cea.epi_id
JOIN clients_all ca ON ca.pa_id = cea.epi_paid
WHERE  epi_id = ({episode_id})
  --AND co.o_otid = {StageID_Other} -- Order Type
  AND (CAST(co.o_orderdate AS DATE) = {Date}
   or CAST(cev.CEV_VISITDATE as DATE) = {Date})
ORDER BY cev.CEV_VISITDATE



 SELECT CONCAT(cea.epi_lastname, ', ', cea.epi_firstname) AS patient_name ,o_id,o_cevid, o_deleted,o_epiid, o_orderdate,CONVERT(date, cea.epi_StartOfEpisode) SOE,o_otid,cevn_VisitType as CODE ,o_nursedate,o_voidedby,o_declinedby,o_approvedby, o_dateapproved, o_sendtophysician,o_sendtomeddir,o_howsent,o_physiciansentdate,o_physicianexpecteddate,o_physiciansigneddate,o_meddirhowsent,o_meddirsentdate
 FROM client_orders_all
   JOIN ORDER_TYPES ON OT_ID = O_OTID
 left JOIN client_episodes_all AS cea ON o_epiid = cea.epi_id
 full join CLIENT_EPISODE_VISIt_notes on cevn_cevid = o_cevid
   WHERE O_epiID in ({episode_id})
  -- and cast (o_orderdate AS DATE) = 'xxxxxx'
  order by 4



  --Order info:
  
  SELECT CONCAT(cea.epi_lastname, ', ', cea.epi_firstname) AS patient_name,o_epiid, o_orderdate,CONVERT(date, cea.epi_StartOfEpisode) SOE, o_id,o_cevid,o_otid, o_nursedate,o_voidedby,o_declinedby,o_approvedby, o_dateapproved,o_physiciansigneddate,
  o_meddirsigneddate,o.o_phid,o.o_primarysignedphid,  o.o_meddirsignedphid , o_sendtophysician,o_sendtomeddir,o_howsent,o_physiciansentdate,o_physicianexpecteddate, o_meddirhowsent,o_meddirsentdate,o_desc
  FROM client_orders AS o
  JOIN client_episodes_all AS cea ON o.o_epiid = cea.epi_id
  WHERE o.o_id IN ({order_id})


DECLARE	@return_value int,
		@ceesID int

EXEC	@return_value = [dbo].[usp_AddEventStage]
		@epiid = '{episode_id}',
		@evid = '{EventID}',
		@stid = '{StageID_Other}',
		@reportparameter =  'xxxxxx',
		@oid = '{order_id}',
		@cevid = '{CaseNum}',
		@ceesID = @ceesID OUTPUT

SELECT	@ceesID as N'@ceesID'

SELECT	'Return Value' = @return_value

GO
