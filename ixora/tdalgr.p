/* tdalgr.p
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
        22/08/03 nataly изменен формат aaa.pri , pri.pri c "x(1)"  - > "x(3)"
        13.04.2004 nadejda - настройка для группы "Снимать/не снимать комиссию за конвертацию"
        02.07.04 dpuchkov - добавил привязку по VIP депозитам
        03.09.04 dpuchkov - добавил привязку валютных VIP депозитов к тенге в соответствии с измен законодательством(ТЗ1100)
        01.10.04 dpuchkov - добавил пункт база начисления % (для Звезды будет 360 дней)
        31.10.2006 u00124 добавил Максимальную сумму депозита.
        30.06.2008 alex - редактирование только из ЦО, синхронизация с филиалами
        01.07.2008 alex - добавил параметр в lgrpribranch
        
*/

{mainhead.i}

def var s-ourbank as char no-undo.
find sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(sysc.chval).
if s-ourbank ne "txb00" then do:
message "Редактирование доступно только из ЦО" view-as alert-box.
return.
end.

def var vpri as char.
def buffer b-lgr for lgr.

/*lgr.base = 365.*/ 
{jabro.i
&start = "view frame lgr1. view frame lgr2.
 on help of lgr.pri in frame lgr2 do: run tdaint-help1. end.
 on help of lgr.crc in frame lgr do:  run tdacrc-help.  end.
 on help of lgr.gl in frame lgr do: run tdagl-help. end.
 on help of lgr.autoext in frame lgr do: run uni_help1('spnpl', '3*'). end.
 on help of lgr.tlev in frame lgr do: run uni_help1('lgrsts', '*'). end.
 on help of lgr.feensf in frame lgr do: run tdasch-help('dpschema', '*'). end.
"
&head = "lgr"
&headkey = "lgr"
&where = "lgr.led = 'TDA'"
&index = "lgr"
&formname = "tdalgrset"
&framename = "lgr"
&addcon = "true"
&deletecon = "true"
&viewframe = " "
&predisplay = " find sub-cod where sub-cod.sub = 'lgr' and sub-cod.d-cod = 'lgrcomis' and sub-cod.acc = lgr.lgr no-lock no-error.
                if avail sub-cod and sub-cod.ccode = '0' then v-comiss = '0'. else v-comiss = '1'."
&display = "lgr.lgr lgr.des lgr.gl lgr.crc lgr.autoext lgr.tlev lgr.feensf v-comiss"
&highlight = "lgr.lgr"
&predelete = " "
&precreate = " "
&postadd = "clear frame lgr1. clear frame lgr2.
            lgr.led = 'TDA'.  lgr.stm = 'M'. lgr.complex = false. lgr.lookaaa = false. lgr.nxt = 1.
            lgr.pri = ''.  lgr.intcal = ''. lgr.intpay = ''.
            find last b-lgr where b-lgr.led = 'TDA' use-index ledln no-lock no-error. 
            if available b-lgr then lgr.ln = b-lgr.ln + 1.
            else lgr.ln = 1.
            update lgr.lgr lgr.des lgr.gl lgr.crc lgr.autoext lgr.tlev lgr.feensf with frame lgr.
            update lgr.prd lgr.dueday lgr.tlimit[1] lgr.tlimit[2]  lgr.tlimit[3] with frame lgr1.
            update lgr.pri lgr.intcal with frame lgr2.
            if lgr.intcal = 'S' then do:
               lgr.intpay = 'S'. lgr.type = 'N'. lgr.prefix = 'N'.
            end.
            update lgr.intpay when lgr.intcal <> 'S'
                   lgr.type when lgr.intcal <> 'S'
                   lgr.prefix when lgr.intcal <> 'S'with frame lgr2. 
           "
&prechoose = "disp lgr.prd lgr.dueday lgr.tlimit[1] lgr.tlimit[2] lgr.tlimit[3] with frame lgr1.
 disp lgr.pri lgr.intcal lgr.intpay lgr.type lgr.prefix with frame lgr2.
 message 'Enter-общие параметры,T-Сроки и суммы,I-Проценты,Insert-добавить группу,L-Привязка к тг(для VIP),B-База начисл(%) CTRL+D удалить группу, F4-выйти'.
"
&postdelete = " "
&postkey =
" else if keyfunction(lastkey) = 'RETURN' then
   do transaction on error undo, next inner:
            find sub-cod where sub-cod.sub = 'lgr' and sub-cod.d-cod = 'lgrcomis' and sub-cod.acc = lgr.lgr no-lock no-error.
            if avail sub-cod and sub-cod.ccode = '0' then v-comiss = '0'. else v-comiss = '1'.
            find lgr where recid(lgr) = crec.
            update lgr.des lgr.gl lgr.crc lgr.autoext lgr.tlev lgr.feensf v-comiss with frame lgr.
            run lgrcom (lgr.lgr, v-comiss).
   end.
  else if keyfunction(lastkey) = 'T' then
   do transaction on error undo, next inner:
            hide message.
            find lgr where recid(lgr) = crec.
            update lgr.prd lgr.dueday lgr.tlimit[1] lgr.tlimit[2]  lgr.tlimit[3] with frame lgr1.
   end.
  else if keyfunction(lastkey) = 'I' then
   do transaction on error undo, next inner:
            hide message.
            find lgr where recid(lgr) = crec.
            update lgr.pri lgr.intcal with frame lgr2.
            if lgr.intcal = 'S' then do:
               lgr.intpay = 'S'. lgr.type = 'N'. lgr.prefix = 'N'.
            end.
            else do:
               lgr.intpay = ''. lgr.type = ''. lgr.prefix = ''.
            end.
            update lgr.intpay when lgr.intcal <> 'S'
                   lgr.type when lgr.intcal <> 'S'
                   lgr.prefix when lgr.intcal <> 'S' with frame lgr2.
   end.
else if keyfunction(lastkey) = 'L' then
do transaction on error undo, next inner:
run crcfr.
end.
else if keyfunction(lastkey) = 'B' then
do transaction on error undo, next inner:
run prbase.
end.
else if keyfunction(lastkey) = 'M' then
do transaction on error undo, next inner:
run Maxprd.
end.

"
&end = "hide frame lgr. hide frame lgr1. hide frame lgr2. hide message."
}


