/* Sm-vrde.p
 * MODULE
        Преобразование числа к прописному виду  на англ.яз
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
        26/09/2006 u00777
 * CHANGES

*/

define input  parameter in-summa  as deci.
define output parameter out-summa as character.
define variable i           as integer no-undo.
define variable j           as integer no-undo.
define variable k           as integer no-undo.
define variable klas-s      as integer no-undo.
define variable sim-cip     as integer no-undo.
define variable vien-cip    as integer no-undo.
define variable des-cip     as integer no-undo.
define variable c-s         as character no-undo.

define variable klase       as character extent 12 init
        ["billion","million ","thousand "," "," "," "," "," "," "," "," "," "].


define variable vieni       as character extent 10 init
        [" ","one ","two ","three ","four ","five ","six ",
         "seven ","eight ","nine "].

define variable desmiti     as character extent 10 init
        [" ","ten ","twenty ","thirty ","forty ","fifty ",
        "sixty ","seventy ","eighty ","ninety "].
        
define variable padsmiti    as character extent 10 init
        [" ","eleven ","twelve ","thirteen ","fourteen ",
        "fifteen ","sixteen ","seventeen ",
        "eighteen ","nineteen "].
        
c-s = string(in-summa,"999,999,999,999.99").

out-summa = "".
     if c-s = "000,000,000,000.00" or dec(c-s) < 1
     then out-summa = "zero ".
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
                  out-summa = out-summa + vieni[sim-cip + 1].
                  if sim-cip + 1 > 1 then
                     out-summa  =  out-summa + "hundred ".

                  if des-cip > 1 then do:
                       out-summa = out-summa + desmiti[des-cip + 1].
                       out-summa = out-summa + vieni[vien-cip + 1].
                  end.
                  else do:
                       if des-cip = 1 and vien-cip > 0 then 
                          out-summa = out-summa + padsmiti[vien-cip + 1].
                       else if des-cip = 1 and vien-cip =  0 then 
                          out-summa = out-summa + desmiti[des-cip + 1].                       
                       else out-summa = out-summa + vieni[vien-cip + 1].                                                 
                  end.
                  out-summa = out-summa + klase[i].
             end.
             i = i + 1.
          end.
     end.
     out-summa = trim(out-summa).
     overlay(out-summa,1,1) = caps(substring(out-summa,1,1)).    
return.
/***/

