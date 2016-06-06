/* kdobes.p Электронное кредитное досье

 * MODULE
     Кредитный модуль
 * DESCRIPTION
       Список залогов
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
       
 * AUTHOR
        11.12.03 marinav
 * CHANGES
        11.01.04 marinav - добавила пор номер залога для связки его со списком документов
        30/04/2004 madiar - просмотр досье филиалов в ГБ
        17/05/2004 madiar - исправил ошибку при просмотре досье филиалов в ГБ
        20/05/2004 madiar - В find kdlon добавил еще проверку на kdcif - иначе находилось несколько записей в kdlon с одинаковыми номерами досье
        30/09/2005 madiar - добавил в описание обеспечения площадь и адрес
        14/10/2005 madiar - результат h-kdname'а пишется сразу в переменную, а не в screenvalue
        03/11/2005 madiar - перекомпиляция
    05/09/06   marinav - добавление индексов
*/



{global.i}
{kd.i}
{pksysc.f}

if s-kdlon = '' then return.

find kdlon where kdlon.kdcif = s-kdcif and kdlon.kdlon = s-kdlon and (kdlon.bank = s-ourbank or s-ourbank = "TXB00") no-lock no-error.

if not avail kdlon then do:
  message skip " Досье N" s-kdlon "не найдено !" skip(1)
    view-as alert-box buttons ok title " ОШИБКА ! ".
  return.
end.

def var s-full as char.
def var s-use as char.
def var s-land as char.
def var v-mest as deci init 0.

def var v-urep as char.
def var v-udat as char.
def var v-uest as char.

define frame fr skip(1)
       kdaffil.info[1] label "Описание" VIEW-AS EDITOR SIZE 67 by 4 skip
       s-full label "Общ.пл. " format "x(14)"
       s-use label "Пол.пл." format "x(14)"
       s-land label "Зем.уч." format "x(19)" skip
       kdaffil.info[5] format "x(2000)" label "Адрес   " VIEW-AS fill-in SIZE 67 by 1 skip
       v-mest label "Оценка менеджера" format ">>>,>>>,>>>,>>9.99" skip
       
       v-urep format "x(2000)" label "Отчет об оценке" VIEW-AS fill-in SIZE 60 by 1 skip
       v-udat format "x(2000)" label "Данные об оценщике" VIEW-AS fill-in SIZE 57 by 1 skip
       v-uest format "x(2000)" label "Оценка" VIEW-AS fill-in SIZE 69 by 1 skip
       kdaffil.info[8] label "Правоуст.док." VIEW-AS editor SIZE 62 by 4 skip
       kdaffil.info[9] format "x(2000)" label "Рекв.залог-ля" VIEW-AS fill-in SIZE 62 by 1 skip
       
       kdaffil.whn label "ПРОВЕДЕНО " kdaffil.who  no-label skip
       with overlay width 80 side-labels column 1 row 3
       title "ИНФОРМАЦИЯ ОБ ОБЕСПЕЧЕНИИ".


define new shared variable grp as integer init 5.
define var v-cod as char.
/*
on help of kdaffil.name in frame kdaffil22 do:
  run h-kdname.
  displ frame-value. pause.
  kdaffil.affilate = frame-value.
  kdaffil.name = frame-value.
  displ kdaffil.name with frame kdaffil22.
end.
*/
define variable s_rowid as rowid.
define var v-ln as inte init 1.


