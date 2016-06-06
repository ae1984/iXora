/* newmonth.p
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

/* newmonth
*/

define var v-date as date label "Start Date".

{global.i "NEW" }
run setglob.

v-date = g-today.

find last cls.
g-today = cls.cls + 1.
display v-date with row 2 side-label no-box frame td.

if day(g-today) ne 1
then do:
       bell.
       {mesg.i 0236}.
       undo, leave.
     end.
else if month(g-today) ne 1
then do:
       display "Now Moving EOM Balance for All Ledgers...." with frame rem row 5
           centered no-label.
       for each trxbal :
        trxbal.mcam = trxbal.cam.
        trxbal.mdam = trxbal.dam.
       end. 
       for each aaa:
         aaa.mdr[1] = aaa.dr[1].
         aaa.mdr[2] = aaa.dr[2].
         aaa.mdr[3] = aaa.dr[3].
         aaa.mdr[4] = aaa.dr[4].
         aaa.mdr[5] = aaa.dr[5].
         aaa.mcr[1] = aaa.cr[1].
         aaa.mcr[2] = aaa.cr[2].
         aaa.mcr[3] = aaa.cr[3].
         aaa.mcr[4] = aaa.cr[4].
         aaa.mcr[5] = aaa.cr[5].
         aaa.mcnt[1] = aaa.cnt[1].
         aaa.mcnt[2] = aaa.cnt[2].
         aaa.mcnt[3] = aaa.cnt[3].
         aaa.mcnt[4] = aaa.cnt[4].
         aaa.mcnt[5] = aaa.cnt[5].
         aaa.ytdacc = aaa.ytdacc + aaa.mtdacc.
         aaa.mtdacc = 0.
         aaa.minbal[1] = 9999999999.99.
         aaa.maxbal[1] = -999999999.99.
         aaa.rsv-dec[1] = 0.
         aaa.rsv-dec[2] = 0.

         aaa.pdr[month(g-today)] = 0.
         aaa.pcr[month(g-today)] = 0.

       end.
       for each crc where crc.sts ne 9:
         for each gl:
           find glbal where glbal.gl eq gl.gl and glbal.crc eq crc.crc.
           glbal.mdam = glbal.dam.   glbal.mcam = glbal.cam.
           glbal.mdam = glbal.dam.   glbal.mcam = glbal.cam.
           glbal.mdam = glbal.dam.   glbal.mcam = glbal.cam.
           glbal.mdam = glbal.dam.   glbal.mcam = glbal.cam.
           glbal.mdam = glbal.dam.   glbal.mcam = glbal.cam.
         end.
       end.

       {daymon.i arp}
       {daymon.i lon}
       {daymon.i bill}
       /* {daymon.i rim} */
       {daymon.i fun}
       {daymon.i lcr}
       {daymon.i ock}
       {daymon.i eck}
       {daymon.i ast}
       /* {daymon.i dap} */
       {daymon.i iof}
       {daymon.i dfb}
       {daymon.i eps}
       pause 0.
       bell. bell. bell.
       {mesg.i 0876}.
     end.
else run newyear.
current-value(vptrx) = 1.
find sysc where sysc.sysc eq "CURMON".
sysc.inval = month(g-today).
quit.
