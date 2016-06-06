/* vcrep14.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Тело выдачи Приложения 14
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
        14.01.2003 nadejda - вырезан кусок из vcrepk14.p
 * CHANGES
        14.01.2003 nadejda - вырезан кусок из vcrepk14.p
        24.05.2003 nadejda - убраны параметры -H -S из коннекта 
        20.01.2004 nadejda - поиск МРП за месяц отчета для определения минимальной суммы задолженности, которую показываем в отчете
        08.07.2004 saltanat - включен новый передаваемый параметр p-contrtype, а также глоб.переменная v-contrtype.
        04.11.2004 saltanat - убрала shared v-contrtype  
      	30.08.06 U00121 добавил -H,-S в параметры конекта в связи с распределнием баз по разным серверам
*/


{vc.i}
{global.i}
{comm-txb.i}

def input parameter p-option as char.
def input parameter p-bank as char.
def input parameter p-depart as integer.
def input parameter p-contrtype as char.

def new shared var v-god as integer format "9999".
def new shared var v-month as integer format "99".
def new shared var v-dtb as date.
def new shared var v-dte as date.
def new shared var s-vcourbank as char.
def new shared var v-dtcurs as date.
def new shared var v-cursusd as deci.

def var v-name as char.
def var v-depname as char init "".
def var v-i as integer.
def var v-mt104-r as integer.

def new shared temp-table t-docs 
  field kodstr as integer init 0
  field e-all as deci extent 30
  field i-all as deci extent 30.

s-vcourbank = comm-txb().

{vc-defdt.i}

update skip(1) 
   v-month label "     Месяц " skip 
   v-god label   "       Год " skip(1) 
   with side-label centered row 5 title " ВВЕДИТЕ ПЕРИОД ОТЧЕТА : ".

message "  Формируется отчет...".

v-dtb = date(v-month, 1, v-god).

case v-month:
  when 1 or when 3 or when 5 or when 7 or when 8 or when 10 or when 12 then vi = 31.
  when 4 or when 6 or when 9 or when 11 then vi = 30.
  when 2 then do:
    if v-god mod 4 = 0 then vi = 29.
    else vi = 28.
  end.
end case.
v-dte = date(v-month, vi, v-god).


/* найти курс USD на отчетную дату */
v-dtcurs = v-dte + 1.
find last ncrchis where ncrchis.crc = 2 and ncrchis.rdt <= v-dtcurs no-lock no-error. 
v-cursusd = ncrchis.rate[1].

if p-bank = "all" then p-depart = 0.

{get-dep.i}
if p-depart <> 0 then do:
  p-depart = get-dep(g-ofc, g-today).
  find ppoint where ppoint.depart = p-depart no-lock no-error.
  v-depname = ppoint.name.
end.
v-name = "".

do v-i = 1 to 14:
  create t-docs.
  t-docs.kodstr = v-i.
end.

/* не учитываемая сумма задолженности = 20 МРП, МРП на отчетный месяц из зарплатного модуля */
def new shared var v-sumlimit as decimal init 1.
def var v-mrp as decimal.

if not connected ("alga") then 
do:
/*
  find sysc where sysc.sysc = "rkbdir" no-lock no-error.
  if not avail sysc then do:
    message "Не найден системный параметр rkbdir!". 
    pause.
    return.
  end.
  connect value("-db " + trim(sysc.chval) + "alga/alga.db -ld alga ").
*/
  find last cmp no-lock no-error.
  if avail cmp then
  do:
	  find last comm.txb where comm.txb.city = 998 and comm.txb.txb = cmp.code no-lock no-error.
	  if avail comm.txb then
	  do:
	  	connect value(" -db " + comm.txb.path + " -H " + comm.txb.host + " -S " + comm.txb.service + " -ld alga").	
	  end.
	  else
	  do:
	  	message "Отсутсвуют параметры зарплатной базы"  skip 
	  		"для " cmp.name skip
	  		"Дальнейшая работа не возможна!" view-as alert-box.
	  	return.
	  end.
  end.
  else
  do:
  	message "Отсутствует настройка банковского профайла!" skip 
  		"Дальнейшая работа не возможна!" view-as alert-box.
  	return.
  end.
end.

run mrpfind (v-month, v-god, output v-mrp).
if connected ("alga") then disconnect "alga".

v-sumlimit = 20 * v-mrp.



/* коннект к нужному банку */
if connected ("txb") then disconnect "txb".
for each txb where txb.consolid = true and (p-bank = "all" or (txb.bank = s-vcourbank)) no-lock:
  connect value(" -db " + txb.path + " -H " + comm.txb.host + " -S " + comm.txb.service + " -ld txb -U " + txb.login + " -P " + txb.password). 
  run vcrep14dat (txb.bank, p-depart, p-contrtype).
  if p-bank <> "all" then v-name = txb.name.
  disconnect "txb".
end.

find vcparams where vcparams.parcode = "mt104-r" no-lock no-error.
if not avail vcparams then do:
  message skip " Не найден параметр mt104-r !"
          skip(1) view-as alert-box button ok title " ОШИБКА ! ".
  return.
end.
v-mt104-r = vcparams.valinte.

