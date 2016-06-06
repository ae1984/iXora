/* h-ccode.p
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
        29.03.2012 Lyubov - добавила параметр при вызове процедуры p-codific
*/

/* h-quetyp.p */
  {global.i}
/*
{ps-prmt.i}
*/
def var h as int .
def var i as int .
def var d as int .
def shared var v-code like codfr.code .
def shared var v-d-cod like codfr.codfr .
h = 15 .
d = 60.
do:
       {browpnp.i
        &h = "h"
        &first = " find first codific where codific.codfr = v-d-cod
         no-error . if avail codific then cur = recid(codific) . "
        &form = " "
        &where = " true "
        &frame-phrase = "no-label row 1 centered scroll
                 1 h down overlay title ' Справочники ' "
        &predisp = " "
        &seldisp = "codific.codfr "
        &file = "codific"
        &disp = " codific.codfr codific.name "
        &addcon = "false "
        &updcon = "false "
        &delcon = "false"
        &retcon = "false"
        &enderr = " v-d-cod = '' . hide all. "
        &befret = "  "
        &action = "
         if keyfunction(lastkey) = ""return""
               then do:
                   run p-codific(codific.codfr,'*',output v-code).
                   v-d-cod = codific.codfr .
                   return .
               end.
          "
       }

end.
