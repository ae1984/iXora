/* f_sthe.f
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

form
   		 stgenhi.seq 	 label "Nr." 
                 stgenhi.d_from  label "С"
                 stgenhi.d_to    label "По" 
                 stgenhi.who     label "Исполн."
                 stgenhi.tm      label "Время"
                 stgenhi.gen_date label "Дата"
                 stgenhi.sts      label "Стс"
                 stgenhi.active   label "Активн."
                 stgenhi.mode     label "Режим"      
  
with 11 down title "История выписок" overlay row 7 column 2 frame f_sthe.	
