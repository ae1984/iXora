/* chk_stopdepos1.p
 * MODULE
        Поиск не пролонгированных депозитов
 * DESCRIPTION
        Описание
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
        02/08/2011 evseev
 * BASES
        COMM TXB
 * CHANGES
        02/08/2011 evseev - рассылка на почтовый адрес
        03/08/2011 evseev - перекомпиляция
        03/08/2011 evseev - добавил if length(aaa.aaa) <> 20 then next.
        08/09/2011 evseev - исправил length(aaa.aaa) на length(txb.aaa.aaa)
        19/04/2012 evseev - отбрасывать счета со статусом E
*/

for each txb.aaa where txb.aaa.sta <> "C" and txb.aaa.sta <> "E" no-lock.
  if length(txb.aaa.aaa) <> 20 then next.
  find first txb.acvolt where txb.acvolt.aaa = txb.aaa.aaa no-lock no-error.
  find last txb.accr where txb.accr.aaa =  txb.aaa.aaa no-lock no-error.
  if avail txb.acvolt and avail txb.accr then do:
    if date(txb.acvolt.x3) < txb.accr.fdt then  run mail("id00787@metrocombank.kz", "METROCOMBANK <abpk@metrocombank.kz>", "ОШИБКА: депозит не пролонгирован",
                    txb.aaa.aaa + "  " + txb.acvolt.x3 + "  " + string(txb.accr.fdt), "1", "", "").
  end.

end.

