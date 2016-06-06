/* crearpz.p
 * MODULE
        Платежная система
 * DESCRIPTION
	Создание и отправка платежей по ЗП проектам Народного банка
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        3-outg.p
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        02/10/2006 tsoy
 * CHANGES 
        17/11/2006 tsoy  ограничение 70 символов на поле ASSIGN, а также двоиные фамилии типа XXX улы
*/

{yes-no.i}

hide all no-pause.
def shared var s-remtrz like remtrz.remtrz.
def var pathname as char init 'C:\\RZP\\'.

def  var v-5 as char.

def var v-is-halyk as logi.
def var v-clecod as cha. 
def buffer t-bankl for bankl.

def var v-unicode as char.


def var v-dt  as char.
def var ii  as int.

def var logic as logic init false.

def var s  as char init ''.
def var str  as char init ''.

def var  v-assign as char extent 4.
def var  v-ass as char.

def var  v-err as logi.

def var i as integer.
def var j as integer.

def var  v-str as char.

define stream err-out.
output stream err-out to value (s-remtrz + ".err").

define stream swt-out.

def var cnt      as integer.

def var f_total  as deci.
def var v_amt  as deci.

def var v-irs  as char.
def var v-seco as char.

def var v-sirs  as char.
def var v-sseco as char.

def var v-knp as char init ''.
def var v-pr as log init 'true'.

       def var v-chief as char init "НЕ ПРЕДУСМОТРЕНО".
       def var v-mainbk as char init "НЕ ПРЕДУСМОТРЕНО".
       def var v-rnn as char.
       def var v-rnnben as char.
       def var v-sub as int.
       def var v-sname as char.

def temp-table tf 
    field filename as char format "x(25)" .

def temp-table tmp
           field card    as char format "x(18)"  /* N карт */
           field sum1    like jl.dam             /* Сумма из списка */
           field fm  as char
           field nm  as char           
           field ft  as char           
           field rnn as char.


define button bimport  label "Импорт из файла".
define button bruch   label  "Ручной ввод".

def frame f1 
   bimport 
   bruch     
with centered row 3.

def frame f2 
    i label "Количество записей" 
with centered row 3 side-labels.


def frame f3                 
    j         label "Запись  "  skip
    tmp.sum1  label "Сумма   "  format ">>>>>>>>9.99"  skip
    tmp.fm    label "Фамилия "  format "x(25)"           skip
    tmp.nm    label "Имя     "  format "x(25)"           skip
    tmp.ft    label "Отчество"  format "x(25)"           skip                
    tmp.rnn   label "РНН     "  format "x(25)"           skip                
    tmp.card  label "N Карты "  format "x(25)"           skip
with centered row 3 side-labels.

def frame f4 
    v-unicode label "UNICODE" format "x(16)"  skip
with centered row 3 side-labels.

def var v-com     as deci.
def var v-comcod  as char.
def frame fcom 
     v-com     label "Комиссия " format ">>>>>>>>9.99"  skip
     v-comcod  label "Код Комиссии " format "x(16)"  skip
with centered row 3 side-labels.

define query q1 for tf.
def var fname as char init ''.

def browse b1 
    query q1 no-lock
    display 
        tf.filename  label " Файл "       format "x(23)"
        with 14 down .

def frame fr1 
    b1
with centered overlay view-as dialog-box title " Файлы доступные для импорта ".

