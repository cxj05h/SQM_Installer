GUIDANCE:{Date}/*Current Scheduled Date*/,GUIDANCE:{EventID}/*Reason ID*/

SELECT top 200 (epi_lastname + ', ' + epi_firstname) AS 'NAME',epi_id,epi_status,epi_mrnum,epi_mi,epi_startofepisode AS SOE,epi_EndOfEpisode AS EOE,epi_SocDate,CEBP_BENEFITPERIOD AS BP, epi_paid  ,epi_slid
FROM CLIENT_EPISODES_ALL  
JOIN CLIENT_EPISODE_BENEFIT_PERIOD ON cebp_epiid = epi_id 
where  ({names_clause})
order by 1

select top 200 (epi_lastname + ', ' + epi_firstname) as 'NAME', epi_id, epi_paid, epi_status, LEFT (epi_mrnum, 3) AS 'BRANCH', epi_mi, EPI_SLID,ps_freq,
CONVERT(date, epi_STARTofepisode, 101) as SOE
,CONVERT(date, epi_ENDofepisode, 101) as EOE,
CONVERT(date, epi_SOCdate, 101) as SOC,CEBP_BENEFITPERIOD AS BP from CLIENT_EPISODES_ALL 
JOIN CLIENT_EPISODE_BENEFIT_PERIOD ON cebp_epiid = epi_id
JOIN client_episode_fs ON cefs_epiid = epi_id
join payor_sources on ps_id = cefs_psid
where epi_mrnum IN ({MRnum})
order by 2
	
--------------------------------------------------

---------Reason IDs------

 --1 NEW ADMISSION
 --2 DISCHARGE
 --3 DEATH AT HOME
 --4 RECERT ORDER DUE
 --5 RECURRING
 --6 PRN
-------------------------

--Find Dates

SELECT distinct
cim_id
,cim_scheduledstartdate, cim_completeddate
,imr_desc
,cim_imrid
,cim_meetingstatus
,cim_open
,cim_voidedby
,cim_voideddate
	 FROM client_idg_meetings
	 left JOIN client_eobs ON cim_ceobid = ceob_id
	 JOIN idg_meeting_reasons ON cim_imrid = imr_id
	 WHERE ceob_paid IN ({patient_id})
	and cast  (cim_scheduledstartdate as date) IN ({Date})  --meeting date
	--and cimd_wkrid = @worker              --worker id
	--and cim_imrid = '{EventID}'           --IDG reason
	--and cast (cimd_signeddate as date)  = @signeddate -- finds all signaures on meetings only
	--and cimd_signedby is not null
order by 4,2 asc
select cimd_signeddate AS 'MD Signed' from client_idg_meeting_details 
join client_idg_meetings on cim_id = cimd_cimid
 JOIN client_eobs ON cim_ceobid = ceob_id
WHERE (
    ceob_paid in ( (SELECT epi_paid FROM client_episodes_all WHERE epi_id in( {episode_id})))
    OR ceob_paid in ({patient_id})
    or ceob_paid IN (select epi_paid from CLIENT_EPISODES_ALL where {names_clause})
)
and cast  (cim_scheduledstartdate as date) IN ({Date})  --meeting date
and cimd_idgrid = 1
and cimd_signedby is not null



-------------------------------------------------------------------------------------------------------------------------------------

--Provide to SQM
SELECT DISTINCT
    cim_id,
		cim_scheduledstartdate,
CASE /*Enter the old scheduled start date next to the new scheduled start date. Add another row for each new change*/
    WHEN TRY_CONVERT(DATE, cim_scheduledstartdate) = TRY_CONVERT(DATE, 'Date1') THEN 'Date1'
    WHEN TRY_CONVERT(DATE, cim_scheduledstartdate) = TRY_CONVERT(DATE, 'Date2') THEN 'Date2'
    ELSE CAST(cim_scheduledstartdate AS VARCHAR(50))
END AS cim_newScheduleddate,
cim_completeddate,
CASE /*Enter the old completed date  next to the new completed date. Add another row for each new change. If there is no change, leave as is*/
    WHEN TRY_CONVERT(DATE, cim_completeddate) = TRY_CONVERT(DATE, 'Date1') THEN 'Date1'
    WHEN TRY_CONVERT(DATE, cim_completeddate) = TRY_CONVERT(DATE, 'Date2') THEN 'Date2'
    ELSE CAST(cim_completeddate AS VARCHAR(50))
END AS cim_newCompleteddate,
    imr_desc,
    cim_imrid,
    cim_meetingstatus,
    cim_open,
    cim_voidedby,
    cim_voideddate
FROM client_idg_meetings
LEFT JOIN client_eobs ON cim_ceobid = ceob_id
JOIN idg_meeting_reasons ON cim_imrid = imr_id
WHERE ceob_paid IN ({patient_id})
    AND CAST(cim_scheduledstartdate AS DATE) IN ({Date})
ORDER BY 4, 2 ASC



------------------------------------------------------------------------------------------------------------------------------















