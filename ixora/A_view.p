/* A_view.p
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
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
       18.12.2005 tsoy     - добавил время создания платежа.
*/

def shared var m-sqn as char .
def temp-table b-remtrz  like remtrz . 
def var tra as char.
def var v-field as cha .
def var v-sender like remtrz.sbank .
def var v-sqn like remtrz.sqn  .

 if m-sqn ne "" then do:
  tra = m-sqn.
  display "W A I T " with centered frame www1 . pause 0 .
  
 input through value("larc -F s -s " + string(tra) ) . 
 import v-field .


repeat :
 import v-field .
 if v-field = ":C5:" then leave .
end .
if v-field ne ":C5:"
 then do:
  return .
 end.
  for each b-remtrz. 
   delete b-remtrz . 
  end . 
  
  import v-sender v-sqn .
  create b-remtrz . 
       b-remtrz.rtim = time.
  import b-remtrz .   
  input close . 
  hide frame www1 . 

  find first crc where crc.crc = b-remtrz.tcrc no-lock.

        display  /* "Klients:" substring(v-sender,9)   */
        "Dok.:" substr(b-remtrz.sqn,19)
       "Datums:" b-remtrz.rdt
        "Valdt:" b-remtrz.valdt2
        skip
        "Summa:" b-remtrz.payment crc.code 
         skip                                  
         "50"
"52 " at 40 /* v-F52 format "x(1)" at 42 */ 
b-remtrz.ordinsact at 46 format "x(35)" skip
b-remtrz.ordcst[1] at 5 format "x(35)" 
b-remtrz.ordins[1] at 46 format "x(35)" skip
b-remtrz.ordcst[2] at 5 format "x(35)" 
b-remtrz.ordins[2] at 46 format "x(35)" skip
b-remtrz.ordcst[3] at 5 format "x(35)" 
b-remtrz.ordins[3] at 46 format "x(35)" skip
b-remtrz.ordcst[4] at 5 format "x(35)" 
b-remtrz.ordins[4] at 46 format "x(35)" skip
"59" b-remtrz.racc at 5 format "x(35)"           
"57 " at 40 b-remtrz.rbank at 46 format "x(35)" skip
b-remtrz.bn[1] at 5 format "x(35)" b-remtrz.actins[1] at 46 format "x(35)" skip
b-remtrz.bn[2]  at 5 format "x(35)" b-remtrz.actins[2] at 46 format "x(35)" skip
substr(b-remtrz.bn[3],1,35) at 5 format "x(35)" 
b-remtrz.actins[3] at 46 format "x(35)" skip
substr(b-remtrz.bn[3],36) format "x(35)" 
b-remtrz.actins[4] at 46 format "x(35)" skip         
"70" b-remtrz.detpay[1] at 5 format "x(35)"
"72" at 40
b-remtrz.rcvinfo[1] at 46 format "x(35)" skip
b-remtrz.detpay[2] at 5 format "x(35)" 
b-remtrz.rcvinfo[2] at 46 format "x(35)" skip
b-remtrz.detpay[3] at 5 format "x(35)" 
b-remtrz.rcvinfo[3] at 46 format "x(35)" skip
b-remtrz.detpay[4] at 5 format "x(35)" 
b-remtrz.rcvinfo[4] at 46 format "x(35)" skip
"71 " 
b-remtrz.bi  format "x(35)" skip
WITH overlay frame b no-box no-label no-underline.
pause . 
   end.
  