procedure cr_remtrz.

       def input parameter ptype as integer.

       v-err = false.


       output stream swt-out to value (CAPS(s-remtrz)).

       find remtrz where remtrz.remtrz =  s-remtrz no-lock no-error.
       if avail remtrz  then do:

           find aaa where aaa.aaa =  remtrz.sacc no-lock no-error.
           if avail aaa then do:
                   find cif where  cif.cif = aaa.cif no-lock no-error.
           end.
       end.

       v-sub = index (remtrz.ord, "/RNN/", 1).
       if v-sub > 0 then do:
          v-rnn = substr(remtrz.ord, index(remtrz.ord,"/RNN/") + 5, 12).
          v-sname = substr(remtrz.ord, 1, (v-sub - 1)). 
       end.
       else do:
         v-rnn = "".
         v-sname = remtrz.ord.
       end.

       v-sub = index (remtrz.bn[3], "/RNN/", 1).
       if v-sub > 0 then do:
          v-rnnben = substr(remtrz.bn[3], index(remtrz.bn[3],"/RNN/") + 5, 12).
       end.


       find first aaa where aaa.aaa = remtrz.sacc no-lock no-error.
       if avail aaa then do:
           
           find first sub-cod where sub-cod.sub = "cln"
                                     and sub-cod.acc = aaa.cif
                                     and sub-cod.d-cod = "clnchf" no-lock no-error.
           
           if avail sub-cod and sub-cod.ccode ne "msc" then v-chief = trim(sub-cod.rcode).

           find first sub-cod where sub-cod.sub = "cln"
                                     and sub-cod.acc = aaa.cif
                                     and sub-cod.d-cod = "clnbk" no-lock no-error.
           if avail sub-cod and sub-cod.ccode ne "msc" then v-mainbk = trim(sub-cod.rcode).

       end. 

       find remtrz where remtrz.remtrz =  s-remtrz no-lock no-error.
       if avail remtrz  then do:

           find aaa where  aaa.aaa =  remtrz.sacc no-lock no-error.
           if avail aaa then do:
                   find cif where  cif.cif = aaa.cif no-lock no-error.
           end.
       end.

      find first sub-cod where sub-cod.d-cod = "eknp" and sub-cod.acc = remtrz.remtrz and sub-cod.sub = "rmz" no-lock no-error.
      if avail sub-cod and sub-cod.rcod ne '' and sub-cod.rcod matches "*,*,*" then do :
          v-irs  = substr(entry(1,sub-cod.rcod,","),1,1) .
          v-seco = substr(entry(1,sub-cod.rcod,","),2,1) .
      end.




      find sub-cod where sub-cod.acc = cif.cif and sub-cod.sub = "cln" and sub-cod.d-cod = "secek" no-lock no-error.
      
      if avail sub-cod and sub-cod.ccode ne "msc" then v-sseco = sub-cod.ccode.

     if substr(cif.geo, 3, 1) = "1" then v-sirs = "1". else v-sirs = "2".

      /* контроль на заполнение кода ЕКНП */
      find sub-cod where sub-cod.acc = s-remtrz
                         and sub-cod.sub = 'rmz'
                         and sub-cod.d-cod = 'eknp'
                         and sub-cod.ccode = 'eknp'
                         and sub-cod.rcode ne ' ' no-lock no-error.
           if not avail sub-cod then v-pr = false.
           else
              if (entry(1,sub-cod.rcode,',') eq ''
              or entry(2,sub-cod.rcode,',') eq ''
              or entry(3,sub-cod.rcode,',') eq '') then v-pr = false.
           if not v-pr then do:
              message "Необходимо проставить коды ЕКНП (см.опцию 'Справочник')!".
              pause.
              return.
            end.

            v-knp = entry(3, sub-cod.rcode, ',').
     /*
     do i = 1 to 4 :
       
       v-assign[i] = trim(remtrz.detpay[i]) .

       do while  v-assign[i] begins "-" or v-assign[i] begins ":" or v-assign[i] begins " " :
         substr(v-assign[i],1,1)  = "".
         if v-assign[i] = "" then leave .
       end.

       if v-assign[1] <> "" then v-ass = v-ass + v-assign[1] + chr(10) .
       if v-assign[2] <> "" then v-ass = v-ass + v-assign[2] + chr(10) .
       if v-assign[3] <> "" then v-ass = v-ass + v-assign[3] + chr(10) .


     end.
     
    */

     do ii = 1 to 4:
     	v-ass = v-ass + trim(remtrz.detpay[ii]).
     end.
     if v-ass <> "" then 
     do:
     	if length (v-ass) > 62 then 
     	do:
     		if length (v-ass) > 132 then 
     		do:
     			if length (v-ass) > 202 then 
     			do:
     				if length (v-ass) > 272 then 
     				do:
     					if length (v-ass) > 342 then 
     					do:
     						if length (v-ass) > 412 then
     							v-dt = v-dt + substring (v-ass,1,62) 
                                                                         + chr(10) + substring (v-ass,63,70) 
                                                                         + chr(10) + substring (v-ass,133,70) 
                                                                         + chr(10) + substring (v-ass,203,70) 
                                                                         + chr(10) + substring (v-ass,273,70) 
                                                                         + chr(10) + substring (v-ass,343,70) .
     						else 
     							v-dt = v-dt + substring (v-ass,1,62) 
                                                                         + chr(10) + substring (v-ass,63,70) 
                                                                         + chr(10) + substring (v-ass,133,70) 
                                                                         + chr(10) + substring (v-ass,203,70) 
                                                                         + chr(10) + substring (v-ass,273,70) 
                                                                         + chr(10) + substring (v-ass,343).
     					end.
     					else 
     						v-dt = v-dt + substring (v-ass,1,62) 
                                                                 + chr(10) + substring (v-ass,63,70) 
                                                                 + chr(10) + substring (v-ass,133,70) 
                                                                 + chr(10) + substring (v-ass,203,70) 
                                                                 + chr(10) + substring (v-ass,273).
     				end.
     				else 
     					v-dt = v-dt + substring (v-ass,1,62) 
                                                         + chr(10) + substring (v-ass,63,70) 
                                                         + chr(10) + substring (v-ass,133,70) 
                                                         + chr(10) + substring (v-ass,202).
     			end.
     			else 
     				v-dt = v-dt + substring (v-ass,1,62) 
                                                 + chr(10) + substring (v-ass,63,70) 
                                                 + chr(10) + substring (v-ass,133).
     		end.
     		else 
     			v-dt = v-dt + substring (v-ass,1,62) + chr(10) + substring (v-ass,63).
     	end.
     	else 
     		v-dt = v-dt + v-ass .
      end.


     v-is-halyk = false.

     find  bankl where bankl.bank = remtrz.rbank no-lock no-error.
     if avail bankl then  do:

         if bankl.bank = "190501601" then v-is-halyk = true.

     end.

     if v-is-halyk then do:
    
         update v-unicode with frame f4.
         
         if v-unicode <> "" then  v-ass = v-ass + "UNICODE  " + v-unicode + chr(10) .
         if v-unicode <> "" then  remtrz.detpay[4] = remtrz.detpay[4] + "UNICODE  " + v-unicode.

     end.

     find first t-bankl where t-bankl.bank = remtrz.sbank no-lock no-error.

     find first bankt where bankt.cbank = remtrz.sbank and bankt.crc = remtrz.tcrc no-lock no-error.

     find first sysc where sysc.sysc = "clecod" no-lock no-error.
     if  avail sysc then do :
        v-clecod = trim(sysc.chval).
     end.


     put stream swt-out unformatted 
              "\{1:F01K059140000000001000001\}" chr(10)  
              "\{2:I102SGROSS000000U3003\}" chr(10)  
              "\{4:" chr(10)  
              ":20:"            s-remtrz chr(10)  
              ":50:/D/"         remtrz.sacc chr(10)  
              "/RNN/"           cif.jss chr(10)  
              "/NAME/"          cif.prefix + " " + cif.name chr(10)  
              "/CHIEF/"         v-chief chr(10)  
              "/MAINBK/"        v-mainbk chr(10)  
              "/IRS/"           v-irs chr(10)  
              "/SECO/"          v-seco chr(10)  .
              
            if remtrz.sbank begins "TXB" and remtrz.sbank <> "TXB00" then do:
       
               put stream swt-out unformatted 
                  ":52B:" + t-bankl.crbank + chr(10) +
                  ":53C:190501914/" + bankt.acc + chr(10).
            end. else do:

               put stream swt-out unformatted 
                  (":52B:" + trim(v-clecod) + chr(10) +
                   if remtrz.sbank <> remtrz.scbank then ":53C:" + trim(remtrz.scbank) + chr(10) else "")
                   if remtrz.rbank <> remtrz.rcbank then ":54B:" + trim(remtrz.rcbank)  + chr(10) else "".
            end.
               
            put stream swt-out unformatted 
              ":57B:" + trim(remtrz.rbank) + chr(10)  
              ":59:"            remtrz.ba chr(10)  
              "/RNN/"           v-rnnben chr(10)  
              "/NAME/"          remtrz.bn[1] chr(10)  
              "/IRS/1"                       chr(10)  
              "/SECO/4"                      chr(10)  
              ":70:/NUM/"        substr(remtrz.sqn,19) + chr(10)  
              "/DATE/"          substr(string(year(today)),3,2) string(month(today),"99") + string(day(today),"99") chr(10)   
              "/VO/01"          chr(10)  
              "/SEND/07"        chr(10)  
              "/KNP/"           v-knp chr(10)  
              "/PSO/01" + chr(10) + 
              "/PRT/50" + chr(10) +
              "/ASSIGN/"        v-dt + chr(10).

              i = 1.

              for each tmp.

              v_amt = v_amt + tmp.sum1. 

              if tmp.ft = "-" then tmp.ft = "".

              put stream swt-out unformatted ":21:"   + string (i) + chr(10)  
                              ":32B:KZT"  + replace(trim(string(tmp.sum1, ">>>>>>>>>>>>>>>>>.99")), ".", ",") + chr(10)  
                              ":70:"   + chr(10)  
                              "/FM/"   + tmp.fm   + chr(10)  
                              "/NM/"   + tmp.nm   + chr(10)  
                              "/FT/"   + tmp.ft   + chr(10)  
                              "/RNN/"  + tmp.rnn  + chr(10)  
                              "/LA/"   + tmp.card + chr(10) . 

                   i = i + 1.

              end.

              if v-is-halyk then do:

                       v-comcod = v-unicode. 
      		       update v-com v-comcod with frame fcom.

                       put stream swt-out unformatted ":21:"   + string (i) + chr(10)  
                                       ":32B:KZT"  + replace(trim(string(v-com, ">>>>>>>>>>>>>>>>>.99")), ".", ",") + chr(10)  
                                       ":70:"   + chr(10)  
                                       "/FM/"   + "КОМИССИЯ"   + chr(10)  
                                       "/NM/"   + "БАНКА   "   + chr(10)  
                                       "/LA/"   + v-comcod     + chr(10) .
                        v_amt = v_amt + v-com.
       	      end.


              /* Проверка суммы */
              if v_amt <> remtrz.amt then do:
                  put stream err-out unformatted  "Неверная итоговая сумма в списке ! "  string(v_amt) " несоответсвует "  string(remtrz.amt) skip.
                  v-err = true.
              end.

              put stream swt-out unformatted 
              ":32A:"  substr(string(year(today)),3,2) string(month(today),"99") + string(day(today),"99")  + "KZT" + replace(trim(string(remtrz.amt, ">>>>>>>>>>>>>>>>>.99")), ".", ",")  + chr(10)  
              "-\}" .                                                  

      input  close.
      output stream swt-out close.
      output stream err-out close.



      if v-err then do:
           
           message "Ошибки при импорте файла. Показать отчет ? " view-as alert-box question buttons yes-no
           title "Внимание" update logic.

           if logic then do:
                 run menu-prt (s-remtrz + ".err").
           end.

      end.

      unix silent value("rm /tmp/" + s-remtrz ).
      unix silent value("cp -f " + s-remtrz + " " +  "/tmp/" + s-remtrz ).

