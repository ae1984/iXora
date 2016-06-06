/* obm_rst2.p
 * MODULE
        Обменные операции
 * DESCRIPTION
       Ежедневный отчет обменного пункта по купленной и проданной валюте
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        3-1-10
 * AUTHOR
        31/12/99 pragma
 * BASES
        BANK COMM
 * CHANGES
        02/06/03 nataly - было добавлено условие для проводок где gl = 100200 для кассиров РЕИЗа
        18.09.2003 nadejda  - заменено слово для курса "по официальному" на "по рыночному"
        23.09.2003 nadejda   добавлена обработка кассы в обменном пункте 100300
	09.11.2005 u00121 - изменил формат вывода чисел, теперь везде, если число с минусом, будет выводиться нормально
	30.05.2006 u00121 - поиск по таблице exch_lst был без no-lock, без no-error, без avail - добавил сообщение, если запись не найдена
    02.03.12 damir - вывод формы в формате WORD (без возможности редактирования) Т.З. № 1256, добавил menu-prt.

*/
{functions-def.i}
{global.i}
{keyord.i} /*Переход на новые и старые форматы форм*/

/*define var g-ofc    like ofc.ofc initial 'dovgal'.
define var g-today  as date initial '02/25/02'.  */

define variable symb1 as integer extent 5 init [21,43,65,87,109].
define variable symb2 as integer extent 7 init [4,32,39,59,78,97,116].
define variable t_amt as decimal init 0.
define variable v_amt as decimal init 0.
define variable rur_amt as decimal init 0.
define variable tot1 as decimal.
define variable eur_amt as decimal init 0.
define variable c_dam like crc.rate[1].
define variable c_cam like crc.rate[1].
define variable i as integer.
define var tg-today  as date.

def var pwidth as int init 103.

define temp-table tot_sum
  field ts_crc like crc.crc
  field ts_dam like jl.dam
  field ts_damkzt like jl.dam
  field ts_cam like jl.cam
  field ts_camkzt like jl.cam
  index icrc is primary ts_crc.

define temp-table t_ofc
  field to_ofc like g-ofc.

def stream v-out.
def stream v-out2.

def var v-file  as char init "Rep1.htm".
def var v-file2 as char init "Rep2.htm".
def var v-inputfile as char init "/data/export/report.htm".
def var v-str       as char.

output stream v-out  to value(v-file).
output stream v-out2 to value(v-file2).

input from value(v-inputfile).
repeat:
    import unformatted v-str.
    v-str = trim(v-str).
    put stream v-out unformatted v-str.
end.
input close.

procedure add_to_TS:
define input param namt like jl.dam.
define input param nrate like crc.rate[1].

find tot_sum where ts_crc = jl.crc no-error.
if not avail tot_sum then do: create tot_sum. ts_crc = jl.crc. end.
if jl.dc = 'd' then
                 do:
                   ts_dam = ts_dam + namt.
                   ts_damkzt = ts_damkzt + namt * nrate.
                 end.
               else
                 do:
                   ts_cam = ts_cam + namt.
                   ts_camkzt = ts_camkzt + namt * nrate.
                 end.
end procedure.

tg-today = g-today.

update "Введите дату отчета: " tg-today no-label.



find first exch_lst where exch_lst.ofc_list matches ("*" + g-ofc + "*") no-lock no-error.
if not avail exch_lst then /*u00121 30/05/06*/
do:
	message "Вы не являетесь кассиром обменного пункта!" skip
		"Проверьте настройку реестра обменного пункта!" view-as alert-box.
	return.
end.
else
do:
	REPEAT i=1 TO NUM-ENTRIES(exch_lst.ofc_list):
	  create t_ofc.
	  t_ofc.to_ofc = ENTRY(i,exch_lst.ofc_list).
	end.
end.


for each t_ofc:

for each jl where (jl.gl = 100100 or jl.gl = 100200 or jl.gl = 100300) and substring(jl.rem[1],1,5) = 'Обмен' and jl.who  =t_ofc.to_ofc and jl.crc <> 1 and jl.jdt = tg-today:
    find joudoc where joudoc.jh = jl.jh and joudoc.who = jl.who and joudoc.whn =jl.jdt no-lock no-error.
      if avail joudoc
         then
           do:
             find crc where crc.crc = jl.crc no-lock no-error.
             if jl.dc = 'd' and jl.dam <> 0 then run add_to_TS(jl.dam, joudoc.brate).
             if jl.dc = 'c' and jl.cam <> 0 then run add_to_TS(jl.cam, joudoc.srate).
           end.
