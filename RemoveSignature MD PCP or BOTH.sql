GUIDANCE:{StageID_Other}/*PCP MD or BOTH*/

SELECT CONCAT(cea.epi_lastname, ', ', cea.epi_firstname) AS patient_name,o_epiid, o_orderdate,CONVERT(date, cea.epi_StartOfEpisode) SOE, o_id, o_meddirsigneddate, o_physiciansigneddate, o_cevid,o_otid, o_nursedate,o_deleted,o_voidedby,o_declinedby,o_approvedby, o_dateapproved,o_physiciansigneddate,
o_meddirsigneddate,o.o_phid,o.o_primarysignedphid,  o.o_meddirsignedphid , o_sendtophysician,o_sendtomeddir,o_howsent,o_physiciansentdate,o_physicianexpecteddate, o_meddirhowsent,o_meddirsentdate,o_desc
FROM client_orders_all AS o
JOIN client_episodes_all AS cea ON o.o_epiid = cea.epi_id
WHERE o.o_id IN ({order_id})


-- Declare the variable to specify which signatures to remove
DECLARE @SignatureOption VARCHAR(10) = '{StageID_Other}'; -- Possible values: 'PCP', 'MD', 'BOTH'

-- Create a temporary table to store original dates
CREATE TABLE #TempDatesOrderSnapshot (
    o_id INT,
    o_physiciansigneddate DATETIME,
    o_meddirsigneddate DATETIME
)

-- Insert original dates into the temporary table
INSERT INTO #TempDatesOrderSnapshot (o_id, o_physiciansigneddate, o_meddirsigneddate)
SELECT o_id, o_physiciansigneddate, o_meddirsigneddate
FROM CLIENT_ORDERS
WHERE o_id IN ({order_id}) -- Replace {order_id} with your specific order IDs

-- Begin transaction
BEGIN TRAN

-- Nullify signatures based on @SignatureOption
UPDATE CLIENT_ORDERS
SET
    o_physiciansigneddate = CASE WHEN @SignatureOption IN ('PCP', 'BOTH') THEN NULL ELSE o_physiciansigneddate END,
    o_meddirsigneddate = CASE WHEN @SignatureOption IN ('MD', 'BOTH') THEN NULL ELSE o_meddirsigneddate END
WHERE o_id IN (SELECT o_id FROM #TempDatesOrderSnapshot)

-- Verify the NULL update
SELECT o_id, o_physiciansigneddate, o_meddirsigneddate
FROM CLIENT_ORDERS
WHERE o_id IN (SELECT o_id FROM #TempDatesOrderSnapshot)

-- Restore signatures not selected for removal
UPDATE c
SET
    c.o_physiciansigneddate = CASE WHEN @SignatureOption NOT IN ('PCP', 'BOTH') THEN t.o_physiciansigneddate ELSE c.o_physiciansigneddate END,
    c.o_meddirsigneddate = CASE WHEN @SignatureOption NOT IN ('MD', 'BOTH') THEN t.o_meddirsigneddate ELSE c.o_meddirsigneddate END
FROM CLIENT_ORDERS c
JOIN #TempDatesOrderSnapshot t ON c.o_id = t.o_id

-- Verify the restore
SELECT o_id, o_physiciansigneddate, o_meddirsigneddate
FROM CLIENT_ORDERS
WHERE o_id IN (SELECT o_id FROM #TempDatesOrderSnapshot)

-- Commit transaction
COMMIT

-- Clean up
DROP TABLE #TempDatesOrderSnapshot
