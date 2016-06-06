/* jou-aasnew2.p
 * MODULE
        Установка спец интструкций по неснижаемому остатку
 * DESCRIPTION
        Установка спец интструкций по неснижаемому остатку
        Вызывается для вида проводки КАССА -> СЧЕТ для ФЛ
 * RUN

 * CALLER
        jou_main.p
 * SCRIPT

 * INHERIT

 * MENU
        2-1
 * AUTHOR
        30.03.2006 nataly
 * CHANGES
        17.04.06 nataly добавлена обработка кода 193,180,181 - исключения по кредитам
        02/05/2012 evseev - логирование значения aaa.hbal
*/



def var fizlgr as char init "202,204,222,208".

/* отобьем физ. лиц - для клиентских проводок */
find sysc where sysc.sysc = "FIZLGR" no-lock no-error.
if avail sysc then fizlgr = sysc.chval.

{jou-aasnew2.i

 &start = "
   do i = 1 to num-entries (fizlgr):
      if entry (i, fizlgr) <> '' then do:
         if  lookup (aaa.lgr,fizlgr) = 0 then return.
      end.
   end.
 "
}


