\c host_agent


CREATE TABLE if NOT EXISTS PUBLIC.host_info
  (

     id SERIAL NOT NULL PRIMARY KEY,
     hostname VARCHAR NOT NULL UNIQUE,
     cpu_number INT NOT NULL,
     cpu_architecture VARCHAR NOT NULL,
     cpu_model VARCHAR NOT NULL ,
     cpu_mhz  INT NOT NULL,
     L2_cache INT NOT NULL,
     total_mem INT NOT NULL,
     "timestamp" TIMESTAMP NOT NULL



  );

  CREATE TABLE if NOT EXISTS PUBLIC.host_usage
  (

  host_id SERIAL NOT NULL REFERENCES host_info(id),
  "timestamp" TIMESTAMP NOT NULL,
  memory_free INT NOT NULL,
  cpu_idle INT NOT NULL,
  cpu_kernel INT NOT NULL,
  disk_io INT NOT NULL,
  disk_available INT NOT NULL

  );
