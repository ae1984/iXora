/* h-rmz7.p
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

def shared var vsel6 as cha format "x".
def shared var s-remtrz like remtrz.remtrz.
def var h as int.
     h= 12.

       {browpnp.i
        &h = "h"
        &where = " que.pid = 'G' and que.con <> 'F'
        and ( can-find(remtrz where remtrz.remtrz = que.remtrz and 
            remtrz.source begins vsel6))       
         use-index fprc"
        &frame-phrase = "row 1 centered scroll 1 h down"
         &predisp = "find remtrz where remtrz.remtrz = que.remtrz
          no-lock no-error . "

        &seldisp = "que.remtrz column-label 'Платеж' "
        &file = "que"
        &disp = "que.remtrz column-label 'Платеж'
                 remtrz.ref format ""x(20)"" column-label 'Ссылка' 
                 remtrz.ptype column-label 'Тип' 
                 remtrz.rdt column-label 'Рег.дата'
                 remtrz.valdt1 column-label 'Вал.дата1' 
                 remtrz.valdt2 column-label 'Вал.дата2' "
        &addupd = " que.remtrz  column-label 'Платеж' "
        &upd    = "  "
        &addcon = "false"
        &updcon = "false"
        &delcon = "false"
        &retcon = "true"
        &befret = " s-remtrz = que.remtrz .
                    frame-value = que.remtrz .
                    hide all . " }

