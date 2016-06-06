/* ds5.p
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
 * BASES
        BANK COMM
 * AUTHOR
        31/12/99 pragma
 * CHANGES
*/



{global.i}


      def var n-ofc as char.
      def var f_name as char.
      def var n-amt as decimal.
      def var str_p as char.
      def var v_spf1 as integer.
      def var v_spf as char.
      def var i-ind as integer.

find first cmp no-lock no-error.

                                                        
      define frame frame1  
      v_spf label  "Выберите наименование "  format "x(50)" 
      with side-labels centered row 9.


on help of v_spf in frame frame1 do:
   str_p = "".

       for each ppoint  no-lock :
         str_p = str_p + string (ppoint.name) + "|".
       end.


       run sel ("Выберите подразделение", str_p).
       i-ind = 0.
       for each ppoint   no-lock :
          i-ind = i-ind + 1.
          if i-ind = int(return-value) then do:
             v_spf = ppoint.name.
             v_spf1 = ppoint.depart.
             displ v_spf with frame frame1.     
             leave.
          end.
       end.
end.





      update v_spf with frame frame1 side-labels centered row 9.  

   find last  depaccnt where depaccnt.depart = v_spf1 exclusive-lock no-error.

find last ofc where ofc.ofc = g-ofc no-lock no-error.

f_name = string(g-today) +  ".txt".


output to xx.tmp.

put unformatted  "                            ОТЧЕТ О СОСТОЯНИИ КАССЫ \r\n \r\n" .



put unformatted  cmp.name  " " cmp.addr[1]  " \r\n".
/*put unformatted  "Бостандыкский район, Алматы, ПФЦ Нурлы-тау, пр. Аль-Фараби, 19 корпус 1Б, офис 3 \r\n"  . */
put unformatted  ppoint.name  " "  entry(2,depaccnt.rem,'$')  " \r\n" .

put unformatted  "РНН " cmp.addr[2]  " \r\n"  .
put unformatted  "Рег. номер БКС в НК:" entry(1,depaccnt.rem,'$')    " \r\n"  .
put unformatted  "Исполнитель: " + ofc.name  + "\r\n".
put unformatted  g-today  "  "  string(time,"hh:mm:ss")   + "\r\n".




put unformatted  "====================================================================================  \r\n" .
put unformatted  "ВАЛЮТА - ТЕНГЕ                     СУММА                                              \r\n" .
put unformatted  "------------------------------------------------------------------------------------------------------------------------------------------------------------------------ \r\n" .











find ofc where ofc.ofc eq n-ofc no-lock no-error.
if avail ofc then do:
for each cashofc  where 
                   cashofc.ofc eq g-ofc and
                   cashofc.whn eq g-today
                   and cashofc.sts eq 2 no-lock
                   by cashofc.crc :
                    
find first crc where crc.crc eq cashofc.crc no-lock no-error.
if avail crc then
   n-amt = cashofc.amt.

end. /* avail ofc */
end.














put unformatted  "ТЕКУЩИЙ ИТОГ                       "  n-amt format "zzz,zzz,zzz,zz9.99"   "\r\n \r\n"   . 
put unformatted  "==================================================================================== \r\n" .
output close.









   input through  value("ssh Administrator@`askhost`" + " del"  +  " c:\\\\OUT\\\\*.* /Q  ; echo $? ; ").  





  unix silent value('un-win xx.tmp x.tmp'). 
/* input through  value("scp -q x.txt Administrator@`askhost`:C:/OUT/" +  ";echo $?" ). */


   input through  value("scp -q x.tmp Administrator@`askhost`:C:/OUT/" +  ";echo $?" ).
   input through  value("ssh Administrator@`askhost`" + " mkdir"  +  " c:\\\\tmp ; echo $? ; "). 

/*   input through  value("scp -q /data/9/export/open_key1.bin Administrator@`askhost`:C:/tmp/" +  ";echo $?" ). */


function ns_check returns character (input parm as character).
    def var v-str as char no-undo.
    v-str = parm.
    v-str = replace(v-str,"/","//").
    v-str = replace(v-str,"!","\\!").
    v-str = replace(v-str," ","\\ ").
    v-str = "\\""" + v-str + "\\""".
    return (v-str).
end function.





    input through  value("ssh Administrator@`askhost` " + ns_check("C:/Program Files/GammaTech/TumarCSP/cptumar.exe ") + "' -key fopn=c:/tmp/open_key1.bin'").
    input through  value("ssh Administrator@`askhost` " + ns_check("C:/Program Files/GammaTech/TumarCSP/cptumar.exe ") + "' -crp fin=c:/OUT/x.tmp fout=c:/OUT/x.crp fopn=c:/tmp/open_key1.bin fses=c:/OUT/ses_key.bin'").
    input through  value("ssh Administrator@`askhost`" + " del"  +  " c:\\\\OUT\\\\x.tmp ; echo $? ; "). 




 








