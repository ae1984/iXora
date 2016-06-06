/*LCcorBO2.p
 * MODULE
        Trade Finance
 * DESCRIPTION

 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        08/02/2011 evseev
 * BASES
        BANK COMM
 * CHANGES
        21/11/2011 id00810 - теперь на этой стадии отправляется сообщение и присваивается статус FIN
        05.03.2012 Lyubov  - передаем формат сообщения шареной переменной s-mt
        29.06.2012 Lyubov  - изменила отправку писем, теперь адреса берутся из справ. bookcod, METROCOMBANK заменила на FORTEBANK
*/

{mainhead.i}

def shared var s-lc     like LC.LC.
def shared var s-corsts as char.
def shared var s-lccor  like lcswt.lccor.
def shared var s-mt as inte.

def var v-zag      as char no-undo.
def var v-yes      as logi no-undo.
def var v-str      as char no-undo.
def var v-sp       as char no-undo.
def var v-file     as char no-undo.
def var v-maillist as char no-undo extent 2.
def var i          as int  no-undo.
def var k          as int  no-undo.


{chk-f.i}
pause 0.
if s-corsts <> 'MD1'  then do:
    message "Letter of status should be MD1!" view-as alert-box error.
    return.
end.
else do:
  message 'Do you want to change status?' VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE ' QUESTION !' update v-yes.
  if not v-yes then return.

  if chk-f("$HOME/.ssh/id_swift") ne '0' then do:
    message "There is no file $HOME/.ssh/id_swift!" view-as alert-box error.
    return.
  end.
  run i799mt no-error.
  if error-status:error then return.

  run LCcorsts(s-corsts,'FIN').

  find first lch where lch.lc = s-lc and  LCh.value4 = 'O' + string(s-mt) + '-' + string(s-lccor,'999999') and lch.kritcode = "TRNum" and lch.value1 <> '' no-lock no-error.
  if avail lch and trim(lch.value1) <> '' then v-file = replace(lch.value1,"/", "_") + "_" + string(s-lccor,'999999').

  find first LCswt where LCswt.LC = s-lc and LCswt.LCcor = s-lccor and LCswt.mt = 'I' + string(s-mt) exclusive-lock no-error.
  assign LCswt.fname1 = v-file
    LCswt.dt = g-today.
  find current LCswt no-lock no-error.

  /* сообщение */
    find first bookcod where bookcod.bookcod = 'mdmail' and bookcod.code = 'MD2' no-lock no-error.
    if avail bookcod then do:
       do k = 1 to num-entries(bookcod.name,','):
          v-sp = entry(k,bookcod.name,',').
          do i = 1 to num-entries(v-sp):
             if trim(entry(i,v-sp)) <> '' then do:
                if v-maillist[k] <> '' then v-maillist[k] = v-maillist[k] + ','.
                v-maillist[k] = v-maillist[k] + trim(entry(i,v-sp)).
             end.
          end.
       end.
    end.
  if v-maillist[1] <> '' then do:
    assign v-zag = 'Исходящая корреспонденция'
           v-str = 'Референс инструмента: ' + s-lc.
    run mail(v-maillist[1],"FORTEBANK <abpk@fortebank.com>", v-zag,v-str, "", "","").
    if v-maillist[2] <> '' then run mail(v-maillist[2],"FORTEBANK <abpk@fortebank.com>", v-zag,v-str, "", "","").
  end.
end.
