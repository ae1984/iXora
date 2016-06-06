/* k1.p
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
        01.09.04 dpuchkov - Ограничение доступа на просмотр реквизитов клиента.
        08.09.04 dpuchkov - запись удачных попыток доступа.
*/

/*rptkas.p*/
{global.i}
def temp-table wt
    field sim as char
    field crc like crc.crc
    field dam like jl.dam
    field cam like jl.cam
    field acc like jl.acc.
    /*
    index wt is unique crc sim.
    */

def stream m-out.
def var v-rptfrom as date.
def var v-rptto   as date.
def var v-acc     as char.
def var ii        as int.
def stream s-err .

find last  cls no-lock no-error.
find first cmp no-lock no-error.
find first ofc where ofc.ofc = userid('bank') no-lock no-error.

 v-rptfrom = today.
 v-rptto   = today.
 v-acc     = '017467261'.

update
v-rptfrom label "Дата с "
v-rptto   label " по "
v-acc     label "Счет "
with row 9 side-labels centered.



    find last aaa where aaa.aaa = v-acc no-lock no-error.
    if avail aaa then
    find last cif where cif.cif = aaa.cif no-lock no-error.
    if avail cif then
    do:
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
               ciflog.menu = "2.12 Подсчет кассовых оборотов клиентов".
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
                ciflogu.menu = "2.12 Подсчет кассовых оборотов клиентов" .
           end.

         end.
    end.





output stream s-err to kasplan.err.

for each jl
    where jl.jdt ge v-rptfrom
    and   jl.jdt le v-rptto
    /*
    and   jl.acc =  v-acc
    */
    no-lock:
    find first jlsach where jlsach.jh eq jl.jh and jlsach.ln eq jl.ln no-lock
    no-error.
    if not available jlsach then do:
        if jl.gl eq 100100 then do:
        /*
            find wt where wt.crc eq jl.crc and wt.sim eq jl.trx no-error.
            if not available wt then do:
            */
                create wt.
                wt.sim = jl.trx.
                wt.crc = jl.crc.
            /*
            end.
            */
            wt.dam = wt.dam + jl.dam.
            wt.cam = wt.cam + jl.cam.
            wt.acc = jl.acc.
            update wt.
        end.
    end.        
/*    
    for each jlsach where jlsach.jh eq jl.jh and jlsach.ln eq jl.ln no-lock :
        /*
        find wt where wt.crc eq jl.crc and wt.sim eq string(jlsach.sim)
        no-error.
        if not available wt then do:
        */
            create wt.
            wt.sim = string(jlsach.sim).
            wt.crc = jl.crc.
            wt.acc = jl.acc.
            /*
        end.
        */
        if jl.dc eq "D"
        then wt.dam = wt.dam + jlsach.amt.
        else wt.cam = wt.cam + jlsach.amt.
        update wt.
    end.
    */
end.

display '   Ждите...   '  with row 5 frame ww centered .

output stream m-out to rpt.img.
put stream m-out skip
string( today, '99/99/9999' ) + ', ' +
string( time, 'HH:MM:SS' ) + ', ' +
trim( cmp.name )                               format 'x(79)' at 02 skip(1)
'СПИСОК СЧЕТОВ КЛИЕНТОВ'                       format 'x(22)' at 29 skip
' с '  + string( v-rptfrom, '99/99/9999' ) + ' г.' format 'x(17)' at 21
' по ' + string( v-rptto,   '99/99/9999' ) + ' г.' format 'x(17)' at 41 skip(1)
'Исполнитель: ' + trim( ofc.name )             format 'x(79)' at 02 skip.
put stream m-out ' ' fill( '-', 77 )           format 'x(77)'       skip.
put stream m-out
'п/п'          at 02
'Счет'         at 07
'Наименование' at 18
'Валюта'       at 51
'Сумма'        at 70
skip.
put stream m-out ' ' fill( '-', 77 ) format 'x(77)' skip(1).

    for each wt break by wt.crc by wt.sim:
       if first-of( wt.crc ) then do:
          find first crc where crc.crc eq wt.crc no-lock no-error.
          put stream m-out skip(1) crc.des skip(2).
       end.

        ii = ii + 1.
        find cashpl where cashpl.sim eq integer(wt.sim) no-lock no-error.
        put stream m-out
        ii format '>>>9' '. '
        wt.sim " ".
        if available cashpl
        then put stream m-out cashpl.des format "x(30)" " ".
        else put stream m-out fill(" ",31).
        put stream m-out
        wt.acc format 'x(10)'
        wt.dam format ">>>,>>>,>>>,>>>,>>9.99-"
        wt.cam format ">>>,>>>,>>>,>>>,>>9.99-" skip .
    end.

put stream m-out ' ' fill( '-', 77 ) format 'x(77)' skip(2).
output stream m-out close.
output stream s-err close.

    pause 0 before-hide.
    run menu-prt( 'rpt.img' ).
    pause 0 no-message.
    pause before-hide.

return.

/***/
