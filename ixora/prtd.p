/* prtd.p
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
        26/07/2004 dpuchkov
 * CHANGES
*/


def var rsub as char.
def shared var s-remtrz like remtrz.remtrz.
def new shared var ee5 as cha initial "2" .
def shared frame remtrz.
def var v-date as date.
def var acode like crc.code.
def var bcode like crc.code.
def buffer tgl for gl.


{global.i}
{lgps.i}
{rmz.f}
{ps-prmt.i}

   update rsub  with  frame remtrz .
