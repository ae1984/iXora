/* h-cif.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Оповещение кассиров
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
        01.03.2006 dpuchkov
 * CHANGES
        26.04.2006 dpuchkov добавил ограничение по времени оповещения 16:15 < time < 18:15.
        16.03.2011 id00004 заменил Сотрудника в рассылке оповещений
        06.06.2012 id00477 изменил проверку количества записей в таблице bankl для проверки на 128
                           изаменил список сотрудников в рассылке оповещений
        15.06.2012 id00477 изаменил список сотрудников в рассылке оповещений для IBH
        16.07.2012 Lyubov - добавила отправку писем МД, если до 17:30 не изменился статус события
        10.09.2012 Lyubov - убрала сообщение, подправила адрес
*/

{global.i}
{comm-txb.i}

def buffer b-lcpay   for lcpay.
def var v-zag    as char no-undo.
def var v-str    as char no-undo.
def var v-maillist as char no-undo.

def var v-msgntsnd as char init " бМХЛЮМХЕ! пЮАНРЮЕР ПЕФХЛ йЮЯЯЮ Б ОСРХ: ¶ " no-undo.
def buffer b-syss for sysc.
def var i_ind as integer init 0.
def var i as integer.
def var icheck as integer.
find last b-syss where b-syss.sysc = 'CASOFC' no-lock no-error.
if avail b-syss then
do:
   do i = 1 to num-entries(b-syss.chval):
      if int(entry(i,b-syss.chval)) = 1 then i_ind = 1.
   end.
end.

if comm-cod() = 0 and i_ind = 1 then do:
   if time > 58500 and time < 65700 then do:
      find sysc where sysc.sysc= "SNDK" exclusive-lock no-error.
      if avail sysc then do:
         if g-today = date(sysc.chval) then return.
         else
         sysc.chval = string(g-today).
      end.
      else return.

      for each cashier no-lock:
          unix silent value ("rsh NTMAIN net send " + cashier.ofc + " " +  v-msgntsnd).
      end.
   end.
end.



find last sysc where sysc.sysc = "ourbnk" no-lock no-error.


find last dproc where dproc.pid = "IBH" no-lock no-error.
if avail dproc then do:
   if (time - dproc.l_time) > 600 then do:
      /* run mail("denis@metrobank.kz", "ИНТЕРНЕТ-БАНКИНГ <netbank@metrocombank.kz>", "ОШИБКА: Процесс IBH не отвечает более 10 минут", "Необходимо перестартовать процесс на всех филиалах (если IBH не запускается возможно заблокирована таблица netbank одним из пользователей)" , "1", "",""). */
      run mail("ivan.karasev@metrocombank.kz", "ИНТЕРНЕТ-БАНКИНГ <netbank@metrocombank.kz>", "ОШИБКА: Процесс IBH не отвечает более 10 минут", "Необходимо перестартовать процесс IBH (если IBH не запускается возможно заблокирована таблица netbank одним из пользователей)" , "1", "","").
      run mail("alexandr.korzhov@metrocombank.kz", "ИНТЕРНЕТ-БАНКИНГ <netbank@metrocombank.kz>", "ОШИБКА: Процесс IBH не отвечает более 10 минут", "Необходимо перестартовать процесс IBH (если IBH не запускается возможно заблокирована таблица netbank одним из пользователей)" , "1", "","").
      run mail("anton.marchenko@metrocombank.kz", "ИНТЕРНЕТ-БАНКИНГ <netbank@metrocombank.kz>", "ОШИБКА: Процесс IBH не отвечает более 10 минут", "Необходимо перестартовать процесс IBH (если IBH не запускается возможно заблокирована таблица netbank одним из пользователей)" , "1", "","").
      run mail("Aleksey.Evseev@fortebank.com", "ИНТЕРНЕТ-БАНКИНГ <netbank@metrocombank.kz>", "ОШИБКА: Процесс IBH не отвечает более 10 минут", "Необходимо перестартовать процесс IBH (если IBH не запускается возможно заблокирована таблица netbank одним из пользователей)" , "1", "","").
   end.
end.

