/* cli-dolg2.p
 * MODULE
        Название модуля
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
        22.06.2011 ruslan
 * BASES
        BANK COMM
 * CHANGES
        15.08.2011 ruslan - для cif-aaa
*/

def stream  nur.
def var flg as log init false.
def var v-dt1 as date /*init 10/09/01*/ .
def var v-dt2 as date /* init 10/09/01 */.
def var v-amt as decimal FORMAT '->>,>>>,>>>,>>9.99' init 500000 .
def var v-tot as deci init 0.
def var temp-acc as char  format 'x(9)' init "".
def var temp-rnn as char  format 'x(15)' init "".
def var v-acc like aaa.aaa.  /*MFO*/
def var v-bn as char init ''.      /*RNN*/
def var v-bn1 as char init ''.    /*client's name*/
def var i as int.
def var v-sub as int.
def var temp-total like v-tot.

def var v-type like remtrz.ptype.

def var count1 as  integer init 1.
output stream  nur to rpt.img .

DEFINE SHARED VAR s-aaa LIKE aas_hist.aaa.

def var exist as log initial false.

def temp-table temp  /*workfile*/
    field cif like  bxcif.cif
    field aaa  like bxcif.aaa
    field crc  like bxcif.crc
    field amount like bxcif.amount
    field rem like bxcif.rem.

{global.i }

find first cmp no-lock no-error.
if not g-batch then v-acc = s-aaa.
/*validate(available aaa  , "Такого счета нет") with side-label row 5 centered frame dat .*/

/*update  val label ' бБЕДХРЕ ВХЯКН' format 'zzzz99.99'
 validate(ge 0.0001  , вХЯКН ДНКФМН АШРЭ АНКЭЬЕ МСК")
                   skip with side-label row 5 centered frame dat .
  */


find aaa where aaa.aaa = v-acc no-lock no-error.
if avail aaa then
do:
   find cif where cif.cif = aaa.cif  no-lock no-error.

   find last cifsec where cifsec.cif = cif.cif no-lock no-error.
   if avail cifsec then
   do:
     find last cifsec where cifsec.cif = cif.cif and cifsec.ofc = g-ofc no-lock no-error.
     if not avail cifsec then
     do:
        create ciflog.
        assign
          ciflog.ofc = g-ofc
          ciflog.jdt = today
          ciflog.cif = cif.cif
          ciflog.sectime = time
          ciflog.menu = "1.6.10 Задолженность по счету".
          message "Клиент не Вашего Департамента." view-as alert-box buttons OK .
          return.
     end.
     else
     do:
          create ciflogu.
          assign
            ciflogu.ofc = g-ofc
            ciflogu.jdt = today
            ciflogu.sectime = time
            ciflogu.cif = cif.cif
            ciflogu.menu = "1.6.10 Задолженность по счету" .
     end.

   end.

end.




display '   Ждите...   '  with row 5 frame ww centered .
put stream nur skip
string( today, '99/99/9999' ) + ', ' +
string( time, 'HH:MM:SS' ) + ', ' +
trim( cmp.name ) format 'x(79)' at 02 skip(1).

find aaa where aaa.aaa = v-acc no-lock no-error.
find cif where cif.cif = aaa.cif  no-lock no-error.

if not available aaa then do:
 message "Нет клиента со счетом " v-acc VIEW-AS ALERT-BOX.
 return.
end.
put stream nur skip
" ОТЧЕТ О ЗАДОЛЖЕННОСТИ КЛИЕНТА ПО СЧЕТУ" SKIP(2)
"Клиент " cif.cif " " trim(trim(cif.prefix) + " " + trim(cif.name)) format 'x(60)' skip
"Счет "  aaa.aaa skip.

put stream nur ' ' fill( '-', 817 ) format 'x(77)'.

exist = false.
for each bxcif where bxcif.cif = cif.cif and bxcif.aaa = aaa.aaa break by crc.
    accum bxcif.amount (total by bxcif.crc).
    find crc where bxcif.crc = crc.crc no-lock no-error.
    put stream nur  crc.code format 'x(3)' at 2 amount format '->>>>9.99' at 5
    rem  at 15 skip.
    if last-of(bxcif.crc) then put stream nur 'ИТОГО: ' format "x(5)" at 5
    crc.code format 'x(3)' at 12
    accum total by bxcif.crc bxcif.amount format ">>>>>>>>>9.99" at 15 skip(2) .
    exist = true.
end.

    if not exist then  do:
    message 'У клиента нет долгов по данному счету!' VIEW-AS ALERT-BOX.
    return.
    end.

    output stream nur close.

if not g-batch then do:
   pause 0 before-hide.
   run menu-prt( 'rpt.img' ).
   pause 0 no-message.
   pause before-hide.
 end.


