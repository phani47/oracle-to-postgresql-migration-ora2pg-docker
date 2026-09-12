#### 1 . run docker for postgresql as shown in below
"docker run -d \                                
--name pg18 \
-e POSTGRES_PASSWORD=postgres \
-p 5432:5432 \
postgres:18
"

2. enter into the docker bash
docker exec -it pg18 bash

3. check the connection
psql