end.

end.

find first tot_sum no-lock no-error.
if not avail tot_sum
   then
     do:
             create tot_sum.
             tot_sum.ts_crc = 2.
             tot_sum.ts_dam = 0.
             tot_sum.ts_damkzt = 0.
             tot_sum.ts_cam    = 0.
             tot_sum.ts_camkzt = 0.
     end.

output to rpt2.img.

put stream v-out unformatted
    "<P align=center>ЕЖЕДНЕВНЫЙ ОТЧЕТ <br> обменного пункта <br> о покупке, продаже иностранной валюты и выручке <br> за " tg-today "</P>" skip.

put unformatted padc ('ЕЖЕДНЕВНЫЙ ОТЧЕТ', pwidth, ' ') skip.
put unformatted padc ('обменного пункта', pwidth, ' ') skip.
put unformatted padc ('о покупке, продаже иностранной валюты и выручке', pwidth, ' ') skip.
put unformatted fill (' ',47) 'за ' tg-today skip(1).

put stream v-out unformatted
    "<TABLE width=""100%"" bordercolor=""white"" border=""1"" cellspacing=""0"" cellpadding=""0"">" skip.
put stream v-out unformatted
    "<TR align=center><FONT size=2>" skip
    "<TD rowspan=2>№</TD>" skip
    "<TD rowspan=2>Операция</TD>" skip
    "<TD colspan=3>Валюта</TD>" skip
    "<TD rowspan=2>Тенге <br> по курсу <br> покупки/продажи</TD>" skip
    "<TD rowspan=2>Чистая выручка</TD>" skip
    "</FONT></TR>" skip
    "<TR align=center><FONT size=2>" skip
    "<TD>Вид <br> валюты</TD>" skip
    "<TD>Сумма <br> валюты</TD>" skip
    "<TD>Сумма в тенге <br> по рыночному курсу</TD>" skip
    "</FONT></TR>" skip.

put unformatted fill('-',pwidth) skip.
put "| N |" "Операция" at 7 '|' at 17 fill ('_',22) format 'x(22)' "Валюта" at 40 fill ('_',22) format 'x(22)' '|' at 68 /*fill ('_',2)*/ "Тенге" at 70 /*fill ('_',2)*/  '|' at 86 "Чистая выручка" at 87 '|' at 103 skip.
put "|   |" '|' at 17 "Вид"    at 22 '|' at 30 "Сумма"  at 32 '|' at 47 "Сумма в тенге" at 49 '|' at 68 "По курсу" at 70  '|' at 86 '|' at 103 skip.
put "|   |" '|' at 17 "валюты" at 20 '|' at 30 "валюты" at 32 '|' at 47 "по рыноч-"  at 49 '|' at 68 "покупки/продажи" at 70  '|' at 86 '|' at 103 skip.
put "|   |" '|' at 17 '|'                at 30 '|'                at 47 "ному курсу"    at 49 '|' at 68 '|' at 86 '|' at 103 skip.
put unformatted fill('-',pwidth) skip.

find first exch_lst where exch_lst.ofc_list matches ("*" + g-ofc + "*") and exch_lst.crc = 1 no-lock no-error.
if avail exch_lst then t_amt = exch_lst.bamt.

find first exch_lst where exch_lst.ofc_list matches ("*" + g-ofc + "*") and exch_lst.crc = 2 no-lock no-error.
if avail exch_lst then v_amt = exch_lst.bamt.

find first exch_lst where exch_lst.ofc_list matches ("*" + g-ofc + "*") and exch_lst.crc = 3 no-lock no-error.
if avail exch_lst then eur_amt = exch_lst.bamt.


put stream v-out unformatted
    "<TR align=center><FONT size=2>" skip
    "<TD></TD>" skip
    "<TD>Получено</TD>" skip
    "<TD>KZT</TD>" skip
    "<TD>" string(t_amt,"-z,zzz,zzz,zz9.99") "</TD>" skip
    "<TD></TD>" skip
    "<TD></TD>" skip
    "<TD></TD>" skip
    "</FONT></TR>" skip
    "<TR align=center><FONT size=2>" skip
    "<TD>1</TD>" skip
    "<TD>валюты</TD>" skip
    "<TD>USD</TD>" skip
    "<TD>" string(v_amt,"-z,zzz,zzz,zz9.99") "</TD>" skip
    "<TD></TD>" skip
    "<TD></TD>" skip
    "<TD></TD>" skip
    "</FONT></TR>" skip
    "<TR align=center><FONT size=2>" skip
    "<TD></TD>" skip
    "<TD>и тенге</TD>" skip
    "<TD>EUR</TD>" skip
    "<TD>" string(eur_amt,"-z,zzz,zzz,zz9.99") "</TD>" skip
    "<TD></TD>" skip
    "<TD></TD>" skip
    "<TD></TD>" skip
    "</FONT></TR>" skip.

