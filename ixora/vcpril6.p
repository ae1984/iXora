/* vcpril6.p
 * MODULE
        Валютный контроль 
 * DESCRIPTION
        Приложение 6 - уведомление о просроченной лицензии
 * RUN
        
 * CALLER
        vcpril6p.p, vcpril6a.p, vcpril6k.p
 * SCRIPT
        
 * INHERIT
        vcpril6dat.p, vcpril6out.p
 * MENU
        15-4-1-9, 15-4-2-11, 15-4-3-7
 * AUTHOR
        29.09.2003 nadejda
 * CHANGES
        08.01.2004 nadejda - убраны старые закомментированные куски
	30.08.06 U00121 добавил -H,-S в параметры конекта в связи с распределнием баз по разным серверам
*/


{vc.i}
{global.i}
{comm-txb.i}

def input parameter p-option as char.
def input parameter p-bank as char.
def input parameter p-depart as integer.

def new shared var s-vcourbank as char.
def new shared var v-dtrep as date.
def new shared var v-period as integer.
def new shared var v-sumzero as logical init no.

def var v-name as char no-undo.
def var v-depname as char no-undo.
def var i as integer no-undo.
def var v-ncrccod like ncrc.code no-undo.
def var v-sum like vcdocs.sum no-undo.
def var v-weekbeg as int no-undo.
def var v-weekend as int no-undo.


def new shared temp-table t-contrs
  field contract like vccontrs.contract
  field ctnum as char
  field ctdate as date
  field expimp as char
  field partner as char
  field partnname as char
  field partnaddr as char
  field licid like vcrslc.rslc
  field licnum as char
  field licdt as date
  field liclastdt as date
  field licsum as decimal
  field liccrc as char
  field cif like bank.cif.cif
  field cifname as char
  field okpo as char
  field rnn as char
  field addr as char
  index main is primary unique cifname cif ctdate ctnum contract licdt licnum licid.

def new shared temp-table t-docs
  field licid like vcrslc.rslc
  field ln as integer
  field data20 as date
  field sum20 as deci
  field crc20 as char
  field data30 as date
  field sum30 as deci
  field crc30 as char
  index ln is primary unique licid ln.

s-vcourbank = comm-txb().

v-dtrep = g-today.

find sysc where sysc.sysc = "WKEND" no-lock no-error.
if available sysc then v-weekend = sysc.inval. else v-weekend = 6.
find sysc where sysc.sysc = "WKSTRT" no-lock no-error.
if available sysc then v-weekbeg = sysc.inval. else v-weekbeg = 2.

if weekday(g-today) = v-weekbeg then v-period = 7 - v-weekend + 1.
                                else v-period = 1.

update skip(1) 
   v-dtrep   label "                  Отчетная дата " 
     validate (v-dtrep <= g-today, " Дата отчета не может быть позже текущей!") 
     "  " skip 
   v-period  label " Период просрочки лицензий (дни)" format ">>9"
     validate (v-period > 0, " Период не может быть меньше 1 дня!") 
     help " Поиск просроченных лицензий от даты отчета назад" skip
   v-sumzero label "  Лицензии с суммой =0 показать?" format "да/нет" skip(1)
   with side-label centered row 5 title " ВВЕДИТЕ ДАТУ ОТЧЕТА : ".

message "  Формируется отчет...".

if p-bank = "all" then p-depart = 0.

{get-dep.i}
if p-depart <> 0 then do:
  p-depart = get-dep(g-ofc, g-today).
  find ppoint where ppoint.depart = p-depart no-lock no-error.
  v-depname = ppoint.name.
end.
v-name = "".

/* коннект к нужному банку */
if connected ("txb") then disconnect "txb".
for each txb where txb.consolid = true and (p-bank = "all" or (txb.bank = s-vcourbank)) no-lock:
  connect value(" -db " + txb.path + " -H " + comm.txb.host + " -S " + comm.txb.service + " -ld txb -U " + txb.login + " -P " + txb.password). 
  run vcpril6dat (txb.bank, p-depart).
  if p-bank <> "all" then v-name = txb.name.
  disconnect "txb".
end.

hide message no-pause.

/*message s-vcourbank. pause 300.*/

if p-option = "rep" then
  run vcpril6out ((p-bank <> "all"), v-name, (p-depart <> 0), v-depname, true).

hide all no-pause.

pause 0.


