/* hisfcb.p
 * MODULE
        История выгрузки батчей в ПКБ
 * DESCRIPTION
        Описание
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        05/04/2011 evseev
 * BASES
        BANK COMM
 * CHANGES
*/

{global.i}

def var v-countdt as integer.
def var i as integer.

def temp-table hisdt
 field num as integer
 field dt as date.

DEFINE QUERY q-hisdt FOR hisdt.

DEFINE BROWSE b-hisdt QUERY q-hisdt DISPLAY num label '№' format '>>>9' dt label 'Дата' WITH 25 DOWN SEPARATORS.
DEFINE BUTTON bexit label 'Выход'.
DEFINE BUTTON badd label 'Добавить'.
DEFINE BUTTON bedt label 'Изменить'.
DEFINE BUTTON bdel label 'Удалить'.

DEFINE FRAME f-hisdt
    b-hisdt SKIP(1)
    bexit badd bedt bdel
    WITH 1 COLUMN SIDE-LABELS COLUMN 10 /*NO-BOX*/.

def var v-chose as logi init yes.
def var v-dt as date label 'Дата'.
DEFINE FRAME f-dt.

form
    v-dt label "Дата          "
with centered side-label row 7 width 40 overlay  title 'Введите дату' frame f-dt.


for each hisdt exclusive-lock:
   delete hisdt.
end.

find first pksysc where pksysc.sysc = '1cb' exclusive-lock no-error.
if not avail pksysc then return.
if pksysc.chval = '' then pksysc.chval = string(pksysc.daval).
v-countdt = 0.
v-countdt = num-entries(pksysc.chval).

if v-countdt <> 0 then do:
  do i = 1 to v-countdt:
    create hisdt.
      hisdt.num = i.
      hisdt.dt = date(entry(i, pksysc.chval)).
  end.
end.

OPEN QUERY q-hisdt FOR EACH hisdt.

ON CHOOSE OF badd
DO:
  update v-dt with frame f-dt.
  create hisdt.
      hisdt.num = v-countdt + 1.
      hisdt.dt = v-dt.
  v-countdt = v-countdt + 1.
  OPEN QUERY q-hisdt FOR EACH hisdt.
  HIDE FRAME f-dt.
END.

ON CHOOSE OF bedt
DO:
  v-dt = hisdt.dt.
  update v-dt with frame f-dt.
  hisdt.dt = v-dt.
  OPEN QUERY q-hisdt FOR EACH hisdt.
  HIDE FRAME f-dt.
END.

ON CHOOSE OF bdel
DO:
   delete hisdt.
   find last hisdt no-error.
   if avail hisdt then
      v-countdt = hisdt.num.
   else
      v-countdt = 0.
   OPEN QUERY q-hisdt FOR EACH hisdt.
END.





ENABLE ALL WITH FRAME f-hisdt.
WAIT-FOR CHOOSE OF bexit.

message 'Сохранить изменения?' VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE " ВНИМАНИЕ !"
update v-chose.

if v-chose then do:
  pksysc.chval = ''.
  if v-countdt > 0 then do:
      for each hisdt:
         pksysc.chval = pksysc.chval + string (hisdt.dt).
         if v-countdt <> hisdt.num then pksysc.chval = pksysc.chval + ','.
      end.
      find last hisdt.
      pksysc.daval = hisdt.dt.
  end.
  else do:
     pksysc.chval = ''.
    /* pksysc.daval = 01/01/99.*/
  end.
end.