put "|   |" " Получено" '|' at 17 ' KZT ' '|' at 30 t_amt format '-z,zzz,zzz,zz9.99' '|' at 47 '|' at 68 '|' at 86 '|' at 103 skip.
put "| 1 |" "  валюты " '|' at 17 ' USD ' '|' at 30 v_amt format '-z,zzz,zzz,zz9.99' '|' at 47 '|' at 68 '|' at 86 '|' at 103 skip.
put "|   |" " и тенге " '|' at 17 ' EUR ' '|' at 30 eur_amt format '-z,zzz,zzz,zz9.99' '|' at 47 '|' at 68 '|' at 86 '|' at 103 skip.

find first exch_lst where exch_lst.ofc_list matches ("*" + g-ofc + "*") and exch_lst.crc = 4 no-lock no-error.
if avail exch_lst then do:
    rur_amt = exch_lst.bamt.
    put stream v-out unformatted
        "<TR align=center><FONT size=2>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD>RUR</TD>" skip
        "<TD>" string(rur_amt,"-z,zzz,zzz,zz9.99") "</TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "</FONT></TR>" skip.

    put "|   |" "         " '|' at 17 ' RUR ' '|' at 30 rur_amt format '-z,zzz,zzz,zz9.99' '|' at 47 '|' at 68 '|' at 86 '|' at 103 skip.
end.
else rur_amt = - 9999999999.


put unformatted fill('-',pwidth) skip.


find tot_sum where tot_sum.ts_crc = 2 no-lock no-error.
/*find crc where crc.crc = 2 no-lock no-error.*/
find last ncrchis where ncrchis.crc = 2 and ncrchis.rdt <= tg-today no-lock no-error.
if avail tot_sum then do:
    put stream v-out unformatted
        "<TR align=center><FONT size=2>" skip
        "<TD></TD>" skip
        "<TD>Куплено</TD>" skip
        "<TD>USD</TD>" skip
        "<TD>" string(ts_dam,"-z,zzz,zzz,zz9.99") "</TD>" skip
        "<TD>" string(ts_dam * ncrchis.rate[1],"-z,zzz,zzz,zz9.99") "</TD>" skip
        "<TD>" string(ts_damkzt,"-z,zzz,zzz,zz9.99") "</TD>" skip
        "<TD>" string(ts_dam * ncrchis.rate[1] - ts_damkzt,"-z,zzz,zzz,zz9.99") "</TD>" skip
        "</FONT></TR>" skip
        "<TR align=center><FONT size=2>" skip
        "<TD>2</TD>" skip
        "<TD>валюты</TD>" skip
        "<TD>USD</TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "</FONT></TR>" skip.

    put "|   |" " Куплено " '|' at 17 ' USD '
                            '|' at 30 ts_dam format '-z,zzz,zzz,zz9.99'
                            '|' at 47 ts_dam * ncrchis.rate[1] format '-z,zzz,zzz,zz9.99'
                            '|' at 68 ts_damkzt format '-z,zzz,zzz,zz9.99'
                            '|' at 86 ts_dam * ncrchis.rate[1] - ts_damkzt format '-zzz,zzz,zz9.99'
                            '|' at 103 skip.
    put "| 2 |" "  валюты " '|' at 17 ' USD '
                            '|' at 30
                            '|' at 47
                            '|' at 68 '|' at 86 '|' at 103 skip.
end.
else do:
    put stream v-out unformatted
        "<TR align=center><FONT size=2>" skip
        "<TD></TD>" skip
        "<TD>Куплено</TD>" skip
        "<TD>USD</TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "</FONT></TR>" skip
        "<TR align=center><FONT size=2>" skip
        "<TD>2</TD>" skip
        "<TD>валюты</TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "</FONT></TR>" skip.

    put "|   |" " Куплено " '|' at 17 ' USD '
                            '|' at 30
                            '|' at 47
                            '|' at 68
                            '|' at 86
                            '|' at 103 skip.
    put "| 2 |" "  валюты " '|' at 17
                            '|' at 30
                            '|' at 47
                            '|' at 68 '|' at 86 '|' at 103 skip.
