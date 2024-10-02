GUIDANCE:{StageID_Other}/*Order Type*/,GUIDANCE:{Date}/*Order date or Visit date*/,GUIDANCE:{EventID}/*Visit Type*/

--Episodes:------

SELECT top 200 (epi_lastname + ', ' + epi_firstname) AS 'NAME',epi_id,epi_status,epi_mrnum,epi_mi,epi_startofepisode AS SOE,epi_EndOfEpisode AS EOE,epi_SocDate,CEBP_BENEFITPERIOD AS BP, epi_paid  ,epi_slid
FROM CLIENT_EPISODES_ALL  
JOIN CLIENT_EPISODE_BENEFIT_PERIOD ON cebp_epiid = epi_id 
where  ({names_clause})
--MRNUM 


select top 200 (epi_lastname + ', ' + epi_firstname) as 'NAME', epi_id, epi_paid, epi_status, LEFT (epi_mrnum, 3) AS 'BRANCH', epi_mi, EPI_SLID,ps_freq,
CONVERT(date, epi_STARTofepisode, 101) as SOE
,CONVERT(date, epi_ENDofepisode, 101) as EOE,
CONVERT(date, epi_SOCdate, 101) as SOC,CEBP_BENEFITPERIOD AS BP from CLIENT_EPISODES_ALL 
JOIN CLIENT_EPISODE_BENEFIT_PERIOD ON cebp_epiid = epi_id
JOIN client_episode_fs ON cefs_epiid = epi_id
join payor_sources on ps_id = cefs_psid
where epi_mrnum={MRnum}
order by 2



--All episodes per MR#
SELECT (epi_lastname + ', ' + epi_firstname) AS 'NAME'
	,epi_status
	,epi_id
	,epi_acid
	,epi_mrnum
	,epi_mi
	,epi_SocDate AS SOC
	,epi_startofepisode AS SOE
	,epi_EndOfEpisode AS EOE
	,CEBP_BENEFITPERIOD AS BP, epi_paid
FROM CLIENT_EPISODES_ALL
JOIN CLIENT_EPISODE_BENEFIT_PERIOD ON cebp_epiid = epi_id
WHERE epi_mrnum in ( (select epi_mrnum from CLIENT_EPISODES_ALL where epi_id IN ({episode_id})))
ORDER BY 8


--GETUPDATES
select * from CLIENT_EPISODE_UPDATES
where ceu_epiid = {episode_id}

------------------------------------------------------

--Visits----

  SELECT cev_id AS CEV, cev_epiid AS EPI_VISIT, cevn_VisitType as CODE, format(CEV_VISITDATE,'yyyy-MM-dd') AS DATE , CEV_CSVID as CSV,csv_synchid AS SCHEDULEID, cevn_id AS cevN, o_id AS ORDER_ID,
  CASE 
    WHEN o_epiid = cev_epiid THEN 'SAME'
    ELSE CAST(o_epiid AS VARCHAR(255))  
  END AS 'Same epi as visit?', o_epiid AS EPI_ORDER,CEV_AGID AS WORKER, wkr_fullname as Worker_Name,CEV_VISITNUMBER AS VN# ,cev_deleted,cevn_ModificationDate
FROM CLIENT_EPISODE_VISIT_notes
JOIN CLIENT_EPISODE_VISITS_ALL ON cev_id = cevn_cevid
JOIN SERVICECODES ON sc_id = CEV_SC_ID
JOIN workers ON CEV_AGID = wkr_id
LEFT JOIN client_sched_visits csv ON CEV_CSVID = csv.csv_id
LEFT JOIN CLIENT_ORDERS on o_cevid = cev_id
WHERE ( CEVn_EPIID IN ({episode_id})
or  CEVn_EPIID IN (select epi_id from CLIENT_EPISODES_ALL where {names_clause})
) 
--AND cevn_VisitDate = {Date}
--and cev_sc_id = (select sc_id from servicecodes where sc_code like {Service_Code})
--AND cevn_visittype Like '%{EventID}%'
order by 4




--Orders------------


SELECT CONCAT(cea.epi_lastname, ', ', cea.epi_firstname) AS patient_name,o_epiid, o_orderdate,CONVERT(date, cea.epi_StartOfEpisode) SOE, o_id,o_cevid,o_otid, o_nursedate,o_deleted,o_voidedby,o_declinedby,o_approvedby, o_dateapproved,o_physiciansigneddate,
o_meddirsigneddate,o.o_phid,o.o_primarysignedphid,  o.o_meddirsignedphid , o_sendtophysician,o_sendtomeddir,o_howsent,o_physiciansentdate,o_physicianexpecteddate, o_meddirhowsent,o_meddirsentdate,o_desc
FROM client_orders_all AS o
JOIN client_episodes_all AS cea ON o.o_epiid = cea.epi_id
WHERE o.o_id IN ({order_id})

  SELECT CONCAT(cea.epi_lastname, ', ', cea.epi_firstname) AS patient_name, o_id, o_deleted, o_epiid, o_orderdate, CONVERT(date, cea.epi_StartOfEpisode) SOE, o_cevid, o_otid, cevn_VisitType as CODE, o_nursedate, o_voidedby, o_declinedby, o_approvedby, o_dateapproved, o_sendtophysician, o_sendtomeddir, o_howsent, o_physiciansentdate, o_physicianexpecteddate, o_physiciansigneddate, o_meddirhowsent, o_meddirsentdate
