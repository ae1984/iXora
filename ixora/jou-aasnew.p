/* jou-aasnew.p
 * MODULE
        Клиентская база
 * DESCRIPTION
        Блокирует сумму на счете получателя при помощи спец. инструкций для контроля старшим менеджером
        Вызывается для вида проводки СЧЕТ -> СЧЕТ для ЮЛ
 * RUN

 * CALLER
        jou_main.p
 * SCRIPT

 * INHERIT

 * MENU
        2-1
 * AUTHOR
        09.04.2003 sasco
 * CHANGES
        03.10.2003 nadejda  - вынесла основное тело программы в jou-aasnew.i
        02/05/2012 evseev - логирование значения aaa.hbal
*/

def var elgr as char init "202,204,222,D*".

/* отобьем физ. лиц - для клиентских проводок */
find sysc where sysc.sysc = "EXCLGR" no-lock no-error.
if avail sysc then elgr = sysc.chval.

{jou-aasnew.i

 &start = "
   do i = 1 to num-entries (elgr):
      if entry (i, elgr) <> '' then do:
         if aaa.lgr matches entry (i, elgr) then return.
      end.
   end.
 "
}


