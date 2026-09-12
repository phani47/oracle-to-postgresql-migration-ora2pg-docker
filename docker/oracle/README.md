### 1 . run docker for oracle as shown in below
"docker run -d --name oracle-free \
  -p 1521:1521 \
  -e ORACLE_PASSWORD=<PWD> \
  container-registry.oracle.com/database/free:latest"


  #### 2. enter into the docker bash
  docker exec -it oracle-free bash

  ### 3. check the connection
  sqlplus monitor/<PWD>@freepdb1