/* собрать данные по валютам */
def new shared temp-table t-rep14
  field kodstr as integer
  field expsum as deci
  field expsumkzt as deci
  field impsum as deci
  field impsumkzt as deci
  index kodstr is primary unique kodstr.

for each t-docs no-lock:
  create t-rep14.
  t-rep14.kodstr = t-docs.kodstr.
  
if t-docs.kodstr < 3 then do: 
  t-rep14.expsumkzt = t-docs.e-all[1].
  t-rep14.impsumkzt = t-docs.i-all[1].

  t-rep14.expsum = t-docs.e-all[2].
  t-rep14.impsum = t-docs.i-all[2].
end.
else do:
  t-rep14.expsumkzt = t-docs.e-all[1] / v-cursusd.
  t-rep14.impsumkzt = t-docs.i-all[1] / v-cursusd.

  t-rep14.expsum = t-rep14.expsumkzt + t-docs.e-all[2].
  t-rep14.impsum = t-rep14.impsumkzt + t-docs.i-all[2].
end.

  for each ncrc where ncrc.crc > 2 no-lock :
    find last ncrchis where ncrchis.crc = ncrc.crc and ncrchis.rdt <= v-dtcurs no-lock no-error. 

    if t-docs.e-all[ncrc.crc] <> 0 then 
      t-rep14.expsum = t-rep14.expsum + t-docs.e-all[ncrc.crc] * ncrchis.rate[1] / v-cursusd.

    if t-docs.i-all[ncrc.crc] <> 0 then 
      t-rep14.impsum = t-rep14.impsum + t-docs.i-all[ncrc.crc] * ncrchis.rate[1] / v-cursusd.
  end.

  if t-docs.kodstr > 1 then do:
    t-rep14.expsum    = round(t-rep14.expsum / v-mt104-r, 2).
    t-rep14.expsumkzt = round(t-rep14.expsumkzt / v-mt104-r, 2).
    t-rep14.impsum    = round(t-rep14.impsum / v-mt104-r, 2).
    t-rep14.impsumkzt = round(t-rep14.impsumkzt / v-mt104-r, 2).
  end.
end.


def buffer buft-rep14 for t-rep14.

/* строка 8 = 9 + 10 */
find t-rep14 where t-rep14.kodstr = 8.

find buft-rep14 where buft-rep14.kodstr = 9 no-lock.
t-rep14.expsum    = t-rep14.expsum    + buft-rep14.expsum.
t-rep14.impsum    = t-rep14.impsum    + buft-rep14.impsum.
t-rep14.expsumkzt = t-rep14.expsumkzt + buft-rep14.expsumkzt.
t-rep14.impsumkzt = t-rep14.impsumkzt + buft-rep14.impsumkzt.

find buft-rep14 where buft-rep14.kodstr = 10 no-lock.
t-rep14.expsum    = t-rep14.expsum    + buft-rep14.expsum.
t-rep14.impsum    = t-rep14.impsum    + buft-rep14.impsum.
t-rep14.expsumkzt = t-rep14.expsumkzt + buft-rep14.expsumkzt.
t-rep14.impsumkzt = t-rep14.impsumkzt + buft-rep14.impsumkzt.

/* строка 5 = 6 + 8 + 12 - 11 */
find t-rep14 where t-rep14.kodstr = 5.

find buft-rep14 where buft-rep14.kodstr = 6 no-lock.
t-rep14.expsum    = t-rep14.expsum    + buft-rep14.expsum.
t-rep14.impsum    = t-rep14.impsum    + buft-rep14.impsum.
t-rep14.expsumkzt = t-rep14.expsumkzt + buft-rep14.expsumkzt.
t-rep14.impsumkzt = t-rep14.impsumkzt + buft-rep14.impsumkzt.

find buft-rep14 where buft-rep14.kodstr = 8 no-lock.
t-rep14.expsum    = t-rep14.expsum    + buft-rep14.expsum.
t-rep14.impsum    = t-rep14.impsum    + buft-rep14.impsum.
t-rep14.expsumkzt = t-rep14.expsumkzt + buft-rep14.expsumkzt.
t-rep14.impsumkzt = t-rep14.impsumkzt + buft-rep14.impsumkzt.

find buft-rep14 where buft-rep14.kodstr = 12 no-lock.
t-rep14.expsum    = t-rep14.expsum    + buft-rep14.expsum.
t-rep14.impsum    = t-rep14.impsum    + buft-rep14.impsum.
t-rep14.expsumkzt = t-rep14.expsumkzt + buft-rep14.expsumkzt.
t-rep14.impsumkzt = t-rep14.impsumkzt + buft-rep14.impsumkzt.

find buft-rep14 where buft-rep14.kodstr = 11 no-lock.
t-rep14.expsum    = t-rep14.expsum    - buft-rep14.expsum.
t-rep14.impsum    = t-rep14.impsum    - buft-rep14.impsum.
t-rep14.expsumkzt = t-rep14.expsumkzt - buft-rep14.expsumkzt.
t-rep14.impsumkzt = t-rep14.impsumkzt - buft-rep14.impsumkzt.



if p-option = "rep" then
  run vcrep14out ("vcrep14.htm", (p-bank <> "all"), v-name, (p-depart <> 0), v-depname, p-contrtype).
else
  run vcrep14msg.

pause 0.



