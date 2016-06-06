/* vcrep14dat.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
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
 * AUTHOR
        31/12/99 pragma
 * CHANGES
         06.07.2004 saltanat - добавлена глоб. переменная v-contrtype для вызова процедуры: vcrepdexdat.p
                                                                                            vcrep14dat.p, vcrepdimdat.p...
         04.11.2004 saltanat - вместо shared v-contrtype сделала input parameter p-contrtype
         17.01.2005 saltanat - включена передаваемая переменная p-contrvid для проц. vcreppsdat, определяющая нужный вид контракта(активный или закрытый)
*/

/* vcrep14dat.p - Валютный контроль
   Приложение 14
   Сборка во временную таблицу по одному департаменту/банку

   04.11.2002 nadejda создан
   31.07.2003 nadejda - в обработку задолженности добавлено поле sumdolg и берется просроченная сумма по нему
   29/11/2010 aigul - добавление полей cif, bank, ppname, ctype для талицы t-docsa
   29/11/2010 aigul - удаление полей cif, bank, ppname, ctype из талицы t-docsa
*/

{vc.i}

def input parameter p-vcbank as char.
def input parameter p-depart as integer.

def shared var v-god as integer format "9999".
def shared var v-month as integer format "99".
def shared var v-dtb as date.
def shared var v-dte as date.
def shared var v-dtcurs as date.

def new shared var v-reptype as char init "A".

def var v-name as char.
def var v-rnn as char.
def var v-partner as char.
def var v-sum as deci.
def var v-sumdoc as deci.
def var v-sumavans as deci.
def var v-sumpost as deci.
def var v-sumgtd as deci.
def var v-sumplat as deci.
def var s-vcdoctypes as char.
def var v-days as integer.
def var i as integer.
def var v-dtb1 as date.
def var v-dte1 as date.

def shared temp-table t-docs
  field kodstr as integer init 0
  field e-all as deci extent 30
  field i-all as deci extent 30.

def temp-table t-contrs
  field contract like vccontrs.contract
  field ei like vccontrs.expimp
  field ps like vcps.ps
  field dntype like vcps.dntype
  field dndate as date
  field ncrc as integer
  field sum as deci
  index ps is primary ps.

def new shared temp-table t-docsa
  field docs like vcdocs.docs
  field dndate like vcdocs.dndate
  field pcrc like vcdocs.pcrc
  field crckod as char
  field sum like vcdocs.sum
  field sumret like vcdocs.sum
  field knp as char
  field kod14 as char
  field kod14a as char
  field p14sum6 as deci init 0.00
  field p14sum7 as deci init 0.00
  field p14sum9 as deci init 0.00
  field p14sum10 as deci init 0.00
  field p14sum11 as deci init 0.00
  field p14sum12 as deci init 0.00
  field p14sum13 as deci init 0.00
  field info as char
  field cifname as char
  field depart as integer
  field rnn as char
  field contrnum as char
  field cttype as char
  field ctei as char
  field psnum as char
  field partname as char.

def new shared temp-table t-psa
  field ps like vcps.ps
  field dntype like vcps.dntype
  field dndate like vcps.dndate
  field psnum as char
  field crc like vcps.ncrc
  field crckod as char
  field sum like vcps.sum
  field sumusd like vcps.sum
  field info as char
  field cifname as char
  field depart as integer
  field rnn as char
  field contrnum as char
  field ctei as char
  field partname as char.

def new shared temp-table t-svodps
  field ei like vccontrs.expimp
  field kolps as integer init 0
  field kolpskzt as integer init 0
  field sumps as deci init 0
  field sumpskzt as deci init 0
  field koldl as integer init 0
  field koldlkzt as integer init 0
  field sumdl as deci init 0
  field sumdlkzt as deci init 0
  index main is primary ei.

def new shared temp-table t-dolgs
  field cif like txb.cif.cif
  field depart as integer
  field cifname as char
  field cifsort as char
  field contract like vccontrs.contract
  field ctdate as date
  field ctnum as char
  field ctei as char
  field ncrc like txb.ncrc.crc
  field sumcon as decimal init 0
  field sumusd as decimal init 0
  field sumdolg as decimal init 0
  field lcnum as char
  field days as integer
  index main is primary cifsort cif ctdate ctnum contract.

def buffer b-docs for vcdocs.

/* строки 1, 2 */

run vcreppsdat (p-vcbank, p-depart, yes, '1,5','V').

