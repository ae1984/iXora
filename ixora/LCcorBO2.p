﻿/*LCcorBO2.p
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
        29.06.2012 Lyubov  - изменила отправку писем, теперь адреса берутся из справ. bookcod, METROCOMBANK заменила на FORTEBANK
        02.07.2012 Lyubov  - исправила ошибки

*/
/*{global.i}*/
{mainhead.i}

def shared var s-lc like LC.LC.
def shared var s-corsts as char.
def shared var s-lccor like lcswt.lccor.

def var v-zag as char.
def var v-yes as logi init yes.
def var v-str as char.
def var v-sp  as char.
def var v-file  as char.
def var n     as inte.
def var m     as inte.
def var v-maillist as char no-undo extent 2.

pause 0.
if s-corsts <> 'BO1'  then do:
    message "Letter of status should be BO1!" view-as alert-box error.
    return.
end.
else do:
  message 'Do you want to change status?' VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE ' QUESTION !' update v-yes.
  if not v-yes then return.
  run LCcorsts(s-corsts,'FIN').

  run i799mt.

  find first lch where lch.lc = s-lc and  LCh.value4 = 'O799-' + string(s-lccor,'999999') and lch.kritcode = "TRNum" and lch.value1 <> '' no-lock no-error.
  if avail lch and trim(lch.value1) <> '' then v-file = replace(lch.value1,"/", "_") + "_" + string(s-lccor,'999999').

  find first LCswt where LCswt.LC = s-lc and LCswt.LCcor = s-lccor and LCswt.mt = 'I799' exclusive-lock no-error.
  LCswt.fname1 = v-file.
  LCswt.dt = g-today.
  find current LCswt no-lock no-error.

  /* сообщение */
  find first bookcod where bookcod.bookcod = 'mdmail' and bookcod.code = 'MD2' no-lock no-error.
  if avail bookcod then do:
     do n = 1 to num-entries(bookcod.name,','):
        v-sp = entry(n,bookcod.name,',').
        do m = 1 to num-entries(v-sp):
           if trim(entry(m,v-sp)) <> '' then do:
              if v-maillist[n] <> '' then v-maillist[n] = v-maillist[n] + ','.
              v-maillist[n] = v-maillist[n] + trim(entry(m,v-sp)).
           end.
        end.
     end.
  end.
  if v-maillist[1] <> '' then do:
      v-zag = 'Исходящая корреспонденция'.
      v-str = 'Референс инструмента: ' + s-lc.
      run mail(v-maillist[1],"FORTEBANK <abpk@fortebank.com>", v-zag,v-str, "", "","").
      if v-maillist[2] <> '' then run mail(v-maillist[2],"FORTEBANK <abpk@fortebank.com>", v-zag,v-str, "", "","").
      pause 0.
   end.
end.
