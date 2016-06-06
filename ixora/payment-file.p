/*   payment-file.p
 * MODULE
        Переводы
 * DESCRIPTION
        Переводы (Формирование уведомления о выплате перевода)
 * RUN
        s_r-translat.p
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT

 * MENU
        .
 * AUTHOR
        21.06.2005 Ilchuk
 * BASES
        BANK COMM
 * CHANGES
        15.07.05 nataly  - добавлен статус 9 - изменен перевод
        22.07.05 nataly  - добавлено проставление символа кас плана
        27.07.05 nataly добавлена обработка банка по коду nmbr
        02.11.05 nataly откомментировано run mail для типа 6
        12/07/06 nataly добавила обработку корректировки данных через s-nomer1
        27/05/08 marinav - добавление поля РНН
        28/05/08 marinav
        27/06/08 marinav -    v-comis = 0
        15/07/08 marinav - добавила условие arp.des matches "*МЕТРОЭКСПРЕСС*"
        13.01.2012 damir - добавил keyord.i
        01.02.2012 lyubov - изменения в trx-can.i, trx-pay.i
        07.03.2012 damir - перекомпиляция.
*/

{mainhead.i}
{keyord.i} /*Переход на новые и старые форматы ордеров*/

def input parameter v-nomer as char. /* Номер выплаченного перевода */
def input parameter v-type as int. /* Тип отправляемого файла */
                    /* 1 - уведомления о выплате перевода */
                    /* 2 - отмена перевода  */
                    /* 6 - изменение реквизитов платежа */

define new shared variable s-nomer1 like translat.nomer.

def var vh as char no-undo.
def buffer b-crc for crc.

def var sum as decimal no-undo.
def var sumcom as decimal no-undo.
def var sumraz as decimal no-undo.

define var v-chk as char no-undo.
define buffer b-acheck FOR acheck.
/*{global.i}*/

def var v-crc as char no-undo.
def var v-crc2 as char no-undo.
def new shared var s-jh like jh.jh.
def var vdel as char initial "^" no-undo.
def var vparam as char no-undo.
def var rcode as inte no-undo.
def var rdes as char no-undo.
def var inper as char no-undo.
def var inper2 as char no-undo.
def var incom as char no-undo.

def var outper as char no-undo.
def var outper2 as char no-undo.
def var outcom as char no-undo.
def var arpper as char no-undo.
def var arpper2 as char no-undo.
def var arpcom as char no-undo.
def var v-comis as decimal no-undo.

def buffer isysc for sysc.
def buffer isysc2 for sysc.
def buffer outsysc for sysc.
def buffer outsysc2 for sysc.
def buffer b-translat for translat.
/*define shared variable s-nomer like translat.nomer.*/

find first sysc where sysc.sysc = 'sendtr' no-lock no-error.   /* Пути откуда отправляем*/
if not avail sysc then do:
    message  " Уведомление о получении. Не найдена запись sendtr Б SYSC. ".
    pause 3.
    return.
end.

find nmbr where nmbr.code = 'translat' no-lock no-error.
find first spr_bank where spr_bank.code = nmbr.prefix no-lock no-error.
  if not avail spr_bank then do:
    message " Не найден банк отправитель перевода в таблице spr_bank!".
    pause 3.
    return.
  end.

case v-type: /*уведомления о выплате перевода*/
  when 1 then do:
    find first r-translat where r-translat.nomer = v-nomer exclusive-lock no-error.
      if not avail r-translat then do:
        message " Не найден перевод: " + v-nomer + ", для отправки уведомления о доставке! ".
        pause 3.
        return.
      end.

    r-translat.who  = g-ofc. /*Кто выплатил перевод*/
    r-translat.dt-vidach = today. /* Дата выплаты перевода*/
    r-translat.tim-vidach = time. /* Время выплаты перевода*/

    output to rpt.img.
    put unformatted "ВЫПЛАЧЕН"            "|"  /* Статус */
                    r-translat.nomer      "|"  /* Номер перевода */
                    spr_bank.code         "|"  /* Код пункта отправки уведомления о выплате перевода */
                    spr_bank.name         "|"  /* Банк/филиал из которого отправлено уведомление о выплате перевода */
                    r-translat.dt-vidach  "|"  /* Дата выплаты перевода */
                    r-translat.tim-vidach "|"  /* Время выплаты перевода */
                                      skip.
    output close. pause 0.
    unix silent value ("cat rpt.img | win2koi > " + sysc.chval + "V" + substring(r-translat.nomer,5,6) + "." + spr_bank.eng-code).

