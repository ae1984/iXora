/* comm-rnn.i
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
        25.11.2004 г. - suchkov - Добавил проверку на длину и вхождение символов
*/

/* ------------------------- */
/*   функция проверки РНН    */
/* ------------------------- */


function comm-rnn returns logical (r as char).
def var rnnres as logical.
def var tchar  as decimal.
   if length(r) lt 12 then return yes.
   tchar = decimal(r) no-error .
   if tchar = 0 and r <> "000000000000" then return yes .
   run rnnchk (input r, output rnnres).
   return rnnres.
end function.
