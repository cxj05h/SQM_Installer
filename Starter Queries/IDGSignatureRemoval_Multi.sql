GUIDANCE:{Date}/*IDG Date*/,GUIDANCE:{StageID_Other}/*Signed Date*/,GUIDANCE:{CaseNum}/*Worker Last Name*/



SELECT distinct epi_paid , (epi_lastname + ', ' + epi_firstname) AS 'NAME',epi_mrnum,epi_mi, epi_paid  ,epi_slid
FROM CLIENT_EPISODES_ALL  
JOIN CLIENT_EPISODE_BENEFIT_PERIOD ON cebp_epiid = epi_id 
where  ({names_clause})
order by 1, 6

select top 200 (epi_lastname + ', ' + epi_firstname) as 'NAME', epi_id, epi_paid, epi_status, LEFT (epi_mrnum, 3) AS 'BRANCH', epi_mi, EPI_SLID,ps_freq,
CONVERT(date, epi_STARTofepisode, 101) as SOE
,CONVERT(date, epi_ENDofepisode, 101) as EOE,
CONVERT(date, epi_SOCdate, 101) as SOC,CEBP_BENEFITPERIOD AS BP from CLIENT_EPISODES_ALL 
JOIN CLIENT_EPISODE_BENEFIT_PERIOD ON cebp_epiid = epi_id
JOIN client_episode_fs ON cefs_epiid = epi_id
join payor_sources on ps_id = cefs_psid
where epi_mrnum IN ({MRnum})
order by 2
	
	--1	MEDICAL DIRECTOR
	--2	REGISTERED NURSE
	--3	SOCIAL WORKER
	--4	PASTOR/COUNSELOR
	--25000	VOLUNTEER COORDINATOR
	--25001	BEREAVEMENT COORDINATOR
	--25002	IDG MEETING SCRIBE
	--25003	LPN
	--25004	HOSPICE AIDE
	--25005	CANDY'S
	--25006	MUSIC THERAPIST
	--25007	REGISTERED DIETICIAN
	--25008	HOSPICE PHYSICIAN
	
--Find Worker ID
select * from WORKERS where wkr_lastname like '%{CaseNum}%' order by 7 


--*********************************************************




SELECT DISTINCT
    cimd.cimd_id,
    cimd.cimd_idgrid AS 'ROLE',
    cimd.cimd_wkrid,
    (epi_lastname + ', ' + epi_firstname) AS 'NAME',
    cim.cim_id,
    cim.cim_scheduledstartdate,
    cim.cim_completeddate,
    imr_desc,
    cim.cim_imrid,
    cimd.cimd_signedby,
    cimd.cimd_signeddate,
    idgr.idgr_desc,
    ims_desc,
    cim.cim_meetingstatus,
    cim.cim_open,
    wkr_fullname,
    cim.cim_voidedby,
    cim.cim_voideddate,
    cimd.cimd_lastupdate,
    md_signature.cimd_signeddate AS md_signed_date
FROM client_idg_meetings cim
JOIN client_eobs ceob ON cim.cim_ceobid = ceob.ceob_id
JOIN client_idg_meeting_Details cimd ON cimd.cimd_cimid = cim.cim_id
JOIN idg_roles idgr ON cimd.cimd_idgrid = idgr.idgr_id
JOIN workers on wkr_id = cimd_wkrid 
JOIN IDG_MEETING_STATUSES on ims_id = cimd_imsid
join IDG_MEETING_REASONS on imr_id = cim_imrid
INNER JOIN CLIENT_EPISODES_ALL epi ON epi.epi_paid = ceob.ceob_paid
LEFT JOIN (
    SELECT cimd_cimid, cimd_signeddate
    FROM client_idg_meeting_Details
    WHERE cimd_idgrid = 1 AND cimd_signeddate IS NOT NULL
) md_signature ON md_signature.cimd_cimid = cim.cim_id
WHERE ceob.ceob_paid IN ({patient_id})
    AND CAST(cim.cim_scheduledstartdate AS DATE) IN ({Date})
    AND cimd.cimd_signedby IS NOT NULL
    AND (cimd.cimd_wkrid = 'xxxxxxx' OR cimd.cimd_idgrid = 1)  -- Add Worker ID here if needed
