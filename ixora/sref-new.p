/* ref-new.p
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
{global.i}

def  shared var s-referid like sthead.referid.
def  shared var v-dt like sthead.rptto.
def  shared var v-gldate as date.
def  shared var v-frm as char.
s-referid = 0.

def var j as  integer no-undo.
def var v-num like sthead.referid no-undo.
def var v-rptdir as char no-undo.
def var v-tailstm as char no-undo.
def var v-name as char no-undo.
def var v-strep as char no-undo.

/*find sysc where sysc.sysc eq "rptdir" no-lock no-error.
if available sysc then v-rptdir = sysc.chval.
else v-rptdir = "./".

v-rptdir = '/home/u00119/stat/'.

find sysc where sysc.sysc eq "strep" no-lock no-error.
if available sysc then v-strep = sysc.chval.
else v-strep = "./".

find sysc where sysc.sysc eq "sttail" no-lock no-error.
if available sysc then v-tailstm  = sysc.chval.
else v-tailstm = "/usr/bin/tail +2l".

  */

    do transaction :
       /* repeat :*/
            find sysc where sysc.sysc eq "NXTREF" exclusive-lock.
            v-num = sysc.inval.
            find sthead where sthead.referid eq v-num no-lock no-error.
            if available sthead then  return. 
            else do:
             sysc.inval = sysc.inval + 1.  
             create sthead.
             sthead.referid = v-num.
             sthead.whn = g-today.
             sthead.who = 'bankadm'.
            /* sthead.rem = string(v-num,"99999999").*/
             sthead.rptfrom = v-gldate.
             sthead.rptto = v-gldate.
             sthead.rptform = v-frm.
             sthead.rdy = yes.
             s-referid = v-num.
          end.
    end.





