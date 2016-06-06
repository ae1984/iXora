/* erl_gf.p
 * MODULE
        Расчет эффективных ставок
 * DESCRIPTION
        Расчет эффективных ставок по гарантиям
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
        12/05/2010 madiyar - скопировал из erl_bdf.p с изменениями
 * BASES
        BANK
 * CHANGES
*/

{global.i}

def input parameter v-sum as deci no-undo.
def input parameter v-srok as integer no-undo.
def input parameter v-rate as deci no-undo.
def input parameter v-rdt as date no-undo.
def input parameter v-pdt as date no-undo.
def input parameter v-komf as deci no-undo. /* комиссия за выдачу гарантии */

def output parameter v-er as deci no-undo.

define variable dn1 as integer no-undo.
define variable dn2 as decimal no-undo.

def var v-prc as deci no-undo.


{er.i}

empty temp-table b2cl.
empty temp-table cl2b.

run day-360(v-rdt,v-pdt - 1,360,output dn1,output dn2).
v-prc = round(dn1 * v-sum * v-rate / 100 / 360,2).

create cl2b.
cl2b.dt = v-pdt.
cl2b.days = v-pdt - v-rdt.
cl2b.sum = v-sum + v-prc.

v-er = get_er(v-sum,v-komf,0.0,0.0).

