/* ds4.p
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
{get-dep.i}
      def var date1 as char.
      def var date2 as char.
      def var f_name as char.
      def var n-ofc as char.
      def var m-cashgl like jl.gl    no-undo.
      def var m-first as logical     no-undo.
      def var m-firstout as logical  no-undo.
      def var m-sumd  like aal.amt   no-undo.
      def var m-sumk  like aal.amt   no-undo.
      def var m-aah   like jh.jh     no-undo.
      def var m-who   like aal.who   no-undo.
      def var m-ln    like aal.ln    no-undo.
      def var ni    as integer    no-undo.
          ni = 0.

      def var str_p as char.
      def var v_spf1 as integer.
      def var v_spf as char.
      def var i-ind as integer.


def var m-diff  like aal.amt   no-undo.

def var m-amtd  like aal.amt   no-undo.
def var m-amtk  like aal.amt   no-undo.
def var m-att as log format "***/   " no-undo.

def temp-table cashf
    field crc like crc.crc
    field dam like glbal.dam
    field cam like glbal.cam.

for each crc where crc.sts <> 9 no-lock:
    create cashf.
    cashf.crc = crc.crc.
    cashf.dam = 0.
    cashf.cam = 0.
end.



      define frame frame1  
      date1 label  "Дата с "  format "99/99/99" 
      date2 label  "по "  format "99/99/99" 




      v_spf label  "Выберите наименование "  format "x(30)"
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





      update date1 date2 v_spf with frame frame1 side-labels centered row 9.  

      find last  depaccnt where depaccnt.depart = v_spf1 exclusive-lock no-error.







      find last sysc where sysc.sysc = "idate" no-lock no-error.

      if date(date1) < date(sysc.chval) then do:
         message "Дата должна быль больше даты в ФП" view-as alert-box question buttons ok title "" .
         return.
      end.

      if (date(date2) < date(date1)) or (date1 = "") or (date2 = "") then do:
         message "Неверная дата " view-as alert-box question buttons ok title "" .
       return. 
      end.

find last ofc where ofc.ofc = n-ofc no-lock no-error.

f_name = string(g-today) +  ".txt".


output to tt.tmp.

put unformatted  g-today  ", "  string(time,"hh:mm:ss")  ", г.Алматы \r\n"  .
/*put unformatted  "Исполнитель: " + ofc.name  + "\r\n \r\n". */
put unformatted  "Исполнитель: Налоговый инспектор" + "\r\n \r\n".


put unformatted  "                            ФИСКАЛЬНЫЙ ОТЧЕТ \r\n " .
put unformatted  "                         С "  date1 format '99/99/99'  " по "  date2 format '99/99/99'  " \r\n".

put unformatted  "------------------------------------------------------------------------------------------------------------------------------------------------------------------------ \r\n" .
put unformatted  "Номер/док           Сумма Дебет               Сумма Кредит            Комиссия                         Всего      \r\n" .
put unformatted  "------------------------------------------------------------------------------------------------------------------------------------------------------------------------ \r\n" .



/*
for each commonpl where commonpl.DATE >= date(date1) and commonpl.DATE <= date(date2):
   put unformatted  " " commonpl.dnum  "              " commonpl.sum  format ">>>>>>9.99" "          " commonpl.comsum format ">>>>>>9.99" 
"                        "
  commonpl.sum + commonpl.comsum format ">>>>>>9.99" skip.
            ACCUMULATE commonpl.comsum (TOTAL).
            ACCUMULATE sum (TOTAL COUNT).
end.
  */




find sysc where sysc.sysc = "CASHGL" no-lock no-error.
if available sysc then do:
   m-cashgl = inval.
   m-firstout = no.





   
      for each jl  where jl.jdt >= date(date1) and jl.jdt <= date(date2) and jl.who = n-ofc no-lock  break by jl.crc by jl.jh by jl.ln :

         if get-dep (jl.who, jl.jdt) <> v_spf1 then next.

          ni = 1.
   	  if first-of(jl.crc) then do:
	     find crc where crc.crc = jl.crc no-lock no-error.
	     m-sumd = 0.
	     m-sumk = 0.
 	     m-first = false.
 	  end.


          if jl.gl = m-cashgl then do:
             find jh where jh.jh = jl.jh no-lock no-error.
             if available jh and jh.sts = 6 then do:
                m-aah = jl.jh.
		m-who = jl.who.
		m-ln = jl.ln.
		m-amtd = 0.
		m-amtk = 0.
		if jl.dc eq "D" then do:
		    m-amtd = jl.dam.
		    m-sumd = m-sumd + m-amtd.
		end.
		else do:
		    m-amtk = jl.cam.
		    m-sumk = m-sumk + m-amtk.
		end.

	        if not m-first then do:
		   m-first = true.
		end.
		m-att =  jh.sts < 6 .

/* display m-aah m-who m-ln m-amtd m-amtk jl.teller jh.sts m-att with width 130 frame c no-box  no-hide overlay. */
 put unformatted "  "  m-aah  format 'zzzzzz9' "              " m-amtd format 'zzz,zzz,zzz,zz9.99'   "            " m-amtk   format 'zzz,zzz,zzz,zz9.99' "                                         "  m-amtd + m-amtk  format 'zzz,zzz,zzz,zz9.99'  "\r\n".
	     end.
	 end.





         if last-of(jl.crc) and m-first then do:

/*             m-sumd = m-sumd + m-amtd. 
             m-sumk = m-sumk + m-amtk. */
    	     m-diff = m-sumd - m-sumk.
   


