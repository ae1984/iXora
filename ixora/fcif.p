/* fcif.p
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
        25/07/2007 madiyar - закомментил ссылки на ненужные таблицы
        31/07/2007 madiyar - три таблицы забыл, закомментил
*/

{vc.i}

def input parameter  v-cif like cif.cif.
def output parameter  m-nofind as log.

m1: do:
{fcif.i aaa }.
/*
{fcif.i aar }.
{fcif.i accnt }.
{fcif.i adv }.
{fcif.i apploan }.
*/
{fcif.i arp }.
{fcif.i bcif }.
{fcif.i bill }.
/*
{fcif.i bjh }.
*/
{fcif.i cfs }.
/* {fcif.i cifold }. */
{fcif.i clt }.
{fcif.i coll }.
{fcif.i dadp }.
/*
{fcif.i dap }.
*/
{fcif.i deljh }.
{fcif.i fex }.
/*
{fcif.i finance }.
{fcif.i guaold }.
{fcif.i hcr }.
{fcif.i laf }.
*/
{fcif.i gua }.
{fcif.i jh }.
{fcif.i lcr }.
{fcif.i lon }.
/*
{fcif.i loncif }.
*/
{fcif.i rim }.
{fcif.i ucc }.
/*
{fcif.i lopm }.
{fcif.i lop }.
{fcif.i atrf }.
{fcif.i catrf }.
{fcif.i ilf }.
{fcif.i lonh }.
{fcif.i sb }.
{fcif.i sbtrx }.
{fcif.i crdsts }.
*/
{fcif.i lcnt }.
{fcif.i vccontrs }. 
m-nofind = true.
end.
return.

