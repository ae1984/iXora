/* p-codific.p
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
        28.03.12 Lyubov - отличается от p-codific только параметром papa
 * CHANGES
*/

/* h-quetyp.p */
  {global.i}
def input parameter  v-codfr like codfr.codfr.
def input parameter  p-code  like codfr.code .
def output parameter v-code  like codfr.code .
def var h as int .
def var i as int .
def var d as int .
def var c-name like codific.name.
h = 15 .
d = 60.
find first codific where codific.codfr = v-codfr no-lock no-error .
if avail codific then c-name = codific.name .
do:
       {browpnp.i
        &h = "h"
        &form = " codfr.code format 'x(9)' column-label ' Код '
         codfr.name[1] format 'x(70)' column-label 'Описание' "
        &where = " codfr.codfr = v-codfr and codfr.papa = 'yes' and can-do(p-code,substr(codfr.code,1,4)) use-index cdco_idx  "
        &frame-phrase = "row 3 centered scroll 1 h down overlay
        title 'Справочник ' + v-codfr + ' ' +  c-name width 82"
        &predisp = " "
        &seldisp = "codfr.code"
        &file = "codfr"
        &disp = " codfr.code codfr.name[1] "
        &addcon = "false "
        &updcon = "false "
        &delcon = "false"
        &retcon = "true"
        &enderr = " hide all. "
        &befret = " v-code = codfr.code . hide all . "
        &action = " "
       }
end.
