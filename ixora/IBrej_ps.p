/* IBrej_ps.p
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
        25/09/06 tsoy  добавил last в find doc так как добавился суфикс в алматинские remtrz-ы   
*/


 {global.i}
 {lgps.i }

def input param st like ib.doc.state .
def input param jh like ib.doc.jh1 .
def input param unpr as cha .
def input param remtr like ib.doc.remtrz .


find last netbank where netbank.rmz = remtr no-lock no-error.
if not avail netbank then do:
    find last ib.doc where ib.doc.remtrz = remtr 
      exclusive-lock use-index idx_remtrz no-error .
    if avail ib.doc then do :
     ib.doc.state = st .
     if ib.doc.remtrz = remtr then
      ib.doc.jh1 = jh .
     else
      ib.doc.jh2 = jh .
     ib.doc.unpromsg[1] = substring(unpr,1,60) .
     ib.doc.unpromsg[2] = substring(unpr,61,60) .
     ib.doc.unpromsg[3] = substring(unpr,121,60) .
     ib.doc.unpromsg[4] = substring(unpr,181,60) .
    end .
    else do :
     v-text = " Ошибка! В базе Интернет Офиса не найден документ " + remtr .
     run lgps .
    end .

end.