{jabrw.i 

&start     = " on help of kdaffil.name in frame kdaffil20 do:
run h-kdname. kdaffil.name = return-value. displ kdaffil.name with frame kdaffil20. end. "

&head      = "kdaffil"
&headkey   = "code"
&index     = "cifnomc"
&formname  = "pksysc"
&framename = "kdaffil20"
&where     = " kdaffil.kdcif = s-kdcif and kdaffil.kdlon = s-kdlon and kdaffil.code = '20' "
&addcon    = "(kdlon.bank = s-ourbank)"
&deletecon = "(kdlon.bank = s-ourbank)"
&precreate = " "

&postadd   = " s_rowid = rowid(kdaffil). find last kdaffil where kdaffil.kdcif = s-kdcif and kdaffil.kdlon = s-kdlon and kdaffil.code = '20' no-lock no-error.
if avail kdaffil then v-ln = kdaffil.ln + 1.
find kdaffil where rowid(kdaffil) = s_rowid.
kdaffil.ln = v-ln. kdaffil.bank = s-ourbank. kdaffil.code = '20'. kdaffil.kdcif = s-kdcif.
kdaffil.kdlon = s-kdlon. kdaffil.who = g-ofc. kdaffil.whn = g-today. displ kdaffil.ln with frame kdaffil20.
update kdaffil.lonsec kdaffil.name kdaffil.crc kdaffil.amount kdaffil.info[2] with frame kdaffil20. kdaffil.amount_bank = kdaffil.amount * deci(kdaffil.info[2]).
displ kdaffil.amount_bank with frame kdaffil20. pause 0.
s-full = entry(1,kdaffil.info[4],'^'). if num-entries(kdaffil.info[4],'^') > 2 then do: s-use = entry(2,kdaffil.info[4],'^'). s-land = entry(3,kdaffil.info[4],'^'). end.
if kdaffil.info[6] <> '' then v-mest = deci(kdaffil.info[6]).
if kdaffil.info[7] <> '' then do: v-urep = entry(1,kdaffil.info[7],'^'). if num-entries(kdaffil.info[7],'^') > 2 then do: v-udat = entry(2,kdaffil.info[7],'^'). v-uest = entry(3,kdaffil.info[7],'^'). end. end.
displ kdaffil.info[1] s-full s-use s-land kdaffil.info[5] v-mest v-urep v-udat v-uest kdaffil.info[8] kdaffil.info[9] kdaffil.whn kdaffil.who with frame fr.
update kdaffil.info[1] s-full s-use s-land kdaffil.info[5] v-mest v-urep v-udat v-uest kdaffil.info[8] kdaffil.info[9] with frame fr.
if trim(s-full) = '' then s-full = '0'. if trim(s-use) = '' then s-use = '0'. if trim(s-land) = '' then s-land = '0'.
kdaffil.info[4] = s-full + '^' + s-use + '^' + s-land. kdaffil.info[6] = trim(string(v-mest,'>>>,>>>,>>>,>>9.99')).
kdaffil.info[7] = trim(v-urep) + '^' + trim(v-udat) + '^' + trim(v-uest)."

&prechoose = " message 'F4-Выход,INS-Вставка'."
&postdisplay = " "
&display   = " kdaffil.ln kdaffil.lonsec kdaffil.name kdaffil.crc kdaffil.amount kdaffil.info[2] kdaffil.amount_bank "
&highlight = " kdaffil.ln kdaffil.lonsec "

&postkey   = "else
if keyfunction(lastkey) = 'RETURN'
then do transaction on endkey undo, leave:
 if kdlon.bank = s-ourbank then do:
  update kdaffil.lonsec kdaffil.name kdaffil.crc kdaffil.amount kdaffil.info[2] with frame kdaffil20.
  kdaffil.amount_bank = kdaffil.amount * deci(kdaffil.info[2]).
  displ kdaffil.amount_bank with frame kdaffil20. pause 0.
 end.
 s-full = entry(1,kdaffil.info[4],'^'). if num-entries(kdaffil.info[4],'^') > 2 then do: s-use = entry(2,kdaffil.info[4],'^'). s-land = entry(3,kdaffil.info[4],'^'). end.
 if kdaffil.info[6] <> '' then v-mest = deci(kdaffil.info[6]).
 if kdaffil.info[7] <> '' then do: v-urep = entry(1,kdaffil.info[7],'^'). if num-entries(kdaffil.info[7],'^') > 2 then do: v-udat = entry(2,kdaffil.info[7],'^'). v-uest = entry(3,kdaffil.info[7],'^'). end. end.
 displ kdaffil.info[1] s-full s-use s-land kdaffil.info[5] v-mest v-urep v-udat v-uest kdaffil.info[8] kdaffil.info[9] kdaffil.whn kdaffil.who with frame fr.
 if kdlon.bank = s-ourbank then do:
  update kdaffil.info[1] s-full s-use s-land kdaffil.info[5] v-mest v-urep v-udat v-uest kdaffil.info[8] kdaffil.info[9] with frame fr.
  if trim(s-full) = '' then s-full = '0'. if trim(s-use) = '' then s-use = '0'. if trim(s-land) = '' then s-land = '0'.
  kdaffil.info[4] = s-full + '^' + s-use + '^' + s-land. kdaffil.info[6] = trim(string(v-mest,'>>>,>>>,>>>,>>9.99')).
  kdaffil.info[7] = trim(v-urep) + '^' + trim(v-udat) + '^' + trim(v-uest).
  kdaffil.who = g-ofc. kdaffil.whn = g-today.
 end.
 else pause.
 hide frame fr no-pause.
end. "
&end = "hide frame kdaffil20. hide frame fr."
}
hide message.
