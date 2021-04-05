SELECT cpu_number,id,total_mem from host_info
ORDER BY cpu_number,total_mem DESC;

CREATE FUNCTION round5s(ts timestamptz) RETURNS timestamptz AS
$$
	BEGIN
	RETURN date_trunc('hour', ts) + date_part('minute', ts):: int / 5 * interval '5 min';
	END;
$$
LANGUAGE PLPGSQL;

SELECT	host_name, per5, used_memory, AVG(used_memory) OVER (PARTITION BY per5)
FROM
	(SELECT host_name, round5s(time_capture) as per5, (total_mem - memory_free)/total_mem::float as used_memory
	FROM 		sample_info
	INNER JOIN 	sample_usage
	USING 		(host_info_id)) AS temp;

-- list the host number of the hosts that failed to insert at least 3 entries to the host_usage table every 5 mintues
SELECT 	host_name, the_count
FROM
	(SELECT 	host_name, count(per5) as the_count
	FROM
		(SELECT 	host_name, round5s(time_capture) as per5
		FROM 		sample_info) as temp
	GROUP BY 	host_name, per5
	ORDER BY 	host_name) as newTemp
WHERE	the_count < 3;