/*транзакционная часть*/
s-jh = 0.

find isysc where isysc.sysc = 'inper' no-lock no-error.
if avail isysc then inper = isysc.chval.


find isysc2 where isysc2.sysc = 'inper2' no-lock no-error.
if avail isysc2 then inper2 = isysc2.chval.

find crc where crc.crc =  r-translat.crc no-lock no-error.
if avail crc then v-crc = crc.code.

find arp where arp.gl  = integer(inper)  and arp.crc = r-translat.crc and arp.des matches "*МЕТРО*" and length(arp.arp) = 20 no-lock no-error.
if avail arp then arpper = arp.arp.
else do:
     message 'Не найден счет ARP по ГК ' inper  ' в валюте ' v-crc skip 'Перевод не может быть отправлен!'.
     return.
end.

find arp where arp.gl  = integer(inper2)  and arp.crc = r-translat.crc and arp.des matches "*МЕТРО*" and length(arp.arp) = 20 no-lock no-error.
if avail arp then arpper2 = arp.arp.
else do:
     message 'Не найден счет ARP по ГК ' inper2  ' в валюте ' v-crc skip 'Перевод не может быть отправлен!'.
     return.
end.
   /*
    v-comis = r-translat.summa * 0.02.
    case r-translat.crc.
     when 2 then v-comis = max(v-comis,2).
     when 3 then v-comis = max(v-comis,2).
     when 4 then  v-comis = max(v-comis,30).
    end case.
  */
   v-comis = 0.
   {trx-pay.i}
      r-translat.jh = s-jh.
/*run vou_bank(2).*/

{nomer.i}
r-translat.stat = 11. /*подтвержден менеджером*/

/*  в пп 3-1-1
               run mail  ("metroexport@mail.texakabank.kz",
               "TEXAKABANK <abpk@elexnet.kz>",
               "Dkjhs883ISdj7 Перевод ВЫПЛАЧЕН " + r-translat.nomer,
               "Перевод ВЫПЛАЧЕН См. вложение." ,
               "1", "",
               sysc.chval + "V"  + substring(r-translat.nomer,5,6) + "." + spr_bank.eng-code  ).

    r-translat.stat = 2.*/
    RELEASE r-translat.
  end.
  when 2  or when 6 then do: /* отмена перевода  или изменение реквизитов платежа */
    find first translat where translat.nomer = v-nomer exclusive-lock no-error.
      if not avail translat then do:
        message " Не найден перевод: " v-nomer ", для отмены! ".
        pause 3.
        return.
      end.

    if translat.stat <> 2 and translat.stat <> 3 then do:
        message " У перевода: " v-nomer ", неверный статус - " translat.stat.
        pause 3.
        return.
    end.

    translat.dt-otm = today. /* Дата отмены перевода*/
    translat.tim-otm = time. /* Время отмены перевода*/

    output to rpt.img.
    put unformatted "ОТМЕНЕН"             "|"  /* Статус */
                    translat.nomer        "|"  /* Номер перевода */
                    spr_bank.code         "|"  /* Код пункта отправки отмены перевода */
                    spr_bank.name         "|"  /* Банк/филиал из которого отправлена отмена перевода */
                    translat.dt-otm       "|" /* Дата отмены перевода*/
                    translat.tim-otm      "|" /* Время отмены перевода*/
                                      skip.
    output close. pause 0.
    unix silent value ("cat rpt.img | win2koi > " + sysc.chval + "O" + substring(translat.nomer,5,6) + "." + spr_bank.eng-code).

/*транзакционная часть*/
 if v-type = 2 then do:
s-jh = 0.

 find crc where crc.crc =  translat.crc no-lock no-error.
 if avail crc then v-crc = crc.code.


 find outsysc where outsysc.sysc = 'outpr' no-lock no-error.
 if avail outsysc then outper = outsysc.chval.

 find outsysc2 where outsysc2.sysc = 'outpr2' no-lock no-error.
 if avail outsysc2 then outper2 = outsysc2.chval.

 find arp where arp.gl  = integer(outper)  and arp.crc = translat.crc and arp.des matches "*МЕТРО*" and length(arp.arp) = 20 no-lock no-error.
 if avail arp then arpper = arp.arp.
 else do:
      message 'Не найден счет ARP по ГК ' outper  ' в валюте ' v-crc skip 'Перевод не может быть отправлен!'.
      return.
  end.

 find arp where arp.gl  = integer(outper2)  and arp.crc = translat.crc and arp.des matches "*МЕТРО*" and length(arp.arp) = 20 no-lock no-error.
 if avail arp then arpper2 = arp.arp.
 else do:
      message 'Не найден счет ARP по ГК ' outper2  ' в валюте ' v-crc skip 'Перевод не может быть отправлен!'.
      return.
  end.
   {trx-can.i}
      translat.jh-voz = s-jh.

/*run vou_bank(2).*/
  {nomer.i}
  translat.stat = 51. /*подтвержден менеджером*/
/*  run mail  ("metroexport@mail.texakabank.kz",
               "TEXAKABANK <abpk@elexnet.kz>",
               "Dkjhs883ISdj7 Перевод ОТМЕНЕН" + translat.nomer,
               "Перевод ОТМЕНЕН См. вложение." ,
               "1", "",
               sysc.chval + "O"  + substring(translat.nomer,5,6) + "." + spr_bank.eng-code  ).

    translat.stat = 5. */
 end. /*v-type = 2 - ТОЛЬКО ОТМЕНА*/
 else do:
         run mail  ("metroexport@ml01.metrobank.kz",
            "METROKOMBANK <mkb@metrokombank.kz>",
           "Kildd638Hsy728Н" ,
           "Перевод ОТМЕНЕН См. вложение." ,
            "1", "",
           sysc.chval + "O" + substring(translat.nomer,5,6) + "." + spr_bank.eng-code  ).

  translat.stat = 5. /*ОТМЕНЕН*/
  create b-translat.
      run n-trans.
    buffer-copy translat except translat.nomer to b-translat .
     b-translat.stat  = 9. /*ИЗМЕНЕНЫ РЕКВИЗИТЫ*/

     b-translat.date = g-today.
     b-translat.who   = g-ofc.
     b-translat.nomer = s-nomer1 .

 end.
/*Отменен*/
    RELEASE translat.
    RELEASE b-translat.

  end.
  when 3 then do: /* Уведомление об отмене перевода*/
    find first r-translat where r-translat.nomer = v-nomer exclusive-lock no-error.
      if not avail r-translat then do:
        message " Не найден перевод: " + v-nomer + ", для отправки уведомления об отмене! ".
        pause 3.
        return.
      end.

    output to rpt.img.
    put unformatted "ПОДТВЕРЖДЕНИЕОТМЕНЕНЫ"  "|"  /* Статус */
                    r-translat.nomer      "|"  /* Номер перевода */
                    spr_bank.code         "|"  /* Код пункта отправки уведомления о выплате перевода */
                    spr_bank.name         "|"  /* Банк/филиал из которого отправлено уведомление о выплате перевода */
                    today                 "|"  /* Дата отмены перевода */
                    time                  "|"  /* Время отмены перевода */
                                      skip.
    output close. pause 0.
    unix silent value ("cat rpt.img | win2koi > " + sysc.chval + "R" + substring(r-translat.nomer,5,6) + "." + spr_bank.eng-code).

         run mail  ("metroexport@ml01.metrobank.kz",
            "METROKOMBANK <mkb@metrokombank.kz>",
           "Kildd638Hsy728",
           "Перевод ПОДТВЕРЖДЕНИЕОТМЕНЕНЫ  См. вложение." ,
            "1", "",
           sysc.chval + "R" + substring(translat.nomer,5,6) + "." + spr_bank.eng-code  ).

  end.
  when 4 then do: /*возврат перевода*/
    find first translat where translat.nomer = v-nomer exclusive-lock no-error.
      if not avail translat then do:
        message " Не найден перевод: " v-nomer ", для возврата! ".
        pause 3.
        return.
      end.

    if translat.stat <> 2 and translat.stat <> 3 then do:
        message " У перевода: " v-nomer ", неверный статус - " translat.stat.
        pause 3.
        return.
    end.

    translat.dt-otm = today. /* Дата возврата перевода*/
    translat.tim-otm = time. /* Время возврата перевода*/

    output to rpt.img.
    put unformatted "ВОЗВРАЩЕН"           "|"  /* Статус */
                    translat.nomer        "|"  /* Номер перевода */
                    spr_bank.code         "|"  /* Код пункта отправки возврата перевода */
                    spr_bank.name         "|"  /* Банк/филиал из которого отправлен возврат перевода */
                    translat.dt-otm       "|" /* Дата возврата перевода*/
                    translat.tim-otm      "|" /* Время возврата перевода*/
                                      skip.
    output close. pause 0.
    unix silent value ("cat rpt.img | win2koi > " + sysc.chval + "C" + substring(translat.nomer,5,6) + "." + spr_bank.eng-code).

