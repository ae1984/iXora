/* get_cur_bal.p
 * MODULE
       Карточный модуль
 * DESCRIPTION
      получить остаток
 * RUN

 * CALLER
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
 * MENU

 * AUTHOR
        31.05.2005 tsoy 
 * CHANGES
        20.10.2006 tsoy NTORACLE
*/


def input parameter p-num        as char.

def output parameter p-bal       as deci.
def output parameter p-lock      as deci.
def output parameter p-use-limit as deci.
def output parameter p-limit     as deci.

def var  v-fname as char.
def var  v-fnum as char.
def var  v-cmd as char.
def var  v-s as char.

define stream m-in.
           
     v-fname = string ( next-value (mt100seq)).
     v-fnum  = p-num.

     v-cmd   = "abnquery.bat  2 " + v-fname + " " + v-fnum.

     input through value("rsh NTORACLE C:\\\\ABN\\\\" + v-cmd).
     repeat:
           import v-s.
     end.
    
     input through value ("rcp NTORACLE:C:\\\\ABN\\\\" + v-fname + ".lst /tmp/" + v-fname + "; echo $?").
     repeat:
           import v-s.
     end.

     input stream m-in from value("/tmp/" + v-fname).
     repeat:

           import stream m-in unformatted v-s.

           p-bal        = deci(entry (1, v-s, "|")) no-error.
           p-lock       = deci(entry (2, v-s, "|")) no-error.
           p-use-limit  = deci(entry (3, v-s, "|")) no-error.
           p-limit      = deci(entry (4, v-s, "|")) no-error.

     end. 
     
     input through value ("rm /tmp/" + v-fname).
     repeat:
           import v-s.
     end.