end.

release tot_sum.

find tot_sum where tot_sum.ts_crc = 3 no-lock no-error.
/*find crc where crc.crc = 3 no-lock no-error.*/
find last ncrchis where ncrchis.crc = 3 and ncrchis.rdt <= tg-today no-lock no-error.

if not avail tot_sum then do:
    put stream v-out unformatted
        "<TR align=center><FONT size=2>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD>EUR</TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "</FONT></TR>" skip.

    put "|   |" "         " '|' at 17 ' EUR ' '|' at 30 '|' at 47 '|' at 68 '|' at 86 '|' at 103 skip.
end.
else do:
    put stream v-out unformatted
        "<TR align=center><FONT size=2>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD>EUR</TD>" skip
        "<TD>" string(ts_dam,"-z,zzz,zzz,zz9.99") "</TD>" skip
        "<TD>" string(ts_dam * ncrchis.rate[1],"-z,zzz,zzz,zz9.99") "</TD>" skip
        "<TD>" string(ts_damkzt,"-z,zzz,zzz,zz9.99") "</TD>" skip
        "<TD>" string(ts_dam * ncrchis.rate[1] - ts_damkzt,"-z,zzz,zzz,zz9.99") "</TD>" skip
        "</FONT></TR>" skip.


    put "|   |" "         " '|' at 17 ' EUR '
                        '|' at 30 ts_dam format '-z,zzz,zzz,zz9.99'
                        '|' at 47 ts_dam * ncrchis.rate[1] format '-z,zzz,zzz,zz9.99'
                        '|' at 68 ts_damkzt format '-z,zzz,zzz,zz9.99'
                        '|' at 86 ts_dam * ncrchis.rate[1] - ts_damkzt format '-zzz,zzz,zz9.99'
                        '|' at 103 skip.
end.

find tot_sum where tot_sum.ts_crc = 4 no-lock no-error.
find last ncrchis where ncrchis.crc = 4 and ncrchis.rdt <= tg-today no-lock no-error.

if not avail tot_sum then do:
    put stream v-out unformatted
        "<TR align=center><FONT size=2>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD>RUR</TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "</FONT></TR>" skip.
    put "|   |" "         " '|' at 17 ' RUR ' '|' at 30 '|' at 47 '|' at 68 '|' at 86 '|' at 103 skip.
end.
else do:
    put stream v-out unformatted
        "<TR align=center><FONT size=2>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD>RUR</TD>" skip
        "<TD>" string(ts_dam,"-z,zzz,zzz,zz9.99") "</TD>" skip
        "<TD>" string(ts_dam * ncrchis.rate[1],"-z,zzz,zzz,zz9.99") "</TD>" skip
        "<TD>" string(ts_damkzt,"-z,zzz,zzz,zz9.99") "</TD>" skip
        "<TD>" string(ts_dam * ncrchis.rate[1] - ts_damkzt,"-z,zzz,zzz,zz9.99") "</TD>" skip
        "</FONT></TR>" skip.

    put "|   |" "         " '|' at 17 ' RUR '
                        '|' at 30 ts_dam format '-z,zzz,zzz,zz9.99'
                        '|' at 47 ts_dam * ncrchis.rate[1] format '-z,zzz,zzz,zz9.99'
                        '|' at 68 ts_damkzt format '-z,zzz,zzz,zz9.99'
                        '|' at 86 ts_dam * ncrchis.rate[1] - ts_damkzt format '-zzz,zzz,zz9.99'
                        '|' at 103 skip.
end.

put unformatted fill('-',pwidth) skip.

release tot_sum.

find tot_sum where tot_sum.ts_crc = 2 no-lock no-error.
find last ncrchis where ncrchis.crc = 2 and ncrchis.rdt <= tg-today no-lock no-error.