FROM client_orders_all
JOIN ORDER_TYPES ON OT_ID = O_OTID
LEFT JOIN client_episodes_all AS cea ON o_epiid = cea.epi_id
FULL JOIN CLIENT_EPISODE_VISIt_notes ON cevn_cevid = o_cevid
WHERE (
  O_epiID IN ({episode_id}) AND cea.epi_id != 0
  OR
  O_epiID IN (
    SELECT epi_id FROM CLIENT_EPISODES_ALL
    WHERE {names_clause}
  )
  --and o_orderdate = {Date}
  --and o_otid = {StageID_Other}
)
ORDER BY 5


--Schedule--------

select csv_id, csv_synchid as SCHEDULE_ID, csv_epiid, csv_scheddate, csv_scid,sc_code, sc_desc,wkr_fullname as AGENT, csv_agid, csv_status, csv_visitnumber   from client_sched_visits
join servicecodes on sc_id = csv_scid
join workers on wkr_id = csv_agid
join client_episodes_all on epi_id = csv_epiid
where (csv_epiid IN ({episode_id}) or
 csv_paid IN ({patient_id})
or  csv_paid IN (select epi_paid from CLIENT_EPISODES_ALL where ({names_clause}) ))
--and csv_scheddate in ({Date})
--and sc_code in ({Service_Code})
order by csv_scheddate


--Oases---------

select CEV_EPIID as EpiVisit, ceo_epiid as OASIS_EPI,o_epiid as EpiOrder, ceo_id, o_id, CEV_ID , CONVERT (DATE, CEV_VISITDATE, 101) as VisitDate, cevn_visittype as VisitType, o_otid,  ceoh_transtype, ceoh_transdate, ceoh_id from CLIENT_EPISODE_OASIS 
full join CLIENT_EPISODE_VISITS on CEV_ID = ceo_cevid
full join CLIENT_EPISODE_OASIS_ORDERS on ceoo_ceoid = ceo_id
full join CLIENT_ORDERS on ceoo_oid = o_id
join CLIENT_EPISODE_VISIT_NOTES on cevn_cevid = CEV_ID
join CLIENT_EPISODE_OASIS_HISTORY on ceoh_ceoid = ceo_id
WHERE ( CEVn_EPIID IN ({episode_id})
or  CEVn_EPIID IN (select epi_id from CLIENT_EPISODES_ALL where {names_clause})) 
--AND cevn_VisitDate = {Date}
--AND cevn_visittype Like '%{EventID}%'
Order by cev_visitdate


--Billing-------------------------------



--NOA
declare @soc datetime = (select epi_socdate from CLIENT_EPISODES_ALL where epi_id = {episode_id})
declare @paid int = (select epi_paid from CLIENT_EPISODES_ALL where epi_id = {episode_id})
declare @epiid int = '{episode_id}'
 
select * from pdgm.NOTICE_OF_ADMISSION
JOIN CLIENT_EPISODES_ALL ON noa_paid =  @paid 
 	AND noa_SOCDate = @soc 
 	AND epi_SocDate = @soc 
 	AND epi_paid = @paid 
WHERE epi_id = @epiid
AND (
 	noa_billedFlag = 1
 	OR noa_cancelPending = 1)
AND noa_deleted = 0
 
--PDGM
select top 200 (epi_lastname + ', ' + epi_firstname) as 'NAME', epi_id, epi_status, LEFT (epi_mrnum, 3) AS 'BRANCH', epi_mi,
CONVERT(date, epi_STARTofepisode, 101) as SOE
,CONVERT(date, epi_ENDofepisode, 101) as EOE, pp_startdate, pp_enddate, pp_rapbilled, pp_claimbilled,pp_periodEnded,  pp_claimAdjustmentPending ,pp_deleted  , pp_rapCancelPending , cefs_id ,
CONVERT(date, epi_SOCdate, 101) as SOC,CEBP_BENEFITPERIOD AS BP,  epi_paid from CLIENT_EPISODES_ALL 
JOIN CLIENT_EPISODE_BENEFIT_PERIOD ON cebp_epiid = epi_id
JOIN client_episode_fs ON cefs_epiid = epi_id
join pdgm.PDGM_PERIOD on pp_cefsid = cefs_id
where epi_id = {episode_id}
order by 2

--Medicare
SELECT auth_rap AS [R], auth_cancelrap AS [CR], auth_finalclaim AS [F], auth_editclaim AS [EF]
FROM authorizations
JOIN dbo.CLIENT_EPISODE_FS ON auth_cefsid = cefs_id
WHERE cefs_epiid = {episode_id}
