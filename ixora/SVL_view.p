/* SVL_view.p
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
*/

def new shared var m-fnfull as char.
def shared var m-sqn like reject.t_sqn.
{mt100.i new}

find sysc where sysc.sysc eq "bradir".
m-fnfull = sysc.chval + "/out/" + substring(m-sqn,1,8) + "*".

        run get100f.
      
        display "Klients:" substring(v-sender,9) "Dok.:" v-ref
       "Datums:" substring(v-snddate,7)
        "Valdt:" v-valdt
        skip
        "Summa:" v-payment v-crccode 
         skip
"50"
"52" at 40 v-F52 format "x(1)" at 42
v-ordinsact at 46 format "x(35)" skip
v-ordcst[1] at 5 format "x(35)" v-ordins[1] at 46 format "x(35)" skip
v-ordcst[2] at 5 format "x(35)" v-ordins[2] at 46 format "x(35)" skip
v-ordcst[3] at 5 format "x(35)" v-ordins[3] at 46 format "x(35)" skip
v-ordcst[4] at 5 format "x(35)" v-ordins[4] at 46 format "x(35)" skip
"59" v-ba at 5 format "x(35)"
"57" at 40 v-F57 format "x(1)" at 42 v-actinsact at 46 format "x(35)" skip
v-ben[1] at 5 format "x(35)" v-actins[1] at 46 format "x(35)" skip
v-ben[2] at 5 format "x(35)" v-actins[2] at 46 format "x(35)" skip
v-ben[3] at 5 format "x(35)" v-actins[3] at 46 format "x(35)" skip
v-ben[4] at 5 format "x(35)" v-actins[4] at 46 format "x(35)" skip

"70"
v-detpay[1] at 5 format "x(35)"
"72" at 40
v-rcvinfo[1] at 46 format "x(35)" skip
v-detpay[2] at 5 format "x(35)" v-rcvinfo[2] at 46 format "x(35)" skip
v-detpay[3] at 5 format "x(35)" v-rcvinfo[3] at 46 format "x(35)" skip
v-detpay[4] at 5 format "x(35)" v-rcvinfo[4] at 46 format "x(35)" skip
"53" v-sndcoract format "x(35)"
"71" at 40
v-bi at 46 format "x(35)" skip
v-sndcor[1] at 5 format "x(35)" skip
v-sndcor[2] at 5 format "x(35)" skip
v-sndcor[3] at 5 format "x(35)" skip
WITH overlay frame b no-box no-label no-underline.
pause.
hide frame b no-pause.

