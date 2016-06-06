/* h-ccode1.p
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

/* h-quetyp.p */
  {global.i} 
/*
{ps-prmt.i}    
*/
def var h as int .
def var i as int .
def var d as int .
def shared var v-d-cod like codfr.codfr . 
h = 13 .
d = 60.
do:
       {browpnp.i
        &h = "h"
        &first = " 
        form ' Enter - Выбор               '
         with no-label  centered row 21 overlay no-box frame dd1 .
        find first codific where codific.codfr = v-d-cod 
         no-error . if avail codific then cur = recid(codific) . "
        &form = " " 
        &where = " true "
        &frame-phrase = "no-label row 4 column 20 scroll 
                 1 h down overlay title ' Справочники ' "
        &predisp = " view frame dd1. " 
        &seldisp = "codific.codfr "
        &file = "codific"
        &disp = " codific.codfr codific.name "
        &addcon = "false "
        &updcon = "false "
        &delcon = "false"
        &retcon = "true"
        &enderr = " v-d-cod = ''  .  hide frame dd1  . "
        &befret = " v-d-cod = codific.codfr . "
        &action = " "
       }

end.
