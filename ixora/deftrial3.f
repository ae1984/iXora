/* deftrial3.f
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

/*     deftrial3.f                   */

/*    15/02/95                       */

{proghead.i " Report Trial balance    "}
def var dcnt as int format "zzzz9" label "ПРОВ.".
def var ccnt as int format "zzzz9" label "ПРОВ.".
def var tdcnt as int format "zzzz9" label "ПРОВ.".
def var tccnt as int format "zzzz9" label "ПРОВ.".
def var dr like jl.dam label "ДЕбЕТ ".
def var cr like jl.cam label "КРЕДИТ ".
def var vcif like cif.cif.
def var vpost as log.
def var vasof as date label " С ".
def var bsof  as date label " ПО ".
def var vglbal like glbal.bal.
def var vsubbal like glbal.bal.
def var vgb     like glbal.bal.
def var vsb     like glbal.bal.


def var ratels as dec format ">9.9999".
def var debls as dec format  "->>>,>>>,>>>,>>>,>>>.99".
def var credls as dec format "->>>,>>>,>>>,>>>,>>>.99".
def var unitls as int format "zzzzz9".