ORDER BY 2 desc


	--===============================================


	 
	 ----------DO NOT CHANGE ANYTHING AFTER THIS POINT--------------------
	
	, @SIGNIT CHAR(1) = 'N' -- DO NOT CHANGE THIS
	, @EPIID INT = -1 -- DO NOT CHANGE THIS
Begin
	DECLARE @CIMID INT = (SELECT  CIMD_CIMID FROM  CLIENT_IDG_MEETING_DETAILS WHERE  CIMD_ID = @CIMDID) --DO NOT CHANGE THIS
	
	DECLARE @NOTOKTOUNSIGN BIT = 1
	SELECT @NOTOKTOUNSIGN = ( SELECT 1 FROM CLIENT_IDG_MEETING_DETAILS CIMD WHERE CIMD.CIMD_ID = @CIMDID AND EXISTS ( SELECT 1 FROM CLIENT_IDG_MEETING_DETAILS CIMD WHERE CIMD.CIMD_ID = @CIMDID AND EXISTS ( SELECT 1 FROM CLIENT_IDG_MEETING_DETAILS CIMD1 WHERE CIMD1.CIMD_CIMID = ( SELECT CIMD2.CIMD_CIMID FROM CLIENT_IDG_MEETING_DETAILS CIMD2 WHERE CIMD2.CIMD_ID = @CIMDID) AND CIMD1.CIMD_IDGRID = 1 AND CIMD1.CIMD_SIGNEDDATE IS NOT NULL AND CIMD1.CIMD_ID <> CIMD.CIMD_ID)))
	
	IF @NOTOKTOUNSIGN = 1
	BEGIN 
	SELECT 'ERROR: THE MEDICAL DIRECTOR HAS SIGNED THIS AND THEY WILL NEED TO BE UN-SGNED BEFORE THIS ROW AND BE UN-SIGNED'
	RETURN
	END
	ELSE
	
	BEGIN
	
	SELECT 'BEFORE'
	SELECT  * FROM CLIENT_IDG_MEETING_DETAILS CIMD WHERE CIMD.CIMD_ID = @CIMDID
	SELECT  * FROM CLIENT_IDG_MEETINGS CIM WHERE CIM.CIM_ID = ( SELECT CIMD_CIMID FROM CLIENT_IDG_MEETING_DETAILS CIMD WHERE CIMD_ID = @CIMDID)
	
	
	BEGIN TRAN
	EXEC USP_IDGSIGNMEETINGDETAILS @CIMDID,@IDGRID,@SIGNIT,@UID,@EPIID
	
	
	IF @COMMIT = 1
		BEGIN
			COMMIT
			SELECT 'COMMITTED'
			SELECT 'AFTER'
	      SELECT  * FROM CLIENT_IDG_MEETING_DETAILS CIMD WHERE CIMD.CIMD_ID = @CIMDID
		  SELECT  * FROM CLIENT_IDG_MEETINGS CIM WHERE CIM.CIM_ID = ( SELECT CIMD_CIMID FROM CLIENT_IDG_MEETING_DETAILS CIMD WHERE CIMD_ID = @CIMDID)
		  		EXEC USP_HV_IDGMEETINGREFRESH @CIMID
		END
		ELSE
		BEGIN
			SELECT 'ROLLED BACK'
			SELECT 'AFTER'
	      SELECT  * FROM CLIENT_IDG_MEETING_DETAILS CIMD WHERE CIMD.CIMD_ID = @CIMDID
		  SELECT  * FROM CLIENT_IDG_MEETINGS CIM WHERE CIM.CIM_ID = ( SELECT CIMD_CIMID FROM CLIENT_IDG_MEETING_DETAILS CIMD WHERE CIMD_ID = @CIMDID)
		  	  ROLLBACK
		END
	END
	
	
End