for each t-svodps :
  run str14plus(1, t-svodps.ei, 2, t-svodps.kolps).
  run str14plus(2, t-svodps.ei, 2, t-svodps.sumps + t-svodps.sumdl).
  run str14plus(1, t-svodps.ei, 1, t-svodps.kolpskzt).
  run str14plus(2, t-svodps.ei, 1, t-svodps.sumpskzt + t-svodps.sumdlkzt).
end.

/* строки 6, 7, 9, 10, 11, 12, 13  */
run vcreppldat ("A", p-vcbank, p-depart, v-dtb, v-dte, '1,5').

for each t-docsa where t-docsa.cttype = "1":
  run str14plus(6, t-docsa.ctei, t-docsa.pcrc, t-docsa.p14sum6).
  run str14plus(7, t-docsa.ctei, t-docsa.pcrc, t-docsa.p14sum7).
  run str14plus(9, t-docsa.ctei, t-docsa.pcrc, t-docsa.p14sum9).
  run str14plus(10, t-docsa.ctei, t-docsa.pcrc, t-docsa.p14sum10).
  run str14plus(11, t-docsa.ctei, t-docsa.pcrc, t-docsa.p14sum11).
  run str14plus(12, t-docsa.ctei, t-docsa.pcrc, t-docsa.p14sum12).
  run str14plus(13, t-docsa.ctei, t-docsa.pcrc, t-docsa.p14sum13).
end.

/* строки 3, 4, 14 */
/* дата просмотра контрактов */
v-dtb1 = v-dtb.
find vcparams where parcode = "contrs14" no-lock no-error.
if avail vcparams then v-dtb1 = date(vcparams.valchar). else v-dtb1 = 01/01/2000.

/* отчетная дата - не включается */
v-dte1 = v-dte.
if v-month = 12 then v-dte1 = date(1, 1, v-god + 1).
else v-dte1 = date(v-month + 1, 1, v-god).

find vcparams where vcparams.parcode = "dayerror" no-lock no-error.
if avail vcparams then v-days = vcparams.valinte.
else v-days = 120.


/* ЭКСПОРТ */

/* задолженность нерезидента перед резидентом */
for each t-dolgs. delete t-dolgs. end.
run vcrepdexdat (p-vcbank, p-depart, v-dtb1, v-dte1, yes, '1,5').
/* не будем учитывать долги < 1 USD */
for each t-dolgs where t-dolgs.sumusd >= 1 :
  run str14plus(3, "e", 2, t-dolgs.sumusd).

  if t-dolgs.days > v-days then
    run str14plus(14, "e", 2, t-dolgs.sumdolg).
end.

/* задолженность резидента перед нерезидентом */
for each t-dolgs. delete t-dolgs. end.
run vcrepdpldat ("e", p-vcbank, p-depart, v-dtb1, v-dte1, yes, '1,5').
/* не будем учитывать долги < 1 USD */
for each t-dolgs where t-dolgs.sumusd >= 1 :
  run str14plus(4, "e", 2, t-dolgs.sumusd).
end.
/* закончили экспорт */



/* ИМПОРТ */

/* задолженность нерезидента перед резидентом */
for each t-dolgs. delete t-dolgs. end.
run vcrepdimdat (p-vcbank, p-depart, v-dtb1, v-dte1, yes, '1,5').
/* не будем учитывать долги < 1 USD */
for each t-dolgs where t-dolgs.sumusd >= 1 :
  run str14plus(3, "i", 2, t-dolgs.sumusd).
end.

/* задолженность резидента перед нерезидентом */
for each t-dolgs. delete t-dolgs. end.
run vcrepdpldat ("i", p-vcbank, p-depart, v-dtb1, v-dte1, yes, '1,5').
/* не будем учитывать долги < 1 USD */
for each t-dolgs where t-dolgs.sumusd >= 1 :
  run str14plus(4, "i", 2, t-dolgs.sumusd).

  if t-dolgs.days > v-days then
    run str14plus(14, "i", 2, t-dolgs.sumdolg).
end.
/* закончили импорт */


procedure str14plus.
  def input parameter p-numstr as integer.
  def input parameter p-expimp as char.
  def input parameter p-crc like txb.ncrc.crc.
  def input parameter p-sumdoc as deci.

  find t-docs where t-docs.kodstr = p-numstr.
  if p-expimp = "e" then t-docs.e-all[p-crc] = t-docs.e-all[p-crc] + p-sumdoc.
                    else t-docs.i-all[p-crc] = t-docs.i-all[p-crc] + p-sumdoc.
end procedure.

