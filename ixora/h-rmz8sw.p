/* h-rmz8sw.p
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

def shared var vsel7 as cha format "x".
def shared var s-remtrz like remtrz.remtrz.
def var h as int.
h= 12.
if vsel7 = 'SW' then do :
     {browpnp.i
        &h = "h"
        &where = " que.pid = '3' and que.con <> 'F'         
        and  (can-find(remtrz where remtrz.remtrz = que.remtrz and 
         remtrz.source  = 'SW' and remtrz.fcrc = 1 )) use-index fprc "
        &frame-phrase = "row 1 centered scroll 1 h down"
         &predisp =  "find remtrz where remtrz.remtrz = que.remtrz
          no-lock no-error .
          display 
            remtrz.source column-label ""Источник""
            remtrz.ptype column-label ""Тип""
            remtrz.rdt column-label ""Рег.дата""
            remtrz.valdt1 column-label ""1Дата""
            remtrz.valdt2 column-label ""2Дата""
            remtrz.sbank column-label ""БанкО""
            remtrz.rbank column-label ""БанкП""
            with row 17. 
          pause 0 .
          display 
            que.pid column-label ""Код""
            que.con column-label ""Сост.""
            with row 17. 
          pause 0. "

        &seldisp = "que.remtrz"
        &file = "que"
        &disp = "
          que.remtrz  column-label ""Платеж""
          remtrz.ref column-label ""Nr."" format 'x(40)' 
          remtrz.payment column-label ""СуммаК""
          remtrz.tcrc column-label ""Вал.К"" "
        &addupd = " que.remtrz "
        &upd    = "  "
        &addcon = "false"
        &updcon = "false"
        &delcon = "false"
        &retcon = "true"
        &enderr = " hide all.  "
        &befret = " s-remtrz = que.remtrz .
                    frame-value = que.remtrz . 
                    hide all. "
                              }
end.   
     