put unformatted  "------------------------------------------------------------------------------------------------------------------------------------------------------------------------ \r\n" .
put unformatted  "Итого              "  m-sumd   format 'zzz,zzz,zzz,zz9.99' "               "  m-sumk  format 'zzz,zzz,zzz,zz9.99' "                             "  "\r\n".
put unformatted  "------------------------------------------------------------------------------------------------------------------------------------------------------------------------ \r\n" .





	end.
    end.
end.


if ni = 0 then do: 
 put unformatted  "------------------------------------------------------------------------------------------------------------------------------------------------------------------------ \r\n" .
 put unformatted  "Итого              "  m-sumd   format 'zzz,zzz,zzz,zz9.99' "               "  m-sumk  format 'zzz,zzz,zzz,zz9.99' "                             "  "\r\n".
 put unformatted  "------------------------------------------------------------------------------------------------------------------------------------------------------------------------ \r\n" .
end.














































/*
put unformatted  "------------------------------------------------------------------------------------------------------------------------------------------------------------------------ \r\n" .
put unformatted  "Итого              "  accum total commonpl.sum    "               "  (accum total commonpl.comsum) "                             "  (accum total commonpl.sum)  +  (accum total commonpl.comsum) "\r\n".
put unformatted  "------------------------------------------------------------------------------------------------------------------------------------------------------------------------ \r\n" .
*/


output close.







  input through  value("ssh Administrator@`askhost`" + " del"  +  " c:\\\\OUT\\\\*.* /Q  ; echo $? ; ").  

  unix silent value('un-win tt.tmp t.tmp'). 


   input through  value("scp -q t.tmp Administrator@`askhost`:C:/OUT/" +  ";echo $?" ).
   input through  value("ssh Administrator@`askhost`" + " mkdir"  +  " c:\\\\tmp ; echo $? ; "). 




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
    input through  value("ssh Administrator@`askhost` " + ns_check("C:/Program Files/GammaTech/TumarCSP/cptumar.exe ") + "' -crp fin=c:/OUT/t.tmp fout=c:/OUT/" + replace(date1, "/", "." ) +  ".crp fopn=c:/tmp/open_key1.bin fses=c:/OUT/ses_key.bin'").
    input through  value("ssh Administrator@`askhost`" + " del"  +  " c:\\\\OUT\\\\t.tmp ; echo $? ; "). 
































/*

          input through  value("ssh Administrator@`askhost`" + " mkdir"  +  " c:\\\\OUT ; echo $? ; "). 



   unix silent  value("ssh Administrator@`askhost`" + " mkdir"  +  " c:\\\\OUTT").
   unix silent value("scp -q " +  f_name + " Administrator@`askhost`:C:/OUT/" +  ";echo $?" ).  
   unix silent value("scp -q t.tmp Administrator@`askhost`:C:/OUT/" + " ;echo $?" ).





   input through  value("ssh Administrator@`askhost`" + " del"  +  " c:\\\\OUT\\\\*.* /Q  ; echo $? ; ").  
   input through  value("scp -q t.tmp Administrator@`askhost`:C:/OUT/" +  ";echo $?" ).
   input through  value("ssh Administrator@`askhost`" + " mkdir"  +  " c:\\\\tmp ; echo $? ; "). 
   input through  value("scp -q /data/9/export/open_key1.bin Administrator@`askhost`:C:/tmp/" +  ";echo $?" ).


 
function ns_check returns character (input parm as character).
    def var v-str as char no-undo.
    v-str = parm.
    v-str = replace(v-str,"/","//").
    v-str = replace(v-str,"!","\\!").
    v-str = replace(v-str," ","\\ ").
    v-str = "\\""" + v-str + "\\""".
    return (v-str).
end function.



    input through  value("ssh Administrator@`askhost` " + ns_check("C:/Program Files/GammaTech/TumarCSP/cptumar.exe ") + "' -crp fin=c:/OUT/t.tmp fout=c:/OUT/" + replace(date1, "/", "." ) +  ".crp fopn=c:/tmp/open_key1.bin fses=c:/OUT/ses_key.bin'").
    input through  value("ssh Administrator@`askhost`" + " del"  +  " c:\\\\OUT\\\\t.tmp ; echo $? ; "). 


    unix silent  value("ssh Administrator@`askhost`:" + ns_check("C:/Program Files/GammaTech/TumarCSP/dddw.txt")  +  ";echo $?"). 
    unix silent value("scp -q t.tmp Administrator@`askhost`:" +  \C://aaa\ ddd\ +  ";echo $?" ). 
   unix silent value("scp -q t.tmp Administrator@`askhost`:" + ns_check("C:/aaa ddd")+   ";echo $?" ). 
   unix silent value("scp -q t.tmp Administrator@`askhost`:C://aaa\ ddd//" +  ";echo $?" ).




  unix silent  value("ssh Administrator@`askhost`" + ":'C:/Program Files/GammaTech/TumarCSP/cptumar' -crp fin=c:/a/old.txt fout=c:/a/new.txt fopn=c:/a/open_key1.bin fses=c:/a/ses_key.bin").



 работает  unix silent  value("ssh Administrator@`askhost` " + ns_check("C:/Program Files/GammaTech/TumarCSP/cptumar.exe ") + "' -crp fin=c:/a/old.txt fout=c:/a/new.txt fopn=c:/a/open_key1.bin fses=c:/a/ses_key.bin'"). 



*/