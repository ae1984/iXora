/* tdacda02.p
 * MODULE
        Операционка
 * DESCRIPTION
        Отчет по открытым депозитам ФЛ для одного филиала.
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
        31/05/2011 dmitriy
 * CHANGES
		21.12.2012 id00477 - ТЗ 1630 добавление столбцов Гео-код и ИИН/БИН

 * BASES

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

find first cmp no-lock no-error.
put cmp.name format "x(100)" skip.

for each lgr where lgr.led = v-tda or lgr.led = v-cda no-lock:
    for each aaa where aaa.lgr = lgr.lgr and length(aaa.aaa) > 19 and aaa.sta <> "C" and aaa.lstmdt >= v-lstmdt and aaa.lstmdt <= v-expdt no-lock:
        find cif where cif.cif = aaa.cif no-lock.
	if avail cif then do:
	v-payfre = aaa.payfre.
	if v-payfre = 0 then v-payfre2 = "".
	if v-payfre = 1 then v-payfre2 = "Исключительная ставка".
	put lgr.des format "x(30)" ";" cif.cif format "x(6)" ";" cif.name format "x(40)" ";" aaa.aaa ";" aaa.crc ";" aaa.rate format "zz9.99" ";" aaa.cbal format "->>>>>>>>>>>>>9.99" ";" aaa.lstmdt format '99/99/9999' ";" aaa.expdt format '99/99/9999' ";" v-payfre2 ";'" cif.geo format "x(3)" ";" cif.bin format "999999999999" ";" /*cif.mname ";" aaa.lgr*/ skip.
	end.
    end.
end.
put " " skip.
output close.
