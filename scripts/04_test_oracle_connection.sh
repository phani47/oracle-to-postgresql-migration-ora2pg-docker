#!/bin/bash

read -s ORACLE_PWD

docker run --rm \
--platform linux/amd64 \
--network db-migration-network \
--entrypoint /bin/bash \
-e ORA2PG_PASSWD="$ORACLE_PWD" \
georgmoser/ora2pg:25.0 \
-c 'perl -MDBI -e '\''
my $dsn =
"dbi:Oracle:host=oracle-free;port=1521;service_name=freepdb1";

my $dbh = DBI->connect(
    $dsn,
    "HR",
    $ENV{ORA2PG_PASSWD},
    {
        RaiseError => 1,
        PrintError => 0
    }
);

print "Oracle connection SUCCESS\n";

$dbh->disconnect;
'\'''