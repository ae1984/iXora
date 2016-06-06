/* csbal.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Текущее состояние ЭК
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
        --/--/2011 k.gitalov
 * BASES
        BANK COMM
 * CHANGES
*/

{global.i}
def var v-dispensedAmt as deci.
def var v-acceptedAmt as deci.
def var v-Amount as decimal extent 10.
def var rez as log.

run smart_trx(g-ofc,0,1,1,0,output v-dispensedAmt,output v-acceptedAmt, input-output v-Amount, output rez).
