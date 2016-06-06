
run payseccheck (input g-ofc, input trim(program-name(1)) + '(' + keylabel(lastkey) + ')').
if return-value <> 'yes' then 
 do:
  Message ' У вас нет прав для выполнения   ' +
   program-name(1) + '(' + keylabel(lastkey) + ') функции процедуры ! ' .
  pause.    
  next.
 end.

