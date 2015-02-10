#!/usr/bin/perl

use strict;
use DBI qw(:sql_types);

# either make the connection or DIE
my $dbh = DBI->connect(
    'dbi:Oracle:o92',
    'scott',
    'tiger',
    {
        RaiseError => 1,
        AutoCommit => 0
    }
) || die "Database connection not made: $DBI::errstr";

my $retval;

# make parse call to oracle, get statement handle
eval {
    my $func = $dbh->prepare(q{
        BEGIN
            :retval := booktitle(isbn_in => :bind1);
        END;
    });

# bind the parameters and execute
    $func->bind_param(":bind1", "0-596-00180-0");
    $func->bind_param_inout(":retval", \$retval, SQL_VARCHAR);
    $func->execute;

};

if( $@ ) {
    warn "Execution of stored procedure failed: $DBI::errstr\n";
    $dbh->rollback;
} else {
   print "Execution of stored procedure returned: $retval\n";
}

# don't forget to disconnect
$dbh->disconnect;


#======================================================================
# Supplement to the third edition of Oracle PL/SQL Programming by Steven
# Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
# Associates, Inc. To submit corrections or find more code samples visit
# http://www.oreilly.com/catalog/oraclep3/
