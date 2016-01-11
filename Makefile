include config.mk csv.mk normalize_isbe.mk

years = 1997 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008	\
        2009 2010 2011 2012 2013 2014 2015

rcs = $(patsubst %,rc_%.csv,$(years))

csv : $(rcs)

database : act school district demography characteristics average_class_size \
           minutes_per_subject grades cps_crosswalk


.INTERMEDIATE : CPS_Schools_2013-2014_Academic_Year.csv
CPS_Schools_2013-2014_Academic_Year.csv :
	wget -O $@ https://data.cityofchicago.org/api/views/c7jj-qjvh/rows.csv?accessType=DOWNLOAD

raw_cps_crosswalk : CPS_Schools_2013-2014_Academic_Year.csv
	$(create_relation_and) "CREATE TABLE $@ \
                               (cps_id TEXT, cps_unit TEXT, rcdts TEXT, \
                                oracle_id TEXT)" \
        && csvcut -c "SchoolID","CPS Unit","ISBE ID","OracleID" $< | \
           psql -d $(PG_DB) -c 'COPY $@ FROM STDIN WITH CSV HEADER')

cps_crosswalk : raw_cps_crosswalk rcdts_crosswalk
	$(create_relation) "CREATE TABLE $@ \
                            AS SELECT school_id, cps_id, cps_unit, oracle_id \
                            FROM $< INNER JOIN $(word 2,$^) \
                            using(rcdts)"