/*     
      find sysc where sysc.sysc = "psjarc" no-lock no-error .
      unix silent value("cp -f /tmp/" + s-remtrz + " " +  sysc.chval + s-remtrz + "PPrzp" ).
*/
      find sysc where sysc.sysc = "PSJIN" no-lock no-error .

      unix silent value("rm " + sysc.chval + s-remtrz ).
      unix silent value("cp -f /tmp/" + s-remtrz + " " +  sysc.chval + s-remtrz).




end.

procedure load_file.

         update pathname format "x(40)" label "Введите полный путь к файлам" with side-labels centered frame pname.

               hide frame pname.
               pathname = caps(trim(pathname)).

         do trans:

             input through value("rsh `askhost` dir /b '" + pathname + "*.txt '") no-echo.
             repeat:

               import unformatted s.

               if substr(caps(s),1,10) = 'THE SYSTEM' then do: 
                  MESSAGE "Указан неверный путь к файлам: ~n" + pathname
                  VIEW-AS ALERT-BOX INFORMATION BUTTONS ok TITLE " Внимание " .
                  undo, return. 
               end.

               create tf.
                      tf.filename = s .

             end.
               input close.
         end.

         open query q1 for each tf.

         if num-results("q1")=0 then do:
             message "В каталоге " + pathname + " файлы не найдены."
             view-as alert-box information buttons ok title " Внимание " .
             return.                 
         end.

         enable all with frame fr1 .
         wait-for endkey of frame fr1 .
         hide frame fr1 .