if avail tot_sum then do:
    put stream v-out unformatted
        "<TR align=center><FONT size=2>" skip
        "<TD></TD>" skip
        "<TD>Продано</TD>" skip
        "<TD>USD</TD>" skip
        "<TD>" string(ts_cam,"-z,zzz,zzz,zz9.99") "</TD>" skip
        "<TD>" string(ts_cam * ncrchis.rate[1],"-z,zzz,zzz,zz9.99") "</TD>" skip
        "<TD>" string(ts_camkzt,"-z,zzz,zzz,zz9.99") "</TD>" skip
        "<TD>" string(ts_camkzt - ts_cam * ncrchis.rate[1],"-z,zzz,zzz,zz9.99") "</TD>" skip
        "</FONT></TR>" skip
        "<TR align=center><FONT size=2>" skip
        "<TD>3</TD>" skip
        "<TD>валюты</TD>" skip
        "<TD>RUR</TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "</FONT></TR>" skip.

    put "|   |" " Продано " '|' at 17 ' USD '
                            '|' at 30 ts_cam format '-z,zzz,zzz,zz9.99'
                            '|' at 47 ts_cam * ncrchis.rate[1] format '-z,zzz,zzz,zz9.99'
                            '|' at 68 ts_camkzt format '-z,zzz,zzz,zz9.99'
                            '|' at 86 ts_camkzt - ts_cam * ncrchis.rate[1] format '-zzz,zzz,zz9.99'
                            '|' at 103 skip.
    put "| 3 |" "  валюты " '|' at 17 '|' at 30 '|' at 47 '|' at 68 '|' at 86 '|' at 103 skip.
end.
else do:
    put stream v-out unformatted
        "<TR align=center><FONT size=2>" skip
        "<TD></TD>" skip
        "<TD>Продано</TD>" skip
        "<TD>USD</TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "</FONT></TR>" skip
        "<TR align=center><FONT size=2>" skip
        "<TD>3</TD>" skip
        "<TD>валюты</TD>" skip
        "<TD>USD</TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "</FONT></TR>" skip.

    put "|   |" " Продано " '|' at 17 ' USD '
                            '|' at 30
                            '|' at 47
                            '|' at 68
                            '|' at 86
                            '|' at 103 skip.
    put "| 3 |" "  валюты " '|' at 17 '|' at 30 '|' at 47 '|' at 68 '|' at 86 '|' at 103 skip.
end.

release tot_sum.

find tot_sum where tot_sum.ts_crc = 3 no-lock no-error.
find last ncrchis where ncrchis.crc = 3 and ncrchis.rdt <= tg-today no-lock no-error.

if not avail tot_sum then do:
    put stream v-out unformatted
        "<TR align=center><FONT size=2>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD>EUR</TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "</FONT></TR>" skip.

    put "|   |" "         " '|' at 17 ' EUR ' '|' at 30 '|' at 47 '|' at 68 '|' at 86 '|' at 103 skip.
end.
else do:
    put stream v-out unformatted
        "<TR align=center><FONT size=2>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD>EUR</TD>" skip
        "<TD>" string(ts_cam,"-z,zzz,zzz,zz9.99") "</TD>" skip
        "<TD>" string(ts_cam * ncrchis.rate[1],"-z,zzz,zzz,zz9.99") "</TD>" skip
        "<TD>" string(ts_camkzt,"-z,zzz,zzz,zz9.99") "</TD>" skip
        "<TD>" string(ts_camkzt - ts_cam * ncrchis.rate[1],"-z,zzz,zzz,zz9.99") "</TD>" skip
        "</FONT></TR>" skip.

    put "|   |" "         " '|' at 17 ' EUR '
                        '|' at 30 ts_cam format '-z,zzz,zzz,zz9.99'
                        '|' at 47 ts_cam * ncrchis.rate[1] format '-z,zzz,zzz,zz9.99'
                        '|' at 68 ts_camkzt format '-z,zzz,zzz,zz9.99'
                        '|' at 86 ts_camkzt - ts_cam * ncrchis.rate[1] format '-zzz,zzz,zz9.99'
                        '|' at 103 skip.
end.
find tot_sum where tot_sum.ts_crc = 4 no-lock no-error.
find last ncrchis where ncrchis.crc = 4 and ncrchis.rdt <= tg-today no-lock no-error.

if not avail tot_sum then do:
    put stream v-out unformatted
        "<TR align=center><FONT size=2>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD>RUR</TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "</FONT></TR>" skip.
    put "|   |" "         " '|' at 17 ' RUR ' '|' at 30 '|' at 47 '|' at 68 '|' at 86 '|' at 103 skip.
