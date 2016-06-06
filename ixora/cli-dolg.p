/* cli-dolg.p
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
        01.09.2004 dpuchkov - добавил ограничение на просмотр задолженности по счету клиента.
        08.09.2004 dpuchkov - запись удачных попыток доступа.
        27.01.10 marinav - расширение поля счета до 20 знаков
        25.10.11 lyubov - убрала выборку по счету, сделала выборку по cif-коду и отчет об общей сумме задолженностей
        24/05/2013 Luiza - ТЗ 1719 поиск клиента по ИИН/БИН
*/

/*Задолженность клиента по счету
25.12.01  п.п.8-12-8*/


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

def var exist as log initial false.
def new shared var fdt like bxcif.whn.

def var sch like aaa.aaa.
def var v-cif like cif.cif.
def var v-sel as int.

def new shared temp-table tbxc no-undo
    field crc  like crc.crc label ""
    field aaa  like bxcif.aaa label ""
    field code  like crc.code label ""
    field amount like bxcif.amount label ""
    field rem like bxcif.rem label ""
    field whn like bxcif.whn label ""
    index aaa is primary aaa crc.

    def var sum as deci FORMAT '->>,>>>,>>>,>>9.99' label "Задолженность KZT".
    def var sum1 as deci FORMAT '->>,>>>,>>>,>>9.99' label "Задолженность USD".
    def var sum2 as deci FORMAT '->>,>>>,>>>,>>9.99' label "Задолженность USD в тенге".

{global.i }

message " No - Отчет об общей сумме задолженностей по всем клиентам филиала ".
message " Вывести отчет по клиенту ? " view-as alert-box QUESTION BUTTONS YES-NO UPDATE b AS LOGICAL.
if b = true then do:
hide message.

/*run sel2 ("Выбор :", " Отчет по клиенту | 2.Отчет об общей сумме задолженностей по всем клиентам филиала ", output v-sel).

if v-sel = 1 then do:*/

find first cmp no-lock no-error.

if not g-batch then update v-cif label ' Введите cif-код клиента ' with side-label row 5 centered frame dat .

find cif where cif.cif = v-cif  no-lock no-error.

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

display '   Ждите...   '  with row 5 frame ww centered .
put stream nur skip
string( today, '99/99/9999' ) + ', ' +
string( time, 'HH:MM:SS' ) + ', ' +
trim( cmp.name ) format 'x(79)' at 02 skip(1).

find cif where cif.cif = v-cif  no-lock no-error.
find aaa where aaa.cif = cif.cif no-lock no-error.
if avail aaa then sch = aaa.aaa.
else sch = ''.

if not available cif then do:
 message "Нет клиента " v-cif VIEW-AS ALERT-BOX.
 return.
end.
put stream nur skip
" ОТЧЕТ О ЗАДОЛЖЕННОСТИ КЛИЕНТА ПО СЧЕТУ" SKIP(2)
"Клиент " cif.cif " " trim(trim(cif.prefix) + " " + trim(cif.name)) format 'x(60)' skip
"Счет "  sch skip.

put stream nur ' ' fill( '-', 817 ) format 'x(82)'.

exist = false.
for each bxcif where bxcif.cif = cif.cif break by crc.
    accum bxcif.amount (total by bxcif.crc).
    find crc where bxcif.crc = crc.crc no-lock no-error.
    put stream nur  crc.code format 'x(3)' at 2 amount format '->>>>9.99' at 5
    rem format 'x(80)' at 15 skip.
    if last-of(bxcif.crc) then put stream nur 'ИТОГО: ' format "x(5)" at 5
    crc.code format 'x(3)' at 12
    accum total by bxcif.crc bxcif.amount format ">>>>>>>>>9.99" at 15 skip(2) .
    exist = true.
end.

    if not exist then  do:
    message 'У клиента нет долгов!' VIEW-AS ALERT-BOX.
    return.
    end.

output stream nur close.
end.

if b = false then do:
/*if v-sel = 2 then do:*/

    update fdt label " Дата отчета"  help " Задайте дату отчета" skip
    with row 8 centered  side-label frame opt title "Отчет по задолженностям ".
    hide frame  opt.

    find first cmp no-lock no-error.

    display '   Ждите...   '  with row 5 frame ww centered .
    put stream nur skip
    string( today, '99/99/9999' ) + ', ' +
    string( time, 'HH:MM:SS' ) + ', ' +
    trim( cmp.name ) format 'x(79)' at 02 skip(1).

    put stream nur skip
    " ОТЧЕТ О ЗАДОЛЖЕННОСТИ КЛИЕНТА ПО СЧЕТУ" SKIP(2).

    for each bxcif where bxcif.whn <= fdt and bxcif.amount <> 0 no-lock break by aaa by crc by rem:

       find crc where  bxcif.crc = crc.crc no-lock no-error.

            create tbxc.
            tbxc.crc = crc.crc.
            tbxc.code = crc.code.
            tbxc.amount = bxcif.amount.
            tbxc.rem = bxcif.rem.
            tbxc.whn = bxcif.whn.

            find aaa where aaa.aaa = bxcif.aaa no-lock no-error.
            if avail aaa then
                find cif where cif.cif = aaa.cif  no-lock no-error.
                if avail cif then do:
                    tbxc.aaa = aaa.aaa.

                    if first-of (bxcif.aaa) then
                        put stream nur skip
                        ' ' fill( '-', 817 ) format 'x(77)'
                        "Клиент " cif.cif " " trim(trim(cif.prefix) + " " + trim(cif.name)) format 'x(60)' skip
                        "Счет "  aaa.aaa skip
                        ' ' fill( '-', 817 ) format 'x(77)'.
                        accum bxcif.amount (total by bxcif.crc).

                        for each tbxc where tbxc.aaa = aaa.aaa and tbxc.whn <= fdt break by tbxc.crc by tbxc.aaa by tbxc.rem.
                            find crc where tbxc.crc = crc.crc no-lock no-error.

                            if last-of (tbxc.crc) then
                                /*if tbxc.amount <> 0 then*/
                                    put stream nur  crc.code format 'x(3)' at 2 tbxc.amount format '->>>>9.99' at 5
                                               tbxc.rem  at 15 skip.
                        end.

                        if last-of(bxcif.crc) then
                        put stream nur 'ИТОГО: ' format "x(5)" at 5
                                   crc.code format 'x(3)' at 12
                                   accum total by bxcif.crc bxcif.amount format ">>>>>>>>>9.99" at 15 skip(2).
                end.
    end.

    for each bxcif where bxcif.whn <= fdt no-lock:
        find first crc where crc.crc = 2 no-lock no-error.
            if bxcif.crc = 1 then sum = sum + bxcif.amount.
            if bxcif.crc = 2 then sum1 = sum1 + bxcif.amount.
            sum2 = sum1 * crc.rate[1].
    end.

    put stream nur skip
            sum  at 5
        " Задолженность KZT " SKIP
            sum1  at 5
        " Задолженность USD " SKIP
            sum2  at 5
        " Задолженность USD в тенге " SKIP.

    output stream nur close.

message " Вывести отчет в Excel ? " view-as alert-box QUESTION BUTTONS YES-NO UPDATE bb AS LOGICAL.
if bb = true then run excq.
end.

if not g-batch then do:
   pause 0 before-hide.
   run menu-prt( 'rpt.img' ).
   pause 0 no-message.
   pause before-hide.
end.