/*транзакционная часть*/
s-jh = 0.

 find crc where crc.crc =  translat.crc no-lock no-error.
 if avail crc then v-crc = crc.code.

 find outsysc where outsysc.sysc = 'outpr' no-lock no-error.
 if avail outsysc then outper = outsysc.chval.

 find outsysc2 where outsysc2.sysc = 'outpr2' no-lock no-error.
 if avail outsysc2 then outper2 = outsysc2.chval.

 find arp where arp.gl  = integer(outper)  and arp.crc = translat.crc and arp.des matches "*МЕТРО*" and length(arp.arp) = 20 no-lock no-error.
 if avail arp then arpper = arp.arp.
 else do:
      message 'Не найден счет ARP по ГК ' outper  ' в валюте ' v-crc skip 'Перевод не может быть отправлен!'.
      return.
  end.

 find arp where arp.gl  = integer(outper2)  and arp.crc = translat.crc and arp.des matches "*МЕТРО*" and length(arp.arp) = 20 no-lock no-error.
 if avail arp then arpper2 = arp.arp.
 else do:
      message 'Не найден счет ARP по ГК ' outper2  ' в валюте ' v-crc skip 'Перевод не может быть отправлен!'.
      return.
  end.
   {trx-can.i}
      translat.jh-voz = s-jh.
{nomer.i}
translat.stat = 71. /*подтвержден менеджером*/

/*run vou_bank(2).*/
/*    run mail  ("metroexport@mail.texakabank.kz",
               "TEXAKABANK <abpk@elexnet.kz>",
               "Dkjhs883ISdj7 Перевод ВОЗВРАЩЕН " + translat.nomer,
               "Перевод ВОЗВРАЩЕН См. вложение." ,
               "1", "",
               sysc.chval + "C" + substring(translat.nomer,5,6) + "." + spr_bank.eng-code  ).

    translat.stat = 7. /*Возвращен*/  */
    RELEASE translat.
  end.
  when 5 then do: /* Уведомление о возврате перевода*/
    find first r-translat where r-translat.nomer = v-nomer exclusive-lock no-error.
      if not avail r-translat then do:
        message " Не найден перевод: " + v-nomer + ", для отправки уведомления о возврате! ".
        pause 3.
        return.
      end.

    output to rpt.img.
    put unformatted "ПОДТВЕРЖДЕНИЕВОЗВРАТА" "|"  /* Статус */
                    r-translat.nomer      "|"  /* Номер перевода */
                    spr_bank.code         "|"  /* Код пункта отправки уведомления о выплате перевода */
                    spr_bank.name         "|"  /* Банк/филиал из которого отправлено уведомление о выплате перевода */
                    today                 "|"  /* Дата отмены перевода */
                    time                  "|"  /* Время отмены перевода */
                                      skip.
    output close. pause 0.
    unix silent value ("cat rpt.img | win2koi > " + sysc.chval + "R" + substring(r-translat.nomer,5,6) + "." + spr_bank.eng-code).

         run mail  ("metroexport@ml01.metrobank.kz",
            "METROKOMBANK <mkb@metrokombank.kz>",
           "Kildd638Hsy728",
           "Перевод ПОДТВЕРЖДЕНИЕВОЗВРАТА  См. вложение." ,
            "1", "",
           sysc.chval + "R" + substring(r-translat.nomer,5,6) + "." + spr_bank.eng-code  ).

  end.
end.