end.

on return of b1 in frame fr1 do:

       MESSAGE "Вы действительно хотите импортировать файл Tsalary ~n " + pathname + caps(trim(tf.filename)) + " в Pragma ?~n"
       VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
       TITLE "Внимание" UPDATE logic.
       case logic:
            when false then return.
       end.        

       assign
           fname = caps(trim(tf.filename)).

      unix silent value('rcp `askhost`:' + replace(pathname + fname,'\\','\\\\') + ' ./').

     /* unix silent value ("dos-un " + fname + " " + fname + ".tmp" ). */
   unix silent value ("dos-un " + fname + " " + fname + ".tmp" ). 

     /* unix silent value("cat " + fname + "| win2koi > " + fname + ".tmp").*/

      unix silent value ("rm " + fname).
      unix silent value ("mv " +  fname + ".tmp" + " " + fname).

       /* обработка строк файла Tsalary*/

       i =  1 .
       input from value (fname).
       repeat:

           import unformatted str no-error.
           
           cnt = cnt + 1.
                 if substring (str, 1, 2) = "BT" then  /* итоговая сумма */
           do:
              f_total = decimal (trim(substr(str, 9))).
              leave.
           end.



           if cnt > 4 then do:
              
              /* создать новую запись */

              create tmp.
              
              assign tmp.card = trim (substr (str, 1, 19))
                     tmp.sum1 = decimal (replace(trim(substr (str, 20, 14)), ",", "." )).

                     v-str   = substr (str, 34).

                     /* специально для тех у кого фамилия типа "Далелхан улы" */
                     if NUM-ENTRIES  (v-str, " ") = 5 then do:

                         tmp.fm  = entry(4, v-str, " ").
                         tmp.nm  = entry(1, v-str, " ").
                         tmp.ft  = entry(2, v-str, " ") + " " + entry(3, v-str, " ").
                         tmp.rnn = entry(5, v-str, " ") no-error. 

                     end.
                     else do:

                         tmp.fm  = entry(3, v-str, " ").
                         tmp.nm  = entry(1, v-str, " ").
                         tmp.ft  = entry(2, v-str, " ").

                         v-5 = "".

                         v-5 = entry(5, v-str, " ") no-error.
                         tmp.rnn = entry(4, v-str, " ") no-error. 
                         tmp.rnn = tmp.rnn + v-5. 

                     end.


                     if tmp.card = "" or tmp.fm = ""  or tmp.nm = ""  or tmp.ft = ""  or tmp.rnn = ""  then do:
                         put stream err-out unformatted  "Пустое значение в списке ! элеменент "  string(i) skip.
                         v-err = true.
                     end.

                    i =  i + 1. 

           end.

      end.
      input close.

      unix silent value("rm  " + fname ).

      apply "endkey" to frame fr1.

end.  

on choose of bimport in frame f1 do:
   run load_file.
   run cr_remtrz (input 1).
   apply "enter-menubar" to frame f1.
end.

on choose of bruch in frame f1 do:

     update i with frame f2.

     do j = 1 to i .

       create tmp.
       displ j with frame f3.
       update 
           tmp.sum1  
           tmp.fm    
           tmp.nm    
           tmp.ft                                
           tmp.rnn                               
           tmp.card  
       with frame f3 .

     end.

     run cr_remtrz (input 1).

     apply "enter-menubar" to frame f1.
end.

ENABLE all WITH centered FRAME f1.
WAIT-FOR "enter-menubar" of frame f1.
hide all no-pause.

