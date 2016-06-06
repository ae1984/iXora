/* h-knp.p
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
        16.10.2003 nadejda  - изменила формат вывода для красоты
*/

/* help for points  */
{global.i}
def temp-table knp 
 field b-cod as char format "x(3)" column-label "КОД"
 field f-name as char format "x(70)" column-label "ЗНАЧЕНИЕ" 
 index aa is primary unique b-cod . 

for each codfr where codfr.codfr = "spnpl" use-index cdco_idx no-lock:
  create knp . 
  knp.b-cod = codfr.code . 
  knp.f-name = codfr.name[1] + codfr.name[2] + codfr.name[3]. 
end.     

{itemlist.i
       &where = "true"
       &file = "knp"
       &frame = " row 5 centered 13 down overlay title ' КОДЫ НАЗНАЧЕНИЯ ПЛАТЕЖА ' "
       &flddisp = " knp.b-cod knp.f-name "
       &chkey = "b-cod"
       &index = "aa"
       &chtype = "string"
       &funadd = "if frame-value = "" "" then do:
                    {imesg.i 9205}.
                    pause 1.
                    next.
                  end."
       &set = "b"}
