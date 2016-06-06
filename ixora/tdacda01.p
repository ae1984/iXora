/* tdacda01.p
 * MODULE
        Операционка
 * DESCRIPTION
        Отчет по депозитам открытым депозитам ФЛ.
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * BASES
        BANK COMM
 * AUTHOR
        25.01.2011 id00024
 * CHANGES
		21.12.2012 id00477 - ТЗ 1630 добавление столбцов Гео-код и ИИН/БИН
 
 * BASES
	TXB
 * CHANGES

*/                                                                                                                                                                                                                                                                                              

define input parameter v-tda as char.
define input parameter v-cda as char.
define input parameter v-lstmdt as date. 
define input parameter v-expdt as date. 

def var v-payfre as integer.
def var v-payfre2 as char format "x(21)".

put " ".
put skip.

output to value("tdacda.csv") append.

find first txb.cmp no-lock no-error.
put txb.cmp.name format "x(100)" skip.

for each txb.lgr where txb.lgr.led = v-tda or txb.lgr.led = v-cda no-lock:
    for each txb.aaa where txb.aaa.lgr = txb.lgr.lgr and length(txb.aaa.aaa) > 19 and txb.aaa.sta <> "C" and txb.aaa.lstmdt >= v-lstmdt and txb.aaa.lstmdt <= v-expdt no-lock:
        find txb.cif where txb.cif.cif = txb.aaa.cif no-lock.
	if avail txb.cif then do:
	v-payfre = txb.aaa.payfre.
	if v-payfre = 0 then v-payfre2 = "".
	if v-payfre = 1 then v-payfre2 = "Исключительная ставка".
	put txb.lgr.des format "x(30)" ";" txb.cif.cif format "x(6)" ";" txb.cif.name format "x(40)" ";" txb.aaa.aaa ";" txb.aaa.crc ";" txb.aaa.rate format "zz9.99" ";" txb.aaa.cbal format "->>>>>>>>>>>>>9.99" ";" txb.aaa.lstmdt format '99/99/9999' ";" txb.aaa.expdt format '99/99/9999' ";" v-payfre2 ";'" cif.geo format "x(3)" ";" cif.bin format "999999999999" ";" /*txb.cif.mname ";" txb.aaa.lgr*/ skip.
	end.
    end.
end.
put " " skip.
output close.
