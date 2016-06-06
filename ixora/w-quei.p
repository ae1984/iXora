/* w-quei.p
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

def buffer tgl for gl.
def var acode like crc.code.
def var bcode like crc.code.
def var oldpid like que.pid .
def var prilist as cha.
def var oldpri like que.pri.
def var newpri like que.pri.
def var  o-priory as cha.
def shared var v-pnp as cha format "x(10)".
def shared var v-reg5 as char format "x(13)".
def shared var v-chg as integer.
def  var ootchoice as char extent 3 format "x(8)" initial
     [" normal ",
      " urgent ",
      " express"].



def shared frame remtrz.

{global.i}
{ps-prmt.i}
{lgps.i} 
{rmzi.f}   

def shared var s-remtrz like que.remtrz.

find first que where que.remtrz = s-remtrz no-lock .



if  (m_pid = "ps_" or m_pid = "I" or m_pid = "3"
 or  m_pid  = "O" or substr(m_pid,1,1) =  "P") and que.con = "W" then
do transaction :
 find first que where que.remtrz = s-remtrz exclusive-lock .
 oldpri = que.pri.
 
 find sysc where sysc.sysc = "PRI_PS" no-lock no-error .
 if not avail sysc or sysc.chval = "" then do:
 display "Отсутствует запись PRI_PS в таблице SYSC!".
 pause .
 release que.
 undo , return .
 end.
 prilist = sysc.chval.
 o-priory = entry(3 - int(que.pri / 10000 - 0.5 ) ,prilist).

 ootchoice[1] = entry(1,prilist) .
 ootchoice[2] = entry(2,prilist) .
 ootchoice[3] = entry(3,prilist) .

  form ootchoice
  with overlay row 17 1 col columns  57 no-labels
  frame ootfr.
  display ootchoice with frame ootfr.
  choose field ootchoice AUTO-RETURN with frame ootfr.

 if FRAME-INDEX eq 1 then do:
  newpri  = 29999.

  v-priory = ootchoice[1].
  end.
 if FRAME-INDEX eq 2 then do:
  newpri  = 19999.
  v-priory = ootchoice[2].
  end.
 if FRAME-INDEX eq 3 then do: 
  newpri  = 09999.
  v-priory = ootchoice[3].
  end.
  
  que.pri =  newpri.
    
    v-text = s-remtrz + " Изменен приоритет : " +  string(oldpri)
     + "(" + o-priory + ")" + "-> " +
    string(newpri) + "(" + v-priory + ")" .
    run lgps.
/*    que.df = today .
    que.tf = time .
  */

display v-priory with frame remtrz .
pause 0 .
release que .
end.
hide message.

