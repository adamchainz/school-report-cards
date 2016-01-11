97_col = 5 3 4 2
98_col = 3 1 2 0
99_col = 4 2 3 1
00_col = 4 2 3 1

define unzip-rename
unzip -p $< > $@
endef

%.zip :
	wget http://www.isbe.net/research/zip/$@

.INTERMEDIATE : rc11.zip rc12.zip rc13.zip rc14.zip
rc11.zip rc12.zip rc13.zip rc14.zip :
	wget http://www.isbe.net/assessment/zip/$@

rc02All.zip :
	wget http://www.isbe.net/research/Report_Card_02/rc02All.zip
	touch $@


.INTERMEDIATE: RC06_layout.xls RC98_layout.xls rc98bu.zip	\
               RC99_layout.xls rc99lay.zip RC00_layout.xls	\
               Rc00lay.zip RC01_layout.xls RC01_layout.zip	\
               RC02_layout.xls RC03_layout.zip RC03_layout.xls	\
               RC06_layout.xls RC10_layout.xls RC11_layout.xls	\
               RC12_layout.xls

RC9%_layout.xls : rc9%.zip
	$(unzip-rename)

RC98_layout.xls : rc98u.zip
	$(unzip-rename)

RC99_layout.xls : rc99lay.zip
	$(unzip-rename)

RC0%_layout.xls :
	wget ftp://ftp.isbe.net/SchoolReportCard/200$*%20School%20Report%20Card/$@

RC00_layout.xls : Rc00lay.zip
	$(unzip-rename)

RC01_layout.xls : RC01_layout.zip
	$(unzip-rename)

RC02_layout.xls :
	wget -O $@ http://www.isbe.net/research/Report_Card_02/ReportCard02_layout.xls

RC03_layout.xls :
	wget http://www.isbe.net/research/xls/RC03_layout.xls

RC06_layout.xls :
	wget "ftp://ftp.isbe.net/SchoolReportCard/2006%20School%20Report%20Card(updated%20033007)/RC06_layout.xls"

RC10_layout.xls :
	wget http://www.isbe.net/research/xls/RC10_layout.xls

RC1%_layout.xlsx :
	wget -O $@ ftp://ftp.isbe.net/SchoolReportCard/201$*%20School%20Report%20Card/$@

RC11_layout.xls :
	wget http://www.isbe.net/assessment/xls/RC11_layout.xls

RC12_layout.xls :
	wget -O $@ http://www.isbe.net/assessment/xls/RC12-layout.xls


%.csv : %.xls 
	unoconv --format csv $<

.INTERMEDIATE: RC13_layout.csv RC14_layout.csv RC15_layout.csv
RC13_layout.csv RC14_layout.csv RC15_layout.csv : %.csv : %.xlsx 
	unoconv --format csv $<

schema_19%.csv : RC%_layout.csv
	cat $< | python schema.py $($*_col) | python normalize_schema.py > $@

schema_20%.csv : RC%_layout.csv
	cat $< | python schema.py $($*_col) | python normalize_schema.py > $@

.INTERMEDIATE : rc1998u.txt rc98u.zip rc2000u.txt Rc00u.zip		\
                rc02All.zip rc2002u.txt rc2004u.txt			\
                rc04u_updated092005.zip rc2006u.txt rc06.zip		\
                rc2007u.txt rc07.zip rc2009u.txt rc09.zip rc2010u.txt	\
                rc10.zip rc2015u.txt

rc199%u.txt : rc9%u.zip
	$(unzip-rename)

rc1998u.txt : rc98bu.zip
	$(unzip-rename)

rc200%u.txt : rc0%u.zip
	$(unzip-rename)

rc2000u.txt : Rc00u.zip
	$(unzip-rename)

rc2002u.txt : rc02All.zip
	$(unzip-rename)

rc2004u.txt : rc04u_updated092005.zip
	$(unzip-rename)

rc2006u.txt rc2007u.txt rc2009u.txt rc2010u.txt : rc20%u.txt : rc%.zip
	$(unzip-rename)

rc2015u.txt :
	wget -O $@ ftp://ftp.isbe.net/SchoolReportCard/2015%20School%20Report%20Card/rc15.txt

rc_%.csv : rc%u.txt schema_%.csv
	in2csv -s $(word 2, $^) $< > $@