/****************************************************************************************************/
def var v-all as log.
find sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(sysc.chval).

if s-ourbank = "txb00" then do:
    v-all = no.
    message "Производить изменения по всем филиалам?" view-as alert-box question buttons yes-no title "" update v-all.
    if v-all then do:
        displ " Синхронизация с филиалами... " with no-label row 7 centered frame vmess.
        {r-branch.i &proc = "lgrpribranch(yes)"}
        hide frame vmess.
    end.
end.

/****************************************************************************************************/


procedure prbase.
     hide message.
     find lgr where recid(lgr) = crec. 
     update lgr.base label 'База начисления процентов' with frame fm side-label.
end.


procedure Maxprd.
     hide message.
     find lgr where recid(lgr) = crec. 
     update lgr.tlimit[4] label 'Максимальная сумма' with frame fm side-label.
end.




procedure crcfr.
     hide message.
     find lgr where recid(lgr) = crec. 
     if lgr.crc <> 1 then
       update lgr.usdval label 'Привязать сумму к тенге' with frame fm side-label.
end.

procedure lgrcom.
  def input parameter p-lgr as char.
  def input parameter p-comiss as char.
  
  if p-comiss = '0' then do:
    find sub-cod where sub-cod.sub = 'lgr' and sub-cod.d-cod = 'lgrcomis' and sub-cod.acc = p-lgr exclusive-lock no-error.
    if not avail sub-cod then do:
      create sub-cod.
      sub-cod.sub = 'lgr'.
      sub-cod.d-cod = 'lgrcomis'.
      sub-cod.acc = p-lgr.
    end.
    sub-cod.ccode = '0'.
  end.
end.