icheck = 0.
if sysc.chval = 'TXB00' then do:
   for each bankl no-lock :
       icheck = icheck + 1.
   end.
   if icheck < 128 then do:
    /*run mail("denis@metrobank.kz", "ОШИБКА_СПРАВОЧНИК БАНКОВ <netbank@metrocombank.kz>", "СПРАВОЧНИК БАНКОВ ЦО", "Внимание: cправочник банков ЦО поврежден, общее количество записей меньше 129  (проверьте таблицу bankl)" , "1", "","").*/
      run mail("ivan.karasev@metrocombank.kz", "ОШИБКА_СПРАВОЧНИК БАНКОВ <netbank@metrocombank.kz>", "СПРАВОЧНИК БАНКОВ ЦО", "Внимание: cправочник банков ЦО поврежден, общее количество записей меньше 128  (проверьте таблицу bankl)" , "1", "","").
      run mail("alexandr.korzhov@metrocombank.kz", "ОШИБКА_СПРАВОЧНИК БАНКОВ <netbank@metrocombank.kz>", "СПРАВОЧНИК БАНКОВ ЦО", "Внимание: cправочник банков ЦО поврежден, общее количество записей меньше 128  (проверьте таблицу bankl)" , "1", "","").
      run mail("madiyar.kassymzhanov@metrocombank.kz", "ОШИБКА_СПРАВОЧНИК БАНКОВ <netbank@metrocombank.kz>", "СПРАВОЧНИК БАНКОВ ЦО", "Внимание: cправочник банков ЦО поврежден, общее количество записей меньше 128  (проверьте таблицу bankl)" , "1", "","").
      run mail("konstantin.gitalov@metrocombank.kz", "ОШИБКА_СПРАВОЧНИК БАНКОВ <netbank@metrocombank.kz>", "СПРАВОЧНИК БАНКОВ ЦО", "Внимание: cправочник банков ЦО поврежден, общее количество записей меньше 128  (проверьте таблицу bankl)" , "1", "","").
      run mail("anton.marchenko@metrocombank.kz", "ОШИБКА_СПРАВОЧНИК БАНКОВ <netbank@metrocombank.kz>", "СПРАВОЧНИК БАНКОВ ЦО", "Внимание: cправочник банков ЦО поврежден, общее количество записей меньше 128  (проверьте таблицу bankl)" , "1", "","").
   end.
end.



/*-----------------------Trade Finance------------------------------*/

if time > 62971 and time < 63030 then do:
    find first bookcod where bookcod.bookcod = 'mdmail' and bookcod.code = 'MD1' no-lock no-error.
    if avail bookcod then do: v-maillist = bookcod.name.
        for each lc where lookup(lc.lcsts,'MD1,MD2,BO1') > 0 no-lock:
            assign v-zag = lc.lcsts
                   v-str = 'You have a Create/Advise under ' + lc.lc + ' pending on ' + lc.lcsts + '.'.
            run mail(v-maillist,"FORTEBANK <abpk@fortebank.com>", v-zag,v-str, "1", "","").
        end.

        for each lcevent where lookup(lcevent.sts,'MD1,MD2,BO1') > 0 no-lock:
            find first bookcod where bookcod.bookcod = 'lcevent' and bookcod.code = lcevent.event no-lock no-error.
            assign v-zag = lcevent.sts
                   v-str = 'You have a ' + bookcod.name + ' under ' + lcevent.lc + ' pending on ' + lcevent.sts + '.'.
            run mail(v-maillist,"FORTEBANK <abpk@fortebank.com>", v-zag,v-str, "1", "","").
        end.

        for each lcamend where lookup(lcamend.sts,'MD1,MD2,BO1') > 0 no-lock:
            assign v-zag = lcamend.sts
                   v-str = 'You have a Amendment under ' + lcamend.lc + ' pending on ' + lcamend.sts + '.'.
            run mail(v-maillist,"FORTEBANK <abpk@fortebank.com>", v-zag,v-str, "1", "","").
        end.

        for each lcpay where lookup(lcpay.sts,'MD1,MD2,BO1') > 0 no-lock:
            assign v-zag = lcpay.sts
                   v-str = 'You have a Payment under ' + lcpay.lc + ' pending on ' + lcpay.sts + '.'.
            run mail(v-maillist,"FORTEBANK <abpk@fortebank.com>", v-zag,v-str, "1", "","").
        end.
    end.
end.
