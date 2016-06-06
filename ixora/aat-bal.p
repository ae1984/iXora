/* aat-bal.p
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

/* aaa-bal.p
   aat-bal.p */

def buffer b-aaa for aaa.

def shared var s-toavail as dec decimals 2 label "TotAvail" init 0.
def shared var s-aaa like aaa.aaa.

def var cravail like aaa.cbal label "COLLT BAL" init 0.
def var vinc as int.
def var vcbal like aaa.cbal.
def var vavail like aaa.cbal.

find aaa where aaa.aaa = s-aaa no-lock.
find lgr where lgr.lgr eq aaa.lgr no-lock.
find led where led.led eq lgr.led no-lock.


if aaa.loa ne ""
then do:
       find b-aaa where b-aaa.aaa = aaa.loa.
       cravail = (b-aaa.dr[5] - b-aaa.cr[5])
	       - (b-aaa.dr[1] - b-aaa.cr[1]).
     end.

s-toavail = aaa.cbal + cravail - aaa.hbal.
