/* kzn_lg.p
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
        30/06/04 dpuchkov
 * BASES
        BANK COMM
 * CHANGES
        29/07/04 перекомпиляция
        19.04.2011 aigul - вывод только согласованных курсов
        25.04.2012 aigul - сделала строгий выбор суммы для льготных курсов
        26.04.2012 aigul - recompile
        27.04.2012 aigul - добавила BASES
*/


{yes-no.i}
{get-dep.i}
{global.i}

def input parameter l-lockcurs as logical.
def input parameter l-dbt as logical.
def input parameter l-sum as deci.
def input parameter l-typ as char.
def input parameter l-crc as int.

def var v-crc as char.
def var v-depindex as integer.

def shared var v-crclgt as decimal.
def shared var v-dateb as date.
def shared var v-lgcurs as logical.

DEFINE QUERY q1 FOR crclg.

define buffer buf for crclg .

find first crc where crc.crc = l-crc no-lock no-error.
if avail crc then v-crc = crc.code.
if l-crc = 4 then  v-crc = "RUR".
def browse b1
     query q1
     displ
/*
     crclg.crcpok label "Курс"
     crclg.crcpr label "Вал."  format '99'
     crclg.name label "Клиент" format 'x(12)'
     crclg.sum label "Сумма."
*/
   crclg.crcpok label "Курс пок."
   crclg.crcprod label "Курс прод."
   crclg.crcpr label "Валюта" format '99'
   crclg.name label "Клиент" format 'x(12)'
   crclg.sum label "Сумма." format "zzz,zzz,zzz,zzz.99"



     with 9 down title "Выберите льготный курс обмена." overlay.

DEFINE BUTTON bacc LABEL "Выход".

def frame fr1
     b1 help "ENTER - выбор льготного курса"
     skip
     bacc with centered overlay row 5 top-only.

ON CHOOSE OF bacc IN FRAME fr1
do:
   APPLY "WINDOW-CLOSE" TO BROWSE b1.
end.

on return of b1 in frame fr1 do:
   if l-dbt then
     v-crclgt = crclg.crcprod.
   else
     v-crclgt = crclg.crcpok.



   v-dateb = crclg.dateb.
   v-lgcurs = True.
   find buf where rowid (crclg) = rowid (buf) exclusive-lock.
   if l-lockcurs then
     crclg.lock = True.



   APPLY "WINDOW-CLOSE" TO BROWSE b1.
end.


v-depindex = get-dep(g-ofc, g-today).

if l-typ = "D" then
open query q1 for each crclg where crclg.dep = v-depindex and crclg.lock = False and crclg.sts = "V" and crclg.sum = l-sum and crclg.crcpok <> 0
and crclg.crctxt = v-crc.
if l-typ = "C" then
open query q1 for each crclg where crclg.dep = v-depindex and crclg.lock = False and crclg.sts = "V" and crclg.sum = l-sum and crclg.crcprod <> 0
and crclg.crctxt = v-crc.
if num-results("q1") = 0 then
do:

   MESSAGE "Внимание льготный курс не найден. " VIEW-AS ALERT-BOX INFORMATION BUTTONS ok TITLE "".
   return.
end.

b1:SET-REPOSITIONED-ROW (1, "CONDITIONAL").

ENABLE all with frame fr1 centered overlay top-only.

apply "value-changed" to b1 in frame fr1.

WAIT-FOR WINDOW-CLOSE of frame fr1.


hide frame fr1.



