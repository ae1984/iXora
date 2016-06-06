/* html-title.i
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



put {&stream} unformatted 
   "<HTML>" skip 
   "<HEAD>" skip
   "<TITLE>" skip.

put {&stream} unformatted 
   '{&title}' skip.

put {&stream} unformatted 
   "</TITLE>" skip
   "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251""/>" skip
   "<META HTTP-EQUIV=""Content-Language"" content=""ru""/>" skip
   "<STYLE TYPE=""text/css"" ID=""default""> table \{font:Times New Roman Cyr, Verdana, sans; font-size: " skip.

put {&stream} unformatted    
       "{&size-add}". 

put {&stream} unformatted        
       "small; border-collapse: collapse; text-valign:top\}</STYLE>" skip
   "</HEAD>" skip
   "<BODY>" skip.
