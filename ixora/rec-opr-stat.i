/* rec-opr-stat.i        
 * MODULE
        Переводы
 * DESCRIPTION
        Определение статуса 
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT

 * MENU
 * AUTHOR
        19/06/05 Ilchuk
 * CHANGES 

 */

function opr-crc  return char (crc as int).
 find first crc where crc.crc = crc no-lock no-error.
 if avail crc then return crc.code.
end function.


function rec-opr-stat return char (stat as int).
    case stat:
      when 1 then
        return ("Доставлен"). 
      when 11 then
        return ("Подтвер"). /*только для TEXAKA*/
      when 2 then
        return ("Выплачен"). 
      when 3 then
        return ("Отменен"). 
      when 4 then
        return ("Возвращен"). 
    end.    
end function.



