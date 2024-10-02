SELECT top 200 (epi_lastname + ', ' + epi_firstname) AS 'NAME',epi_id,epi_status,epi_mrnum,epi_mi,epi_startofepisode AS SOE,epi_EndOfEpisode AS EOE,epi_SocDate,CEBP_BENEFITPERIOD AS BP, epi_paid  ,epi_slid
FROM CLIENT_EPISODES_ALL  
JOIN CLIENT_EPISODE_BENEFIT_PERIOD ON cebp_epiid = epi_id 
where  ({names_clause})
order by 1, 6
