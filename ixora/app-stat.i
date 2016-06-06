function app-stat return char (stat as integer).
    case stat:
      when 1 then
        return ("На обработке"). 
      when 11 then
        return ("На авторизации").   /*только для департамента бюджетирования */
      when 2 then
        return ("Авторизовано"). 
      when 3 then
        return ("На исполнении"). 
      when 4 then
        return ("Частично исп"). 
      when 5 then
        return ("Исполнено").
      when 8 then
        return ("Удалена").
    end.    
end function.
