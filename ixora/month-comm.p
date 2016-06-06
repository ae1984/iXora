/* month-comm.p
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
       02.04.2012 aigul
 * BASES
        BANK COMM
 * CHANGES
        04.05.2012 aigul - добавила Bases
        15/03/2013 Luiza - ТЗ № 1688 закомент-ла вызов процедуры month-comm-txb, признак передачи суммы комиссии ЭЦП меняем в программе dayclose
*/

{global.i}
def var v-glrem as char.
def var v-comm as decimal.
def var v-arp as char.
def var vdel as char no-undo initial "^".
def var v-param as char.
def var rcode as int.
def var rdes as char.
def var s-jh as int.

find first arp where arp.gl = 287082 no-lock no-error.
if avail arp then do:
    v-comm = arp.cam[1] - arp.dam[1].
    v-arp = arp.arp.
end.
v-glrem = "Комиссия за выпуск электронной цифровой подписи (ЭЦП)".
v-param = string(v-comm) + vdel +
          v-arp + vdel +
          "460828" + vdel +
          v-glrem + vdel +
          "1" + vdel +
          "1" + vdel +
          "4" + vdel +
          "4" + vdel +
          "840".
if v-comm <> 0 and v-comm > 0 then do:
    run trxgen ("alx0006", vdel, v-param, "arp", v-arp, output rcode, output rdes, input-output s-jh).
    if rcode ne 0 then do:
        message rdes.
        pause 1000.
        next.
    end.
    else do:
       run trxsts(s-jh, 6, output rcode, output rdes).
       if rcode ne 0 then do:
          run savelog( "month-comm", v-arp + " " + rdes).
          message rdes view-as alert-box title "". undo,retry.
       end.
    end.
end.
/*{r-branch.i &proc = "month-comm-txb"}*/