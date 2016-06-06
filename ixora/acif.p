/* acif.p
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
        24/01/08 marinav - rcp -> scp
*/

def var nam_out as char.
DEFINE STREAM out_acif.       /*kontu fail*/
def var vhost as char.

{mainhead.i }.
input through value("askhost").
import vhost.
input close.


nam_out = "acif.txt".
OUTPUT STREAM out_acif TO VALUE(nam_out).
FOR EACH aaa where not(aaa.aaa  begins "5") :
      PUT STREAM out_acif 
          aaa.aaa format "x(10)" aaa.sta format "x(1)" aaa.crc format "z9".
      find cif where cif.cif = aaa.cif no-lock no-error.
        if available cif then do:
      PUT STREAM out_acif  trim(trim(cif.prefix) + " " + trim(cif.name)) format "x(50)".         
      end.       
      find first aas where aas.aaa = aaa.aaa  and aas.sic= "SP" no-lock no-error.
      if available aas  and aas.sic = "SP" then 
      
      PUT STREAM out_acif  aas.sic format "x(2)" skip.
     
      else  PUT STREAM out_acif "  " skip.
       
END.  
OUTPUT STREAM out_acif CLOSE.

unix silent alt value("acif.txt").
/*unix silent scp -q acif.txt value(vhost + ":C:/kassa").*/
input through value("cpy -put acif.txt C:/kassa ;echo $?").


