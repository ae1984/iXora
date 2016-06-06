/* opr-stat.i         
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
        17/06/05 Ilchuk
 * CHANGES 
        15.07.05 nataly  - добавлен статус 9 - изменен перевод

 */

function opr-crc  return char (crc as int).
 find first crc where crc.crc = crc no-lock no-error.
 if avail crc then  return crc.code. else return "?". /*nataly*/
end function.

function opr-stat return char (stat as int).
    case stat:
      when 1 then
        return ("Создан"). 
      when 11 then
        return ("ПодтСоз").   /*только для TEXAKA*/
      when 2 then
        return ("Отправ"). 
      when 3 then
        return ("Достав"). 
      when 4 then
        return ("Выплач").
      when 51 then
        return ("Подт.отм").   /*только для TEXAKA*/
      when 5 then
        return ("Увед.отм").
      when 6 then
        return ("Отменен").
      when 71 then
        return ("Подт.Воз").   /*только для TEXAKA*/
      when 7 then
        return ("Увед.воз").
      when 8 then
        return ("Возвращ").
      when 9 then
        return ("Изменен").
    end.    
end function.



