/* quest.p
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
*/

def new shared var v-hst as cha .
def var v-sss as cha . 
def var v-s as cha .
def new shared var v-log as cha .
def var s-remtrz like remtrz.remtrz . 
def var df as date label "Начало периода" . 
def var dt as date label "Конец  периода" .
def var dfi  as date .
def var patt1 as cha format "x(20)" label "1 образец" .
def var patt2 as cha format "x(20)" label "2 образец" .
def var patt3 as cha format "x(20)" label "3 образец" .
def var patt4 as cha format "x(20)" label "4 образец" .
def var patt5 as cha format "x(20)" label "5 образец" .
def var comm as cha format "x(20)"  label " Команда печати ? " .
def stream ttt . 
def stream www . 

find sysc where sysc.sysc = "ourbnk" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 message " Нет записи OURBNK в sysc файле !".
 pause .
 return .
end.

comm = "ps_lessh " .
v-hst = trim(sysc.chval).

find sysc where sysc.sysc = "PS_LOG" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 message " Нет записи PS_LOG в sysc файле !".
 pause .
 return .
end.

v-log = trim(sysc.chval).
df = today . 
dt = today . 
s-remtrz = "" . 
repeat :
output close . 
update df dt 
       patt1 patt2 patt3 patt4
       patt5 comm
       with centered side-label 1 column row 5 frame qq .

       patt1 = patt1.
       patt2 = patt2.
       patt3 = patt3.
       patt4 = patt4.
       patt5 = patt5.

       dfi = df . 
       if search("./tmp.awk") = "./tmp.awk" then 
          unix silent value("rm tmp.awk") .  
        output stream www to  "./tmp.awk" .
    repeat :
     if dfi > dt then leave .
      if  search(v-log + trim(v-hst) + "_logfile.lg." +
              string(dfi,"99.99.9999")) =
              v-log + trim(v-hst) + "_logfile.lg." +
       string(dfi,"99.99.9999") then
       do: input stream ttt from  value(v-log + trim(v-hst) + "_logfile.lg." +
            string(dfi,"99.99.9999")). 
        repeat: 
         import stream ttt unformatted v-sss  .
         if 
          ( index(v-sss,patt1) ne 0 or length(patt1) = 0 ) and
          ( index(v-sss,patt2) ne 0 or length(patt2) = 0 ) and
          ( index(v-sss,patt3) ne 0 or length(patt3) = 0 ) and
          ( index(v-sss,patt4) ne 0 or length(patt4) = 0 ) and
          ( index(v-sss,patt5) ne 0 or length(patt5) = 0 )  
          then put stream www unformatted v-sss skip .
        end.                                 
       input stream ttt close .
       end.
       dfi = dfi + 1 .
   display " Ждите... " dfi with centered frame qq1 no-label . pause 0 . 
  end .
  output stream www close . 
  input stream ttt close .
           if search("./tmp.awk") = "./tmp.awk" then do:
           unix  value ( comm + " tmp.awk" )  .
           unix silent value("rm tmp.awk") .        end . 
           pause 0 .
end .
