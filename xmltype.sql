/* Formatted on 2002/04/02 07:15 (Formatter Plus v4.5.2) */
DROP TABLE env_analysis;

CREATE TABLE env_analysis (
   company VARCHAR2(100),
   site_visit_date DATE,
   report xmltype);

INSERT INTO env_analysis
     VALUES ('ACME SILVERPLATING', TO_DATE (
                                      '15-02-2001',
                                      'DD-MM-YYYY'
                                   ), 
        -- Oracle9i Release 1 syntax:
        xmltype.createxml (
                                         '<?xml version="1.0"?>
        <report>
           <site>1105 5th Street</site>
           <substance>PCP</substance>
           <level>1054</level>
        </report>'
                                      ));

INSERT INTO env_analysis
     VALUES ('SMOKESTAX INC', TO_DATE (
                                 '22-07-2001',
                                 'DD-MM-YYYY'
                              ), 
     -- Oracle9i Release 2 syntax:
     xmltype (
     '<?xml version="1.0"?>
        <report>
           <site>Lake Michigan</site>
           <substance>PCP</substance>
           <level>1744</level>
        </report>'
                                 ));
                                 
                                                                       
SELECT ea.report.getstringval()
  FROM env_analysis ea;

DECLARE
   doc   xmltype;
BEGIN
   SELECT ea.report
     INTO doc
     FROM env_analysis ea
    WHERE company = 'ACME SILVERPLATING';

   do.pl (doc);
END;
/

