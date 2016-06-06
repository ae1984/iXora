/* jl-prcaR.p
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


def shared var s-jh like jh.jh.
def var xin  as dec decimals 2 format "-z,zzz,zzz,zzz,zz9.99" label "CASH IN".
def var xout as dec decimals 2 format "-z,zzz,zzz,zzz,zz9.99" label "CASH OUT".
def var intot  like xin.
def var outtot like xout.
{global.i}
find jh where jh.jh eq s-jh.
xin  = 0.
xout = 0.
output to vou.img page-size 0.

{jl-prcaR.f}

    output close.
    unix silent prit -t vou.img.
    pause 0.
