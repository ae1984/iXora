/* Sm-vrd.p
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
        05.05.06 Ten - добавил проверку: если сумма < 1 то пишем 0 .
*/

define input  parameter in-summa  as deci.
define output parameter out-summa as character.
define variable i           as integer.
define variable j           as integer.
define variable k           as integer.
define variable klas-s      as integer.
define variable sim-cip     as integer.
define variable vien-cip    as integer.
define variable des-cip     as integer.
define variable c-s         as character.
define variable klase       as character extent 12 init
        ["миллиард ","миллиардов ","миллиарда ","миллион ","миллионов ",
        "миллиона ","тысяча ","тысяч ","тысячи "," "," "," "].
define variable vieni       as character extent 10 init
        [" ","один ","два ","три ","четыре ","пять ","шесть ",
         "семь ","восемь ","девять "].

define variable vienA       as character extent 10 init
        [" ","одна ","две ","три ","четыре ","пять ","шесть ",
         "семь ","восемь ","девять "].

define variable desmiti     as character extent 10 init
        [" ","десять ","двадцать ","тридцать ","сорок ","пятьдесят ",
        "шестьдесят ","семьдесят ","восемьдесят ","девяносто "].
        
define variable padsmiti    as character extent 10 init
        [" ","одиннадцать ","двенадцать ","тринадцать ","четырнадцать ",
        "пятнадцать ","шестнадцать ","семнадцать ",
        "восемнадцать ","девятнадцать "].
        
define variable simti       as character extent 10 init
        [" ","сто ","двести ",
        "триста ","четыреста ","пятьсот ",
        "шестьсот ","семьсот ","восемьсот ","девятьсот "].
        
define variable mazie       as character extent 8 init
       ["о","д","т","ч","п","ш","в","с"].
       
define variable lielie      as character extent 8 init
       ["О","Д","Т","Ч","П","Ш","В","С"].

c-s = string(in-summa,"999,999,999,999.99").


out-summa = "".
     if c-s = "000,000,000,000.00" or dec(c-s) < 1
     then out-summa = "ноль ".
     else do:
          i = 1.
          repeat while i <= 4:
             k = index(c-s,",") - 1.
             if k = - 1
             then k = index(c-s,".") - 1.
             klas-s = integer(substring(c-s,1,k)).
             c-s = substring(c-s,k + 2).                                
             
             if klas-s > 0 then do:
                  sim-cip = integer((klas-s - klas-s modulo 100 )/ 100).
                  des-cip = klas-s - 100 * sim-cip.
                  des-cip = integer((des-cip - des-cip modulo 10) / 10).
                  vien-cip = klas-s modulo 10 .
                  out-summa = out-summa + simti[sim-cip + 1].
                  j = 2.
                  
                  if des-cip > 1 then do:
                       out-summa = out-summa + desmiti[des-cip + 1].
                       
                       if i ne 3 then do:
                          if vien-cip = 1 and des-cip > 1 then j = 1.
                          if  vien-cip ge 2 and vien-cip le 4 then j = 3.
                          else if vien-cip ge 5 then j = 2.
                          out-summa = out-summa + vieni[vien-cip + 1].
                       end.
                       else do:
                          if vien-cip = 1 and des-cip > 1 then j = 1.
                          if  vien-cip ge 2 and vien-cip le 4 then j = 3.
                          else if vien-cip ge 5 then j = 2.
                          out-summa = out-summa + vienA[vien-cip + 1].
                       end.   
                  end.
                  else do:
                       if des-cip = 1 and vien-cip > 0 then do:
                            out-summa = out-summa + padsmiti[vien-cip + 1].
                            j = 2.
                       end.
                       else if des-cip = 1 and vien-cip =  0 then do:
                            out-summa = out-summa + desmiti[des-cip + 1].
                            j = 2.
                       end.
                       else if des-cip = 0 and vien-cip > 0 then do:
                            if i ne 3 then do:
                               if vien-cip = 1 then j = 1.
                               if vien-cip ge 2 and vien-cip le 4 then j = 3.
                               if vien-cip ge 5 then j = 2.
                               out-summa = out-summa + vieni[vien-cip + 1].
                            end.
                            else do:
                               if vien-cip = 1 then j = 1.
                               if vien-cip ge 2 and vien-cip le 4 then j = 3.
                               if vien-cip ge 5 then j = 2.
                               out-summa = out-summa + vienA[vien-cip + 1].
                            end.
                       end.
                  end.
                  out-summa = out-summa + klase[3 * (i - 1) + j].
             end.
             i = i + 1.
          end.
     end.
     out-summa = trim(out-summa).
/*     do i = 1 to 8:
        if substring(out-summa,1,1) = mazie[i] then leave.
     end.
     if i <= 8 then overlay(out-summa,1,1) = lielie[i].*/
     overlay(out-summa,1,1) = caps(substring(out-summa,1,1)).    
return.
/***/

