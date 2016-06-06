/* tdaintrat.p
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
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
*/

{global.i}
def input parameter s-pri as char.
def var vi as inte.
def var vpri as char.
def shared var head1 as char initial "Срок".
def shared var head11 as char initial "Ступень 1".
def shared var head12 as char initial "Ступень 2".
def shared var head13 as char initial "Ступень 3".
def shared var head14 as char initial "Ступень 4".
def shared var head15 as char initial "Ступень 5".
def shared temp-table gpri 
    field gpri as char
    field name as char
    field itype as inte
    field rate like pri.rate
    field tlimit like pri.tlimit.
def shared temp-table vrate 
    field vterm as inte 
    field rate like pri.rate extent 5.
def shared frame ss.
def shared frame ss1.
find first gpri where gpri.gpri = s-pri.

{jabre.i
   &head = "vrate"
   &headkey = "vterm"
   &where = "true"
   &formname = "tdainttab"
   &framename = "ss"
   &addcon = "true"
   &deletecon = "true"
   &prechoose = "message 'L-Редактировать ступени,Enter-Редактировать строку,Insert-Добавить строку,F10-Удалить строку,F4-Выход'."
   &predisplay = " "
   &display = "vrate.vterm vrate.rate"
   &highlight = "vrate.vterm"
   &postkey = "else if keyfunction(lastkey) = 'RETURN' then do:
                 update vrate.vterm vrate.rate with frame ss.
                 run SaveRates.
               end.
               else if keyfunction(lastkey) = 'L' then do:
                 update gpri.tlimit[1]with frame ss1.
                 update gpri.tlimit[2]with frame ss1. 
                 update gpri.tlimit[3] with frame ss1.
                 update gpri.tlimit[4] with frame ss1.
                 run SaveLimits.
               end.
               "
   &postadd = "update vrate.vterm vrate.rate with frame ss.
               run SaveRates.
              "
   &prevdelete = "for each pri where pri.pri begins '^' + s-pri + string(vrate.vterm,'99'):
                    delete pri.
                 end.
                "           
   &end = "hide frame ss.
           hide frame ss1.
           hide frame ss2.
          " 
}

Procedure SaveRates.
  vpri = "^" + gpri.gpri + string(vrate.vterm,"99").
  do transaction:
     find pri where pri.pri = vpri no-error.
     if not available pri then do:
       create pri.
              pri.pri = vpri.
     end.
     do vi = 1 to 5:
        pri.tlimit[vi] = gpri.tlimit[vi].
        pri.trate[vi] = vrate.rate[vi].
     end. 
        pri.tlimit[6] = pri.tlimit[5].
        pri.trate[6] = pri.trate[5].
  end.   
End Procedure.

Procedure SaveLimits.
  vpri = "^" + gpri.gpri.
  do transaction:
     for each pri where pri.pri begins vpri:
       do vi = 1 to 5:
          pri.tlimit[vi] = gpri.tlimit[vi].
       end.
          pri.tlimit[6] = pri.tlimit[5].
     end. 
  end.   
End Procedure.
