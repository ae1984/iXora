/* deftrial.f
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

{proghead.i " Report Trial balance    "}
def var dcnt as int format "zzzz9" label "TRANS".
def var ccnt as int format "zzzz9" label "TRANS".
def var tdcnt as int format "zzzz9" label "TRANS".
def var tccnt as int format "zzzz9" label "TRANS".
def var dr like jl.dam label "DEBETS".
def var cr like jl.cam label "CRED§TS".
def var vcif like cif.cif.
def var vpost as log.
def var vasof as date label "PAR".
def var vglbal like glbal.bal.
def var vsubbal like glbal.bal.
