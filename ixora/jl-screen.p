/* jl-screen.p
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
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
*/

/** jl-screen.p */


define input parameter kuda_snova as character.
define input parameter d_n        as character.

def shared var s-jh like jh.jh.
def var xin  as dec decimals 2 format "-z,zzz,zzz,zzz,zz9.99" label "ВЗНОС   ".
def var xout as dec decimals 2 format "-z,zzz,zzz,zzz,zz9.99" label "ВЫПЛАТА ".
def var intot  like xin.
def var outtot like xout.

define shared temp-table wf
   field wsub like jl.subled
   field wacc like jl.acc
   field wcif like aaa.cif.


{global.i}

find jh where jh.jh eq s-jh.
xin  = 0.
xout = 0.

output to vou2.img page-size 0.

{jou-prca.f}

output close.


/*
unix / *silent* / value (kuda_snova + " vou.img").
pause 0.*/

