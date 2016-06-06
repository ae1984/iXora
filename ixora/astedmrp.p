/* astedmrp.p
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

/*astedmrp.p 
  Вод и редактирование
  месячного расчетного показателя 
  для отбора ОС по первоначальной стоимости
  14.02.2001  */
  
{mainhead.i}

{jabra.i
&head      = "astmrp"
&headkey   = "astmrp"
&index     = "ykv" 
&where     = " "
&addcon    = "true"
&deletecon = "true"
&start     = " "
&formname  = "astmrp"
&framename = "astmrp"
&postadd   = "hide message no-pause.
              message color normal
              '               <Enter>-ВВОД <F1>-СОХРАНЕНИЕ <F4>-ОТКАЗ'.
              update  astmrp.r-year 
                       validate(astmrp.r-year ge '1995' 
                       and astmrp.r-year le string(year(g-today)) ,
                       ' Недопустимое значение! ')
                      astmrp.r-kvart 
                       validate(astmrp.r-kvart ge '0'and astmrp.r-kvart le '4',
                       ' Недопустимое значение! ') 
                       help '1,2,3,4 - на соотвествующий квартал; 0 - на весь год'
                      astmrp.r-sum
              with frame astmrp.
              astmrp.who = g-ofc.
              astmrp.whn = g-today."
&prechoose = "message color normal
    '         <Enter>-РЕДАКТ. <Insert>-ДОБАВИТЬ <Ctrl-D>-УДАЛИТЬ <F4>-ВЫХОД'."
&display   = "astmrp.r-year astmrp.r-kvart astmrp.r-sum "
&highlight = "astmrp.r-year astmrp.r-kvart astmrp.r-sum "
&postkey   = "else if keyfunction(lastkey) = 'RETURN' then do transaction 
              on endkey undo, leave:
               do on endkey undo, leave:
                 hide message no-pause.
                 message color normal
                 '                    <Enter>-ВВОД <F1>-СОХРАНЕНИЕ <F4>-ОТКАЗ'.
                 update astmrp.r-year astmrp.r-kvart astmrp.r-sum
                 with frame astmrp.
                 astmrp.who = g-ofc.
                 astmrp.whn = g-today.
               end.
               displ astmrp.r-year astmrp.r-kvart astmrp.r-sum
               with frame astmrp.
              end."

&predelete = " "
&end       = "hide message no-pause."
}