end.
else do:
    put stream v-out unformatted
        "<TR align=center><FONT size=2>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD>RUR</TD>" skip
        "<TD>" string(ts_cam,"-z,zzz,zzz,zz9.99") "</TD>" skip
        "<TD>" string(ts_cam * ncrchis.rate[1],"-z,zzz,zzz,zz9.99") "</TD>" skip
        "<TD>" string(ts_camkzt,"-z,zzz,zzz,zz9.99") "</TD>" skip
        "<TD>" string(ts_camkzt - ts_cam * ncrchis.rate[1],"-z,zzz,zzz,zz9.99") "</TD>" skip
        "</FONT></TR>" skip.

    put "|   |" "         " '|' at 17 ' RUR '
                        '|' at 30 ts_cam format '-z,zzz,zzz,zz9.99'
                        '|' at 47 ts_cam * ncrchis.rate[1] format '-z,zzz,zzz,zz9.99'
                        '|' at 68 ts_camkzt format '-z,zzz,zzz,zz9.99'
                        '|' at 86 ts_camkzt - ts_cam * ncrchis.rate[1] format '-zzz,zzz,zz9.99'
                        '|' at 103 skip.
end.

put unformatted fill('-',pwidth) skip.

for each tot_sum:

find last ncrchis where ncrchis.crc = tot_sum.ts_crc and ncrchis.rdt <= tg-today no-lock no-error.
t_amt=t_amt - ts_damkzt + ts_camkzt.

end.

put stream v-out unformatted
    "<TR align=center><FONT size=2>" skip
    "<TD></TD>" skip
    "<TD>Сдано</TD>" skip
    "<TD>KZT</TD>" skip
    "<TD>" string(t_amt,"-z,zzz,zzz,zz9.99") "</TD>" skip
    "<TD></TD>" skip
    "<TD></TD>" skip
    "<TD></TD>" skip
    "</FONT></TR>" skip.

put "|   |" " Сдано  " '|' at 17 ' KZT ' '|' at 30 t_amt format '-z,zzz,zzz,zz9.99' '|' at 47 '|' at 68 '|' at 86 '|' at 103 skip.

find tot_sum where tot_sum.ts_crc = 2 no-lock no-error.
find last ncrchis where ncrchis.crc = 2 and ncrchis.rdt <= tg-today no-lock no-error.

if avail tot_sum then do:
    put stream v-out unformatted
        "<TR align=center><FONT size=2>" skip
        "<TD>4</TD>" skip
        "<TD>валюты</TD>" skip
        "<TD>USD</TD>" skip
        "<TD>" string(v_amt + ts_dam - ts_cam,"-z,zzz,zzz,zz9.99") "</TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "</FONT></TR>" skip.

    put "| 4 |" " валюты " '|' at 17 ' USD ' '|' at 30 v_amt + ts_dam - ts_cam format '-z,zzz,zzz,zz9.99' '|' at 47 '|' at 68 '|' at 86 '|' at 103 skip.
end.
else do:
    put stream v-out unformatted
        "<TR align=center><FONT size=2>" skip
        "<TD>4</TD>" skip
        "<TD>валюты</TD>" skip
        "<TD>USD</TD>" skip
        "<TD>" string(v_amt,"-z,zzz,zzz,zz9.99") "</TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "</FONT></TR>" skip.

    put "| 4 |" " валюты " '|' at 17 ' USD ' '|' at 30 v_amt format '-z,zzz,zzz,zz9.99' '|' at 47 '|' at 68 '|' at 86 '|' at 103 skip.
end.

find tot_sum where tot_sum.ts_crc = 3 no-lock no-error.
find last ncrchis where ncrchis.crc = 3 and ncrchis.rdt <= tg-today no-lock no-error.

if not avail tot_sum then do:
    put stream v-out unformatted
        "<TR align=center><FONT size=2>" skip
        "<TD></TD>" skip
        "<TD>и тенге</TD>" skip
        "<TD>EUR</TD>" skip
        "<TD>" string(eur_amt,"-z,zzz,zzz,zz9.99") "</TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "</FONT></TR>" skip.

    put "|   |" " и тенге" '|' at 17 ' EUR ' '|' at 30 eur_amt format '-z,zzz,zzz,zz9.99' '|' at 47 '|' at 68 '|' at 86 '|' at 103 skip.
