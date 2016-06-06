/* rkorepfun.i       
 * MODULE
        
 * DESCRIPTION
          Все необходимые функции для отчета 8-2-5-15
 * RUN
        
 * CALLER
        
 * SCRIPT

 * INHERIT
        
 * MENU

 * AUTHOR
     28.09.2004 saltanat     
 * CHANGES
     15.10.2004 saltanat - Дополнила функцией получения наименования филиала.
     02/07/2007 madiyar - немного переделал, чтобы убрать явное упоминание кодов конкретных филиалов
*/


function def_dep returns char (input v-dep as char).
def var ide as int.
ide = integer(v-dep) mod 1000.
find first ppoint where ppoint.depart = ide no-lock no-error.
if avail ppoint then return ppoint.name.
else return ''.
end function.

function user_dep returns char (input v-user as char).
  find first ofc where ofc.ofc = v-user no-lock no-error.
  if avail ofc then return string(ofc.regno).
  else return ''.
end function.

function fil_name returns char (input v-nm as char).

find first comm.txb where comm.txb.bank = v-nm and comm.txb.consolid no-lock no-error.
if avail comm.txb then return substring(comm.txb.info,3).
else return v-nm.

end function.

function def_jame returns char (input v-id as int).
CASE v-id:
  WHEN 0 THEN
    return "1035".
  WHEN 1 THEN  
    return "1036".
  WHEN 2 THEN  
    return "1002".
  WHEN 3 THEN  
    return "1004".
  WHEN 4 THEN  
    return "1003".
  WHEN 5 THEN  
    return "1037".
END CASE.
end function.

function def_val returns int (input v-id as int).
CASE v-id:
  WHEN 1 THEN  
    return 1.
  WHEN 2 THEN  
    return 2.
  WHEN 3 THEN  
    return 4.
  WHEN 4 THEN  
    return 11.
END CASE.
end function.

function def_valname returns char (input v-id as int).
CASE v-id:
  WHEN 1 THEN  
    return "KZT".
  WHEN 2 THEN  
    return "USD".
  WHEN 3 THEN  
    return "RUB".
  WHEN 4 THEN  
    return "EUR".
END CASE.
end function.

function def_valute returns char (input v-id as int).
CASE v-id:
  WHEN 1 THEN  
    return "KZT".
  WHEN 2 THEN  
    return "USD".
  WHEN 4 THEN  
    return "RUB".
  WHEN 11 THEN  
    return "EUR".
END CASE.
end function.

