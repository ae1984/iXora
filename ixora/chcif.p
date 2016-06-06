/* chcif.p
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
 * BASES
        BANK COMM
 * CHANGES
        25/07/2007 madiyar - закомментил ссылки на ненужные таблицы
        13.04.2012 damir - изменил формат с "yes/no" на "да/нет".
*/


def var i as int.
def var j as int.

def var m-nofind as log.
def var v-cif like cif.cif.
def var s-cif like cif.cif.
def var ans as log format "да/нет".

def var m-aaa as log initial false.
def var m-aar as log initial false.
/*
def var m-accnt as log initial false.
def var m-adv as log initial false.
def var m-apploan as log initial false.
*/
def var m-arp as log initial false.
def var m-bcif as log initial false.
def var m-bill as log initial false.
/*
def var m-bjh as log initial false.
*/
def var m-cfs as log initial false.
/*
def var m-cifold as log initial false.
*/
def var m-clt as log initial false.
def var m-coll as log initial false.
def var m-dadp as log initial false.
def var m-dap as log initial false.
def var m-deljh as log initial false.
def var m-fex as log initial false.
/*
def var m-finance as log initial false.
def var m-guaold as log initial false.
*/
def var m-gua as log initial false.
def var m-hcr as log initial false.
def var m-jh as log initial false.
def var m-laf as log initial false.
def var m-lcr as log initial false.
def var m-lon as log initial false.
/*
def var m-loncif as log initial false.
*/
def var m-rim as log initial false.
def var m-ucc as log initial false.
/*
def var m-lopm as log initial false.
def var m-lop as log initial false.
def var m-atrf as log initial false.
def var m-catrf as log initial false.
*/
def var m-ilf as log initial false.
def var m-lonh as log initial false.
def var m-sb as log initial false.
def var m-sbtrx as log initial false.
/*
def var m-crdsts as log initial false.
*/
def var m-lcnt as log initial false.
def var m-stmset as log initial false.
def var m-stmshi as log initial false.
def var m-stgenhi as log initial false.


{changecif1.i aaa }.
{changecif1.i aar }.
/*
{changecif1.i accnt }.
{changecif1.i adv }.
{changecif1.i apploan }.
*/
{changecif1.i arp }.
{changecif1.i bcif }.
{changecif1.i bill }.
/*
{changecif1.i bjh }.
*/
{changecif1.i cfs }.
/*
{changecif1.i cifold }.
*/
{changecif1.i clt }.
{changecif1.i coll }.
{changecif1.i dadp }.
{changecif1.i dap }.
{changecif1.i deljh }.
{changecif1.i fex }.
/*
{changecif1.i finance }.
{changecif1.i guaold }.
*/
{changecif1.i gua }.
{changecif1.i hcr }.
{changecif1.i jh }.
{changecif1.i laf }.
{changecif1.i lcr }.
{changecif1.i lon }.
/*
{changecif1.i loncif }.
*/
{changecif1.i rim }.
{changecif1.i ucc }.
/*
{changecif1.i lopm }.
{changecif1.i lop }.
{changecif1.i atrf }.
{changecif1.i catrf }.
*/
{changecif1.i ilf }.
{changecif1.i lonh }.
{changecif1.i sb }.
{changecif1.i sbtrx }.
/*
{changecif1.i crdsts }.
*/
{changecif1.i lcnt }.


repeat:

form " Old CIF " s-cif skip
     " New Cif " v-cif
with frame aa title "Change CIF " centered no-label.
update s-cif v-cif with frame aa.
ans = no.

find cif where cif.cif = s-cif no-lock no-error.
display cif.cif trim(trim(cif.prefix) + " " + trim(cif.name)) format "x(30)" cif.addr no-label with frame b row 4
title "Old CIF".

find cif where cif.cif = v-cif no-lock no-error.
display cif.cif trim(trim(cif.prefix) + " " + trim(cif.name)) format "x(30)" cif.addr no-label with frame c row 12
title "New CIF".
message "Processed " update ans.


if ans then do transaction :

{changecif2.i aaa }.
{changecif2.i aar }.
/*
{changecif2.i accnt }.
{changecif2.i adv }.
{changecif2.i apploan }.
*/
{changecif2.i arp }.
{changecif2.i bcif }.
{changecif2.i bill }.
/*
{changecif2.i bjh }.
*/
{changecif2.i cfs }.
/* {changecif2.i cifold }. */
{changecif2.i clt }.
{changecif2.i coll }.
{changecif2.i dadp }.
{changecif2.i dap }.
{changecif2.i deljh }.
{changecif2.i fex }.
/*
{changecif2.i finance }.
{changecif2.i guaold }.
*/
{changecif2.i gua }.
{changecif2.i hcr }.
{changecif2.i jh }.
{changecif2.i laf }.
{changecif2.i lcr }.
{changecif2.i lon }.
/*
{changecif2.i loncif }.
*/
{changecif2.i rim }.
{changecif2.i ucc }.
/*
{changecif2.i lopm }.
{changecif2.i lop }.
{changecif2.i atrf }.
{changecif2.i catrf }.
*/
{changecif2.i ilf }.
{changecif2.i lonh }.
{changecif2.i sb }.
{changecif2.i sbtrx }.
/*
{changecif2.i crdsts }.
*/
{changecif2.i lcnt }.

{changecif2.i stmset }.
{changecif2.i stmshi }.
{changecif2.i stgenhi }.


end.
end.