end.
else do:
    put stream v-out unformatted
        "<TR align=center><FONT size=2>" skip
        "<TD></TD>" skip
        "<TD>и тенге</TD>" skip
        "<TD>EUR</TD>" skip
        "<TD>" string(eur_amt + ts_dam - ts_cam,"-z,zzz,zzz,zz9.99") "</TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "</FONT></TR>" skip.
    put "|   |" " и тенге" '|' at 17 ' EUR ' '|' at 30 eur_amt + ts_dam - ts_cam format '-z,zzz,zzz,zz9.99' '|' at 47 '|' at 68 '|' at 86 '|' at 103 skip.
end.
find tot_sum where tot_sum.ts_crc = 4 no-lock no-error.
find last ncrchis where ncrchis.crc = 4 and ncrchis.rdt <= tg-today no-lock no-error.

if rur_amt <> -9999999999 then do:
    if not avail tot_sum then do:
        put stream v-out unformatted
        "<TR align=center><FONT size=2>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD>RUR</TD>" skip
        "<TD>" string(rur_amt,"-z,zzz,zzz,zz9.99") "</TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "</FONT></TR>" skip.

        put "|   |" "        " '|' at 17 ' RUR ' '|' at 30 rur_amt format '-z,zzz,zzz,zz9.99' '|' at 47 '|' at 68 '|' at 86 '|' at 103 skip.
    end.
    else do:
        put stream v-out unformatted
        "<TR align=center><FONT size=2>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD>RUR</TD>" skip
        "<TD>" string(rur_amt + ts_dam - ts_cam,"-z,zzz,zzz,zz9.99") "</TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "</FONT></TR>" skip.

        put "|   |" "        " '|' at 17 ' RUR ' '|' at 30 rur_amt + ts_dam - ts_cam format '-z,zzz,zzz,zz9.99' '|' at 47 '|' at 68 '|' at 86 '|' at 103 skip.
    end.
end.

put unformatted fill('-',pwidth) skip.

tot1=0.


for each tot_sum:

    find last ncrchis where ncrchis.crc = tot_sum.ts_crc and ncrchis.rdt <= tg-today no-lock no-error.
    tot1 = tot1 + ts_dam * ncrchis.rate[1] - ts_damkzt + ts_camkzt - ts_cam * ncrchis.rate[1].

end.
put stream v-out unformatted
    "<TR align=center><FONT size=2>" skip
    "<TD colspan=6>Итого</TD>" skip
    "<TD>" string(tot1,"-z,zzz,zzz,zz9.99") "</TD>" skip
    "</FONT></TR>" skip
    "</TABLE>" skip
    "<P></P>" skip
    "<P></P>" skip
    "<P align=left><FONT size=2>Подписи:</FONT></P>" skip
    "<P align=left><FONT size=2>Кассир обменного пункта __________________________   Директор _________________________</FONT></P>" skip.

put "|Итого" '|' at 86  tot1 format '-zzz,zzz,zz9.99' '|' at 103 skip.
put unformatted fill('-',pwidth) skip(2).

put "Подписи:" skip(1).
put "Кассир обменного пункта                              Директор" skip.
put "_______________________                              ___________________" skip.

/*

for each tot_sum:
    find crc where crc.crc = tot_sum.ts_crc no-lock no-error.
    put '| ' 'Всего  ' '|' at symb2[2] crc.code at 33 '|' at symb2[3]
                                               tot_sum.ts_dam    format '-zzz,zzz,zzz,zz9.99'  at 40 '|' at symb2[4]
                                               tot_sum.ts_damkzt format '-zzz,zzz,zzz,zz9.99'  at 60 '|' at symb2[5]
                                               tot_sum.ts_cam    format '-zzz,zzz,zzz,zz9.99'  at 79 '|' at symb2[6]
                                               tot_sum.ts_camkzt format '-zzz,zzz,zzz,zz9.99'  at 98 '|' at symb2[7] '|' at 128
                                       skip.
end.*/

output close.

output stream v-out close.

input from value(v-file).
repeat:
    import unformatted v-str.
    v-str = trim(v-str).
    repeat:
        if v-str matches "*</body>*" then do:
            v-str = replace(v-str,"</body>","").
            next.
        end.
        if v-str matches "*</html>*" then do:
            v-str = replace(v-str,"</html>","").
            next.
        end.
        else v-str = trim(v-str).
        leave.
    end.
    put stream v-out2 unformatted v-str skip.
end.
input close.
output stream v-out2 close.

unix silent cptwin value(v-file2) winword.

pause 0 before-hide .
run menu-prt('rpt2.img').
pause before-hide.

{functions-end.i}



