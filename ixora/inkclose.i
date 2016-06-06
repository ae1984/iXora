 /* inkclose.i
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Оплата инкассовых распоряжений
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        При закрытии опердня
 * AUTHOR
         dpuchkov
 * CHANGES
        12.08.05 dpuchkov перекомпиляция
        01.09.05 dpuchkov обрабатываем с частичной оплатой затем неоплаченые
        21.10.05 dpuchkov добавил значение в sub-cod.
        17.11.2008 alex - Инкассовые распоряжения
        10.06.2009 galina - добавила поле vo в таблице t-inc
        14.08.2009 galina - перенесла контроль денежных средств до посадки ИР на К-2
        20/10/2009 galina - не формируем платеж автоматически, если есть приоставление кроме платежей в бюджет и СО одновременно
        19/11/2010 galina - берем наименование НК из таблицы taxbnk
        01/04/2011 madiyar - изменился справочник pdoctng, исправил инициализацию значения справочника
        06/06/2011 evseev - переход на ИИН/БИН
        20/06/2011 evseev - ТЗ 888, отправка на почту уведомление об оплате. Пока вывод на мой e-mail
        23/06/2011 evseev - добавил логирование savelog
        24/06/2011 evseev - добавил логирование savelog
        27/06/2011 evseev - ТЗ 888, отправка на почту уведомление об оплате. Пока вывод на e-mail О.О.
        14/10/2011 evseev - индентация кода
        24/10/2011 evseev - БИН бенефециара из РНН
        02/11/2011 evseev - СЗ от 01.11.2011 другая дата в назн. плат.
        15.06.2012 evseev - ТЗ-1397. Отправитель = префикс + наименование
        19.06.2012 evseev - клиринг до 14:00 гросс после 14:00
        01.08.2012 evseev - ТЗ-1445
*/

find last aaa where aaa.aaa = aas.aaa exclusive-lock no-error.
if not avail aaa then next.
find last cif where cif.cif = aaa.cif no-lock no-error.
if not avail cif then next.

run savelog( "_inkclose", "inkclose.i: 1) aaa = " + aaa.aaa).
if aaa.crc <> 1  then next.

if aas.sta = 8 then next.
/*оплачиваем только один из тенговых счетов*/
if aaa.crc = 1 then do:
    find last t-iaccs where t-iaccs.iaaa <> aaa.aaa and t-iaccs.icif = cif.cif and t-iaccs.fsum = aas.fsum and
                            t-iaccs.docdat = aas.docdat and t-iaccs.knp = aas.knp and t-iaccs.kbk = aas.kbk no-lock no-error.
    if avail t-iaccs then next. /*оплата была*/
end.

l_afnd = False.

/*если есть другие инструкции то блокируем*/
olds = 0.
for each oldaas where oldaas.aaa = aaa.aaa and lookup(string(oldaas.sta), "0,3") <> 0 no-lock:
  olds = olds + oldaas.chkamt.
end.


/*контроль денежных средств*/
d_arsum = 0.
for each aaar where aaar.a5 = aas.aaa and aaar.a4 <> "1" no-lock:
   d_arsum = d_arsum + decimal(aaar.a3).
end.
run savelog( "_inkclose", "inkclose.i: 2) aaa = " + aaa.aaa + "; olds = " + string(olds) + "; d_arsum = " + string(d_arsum)).
/************************************************************************************ инкассовые ***************************************************/
run savelog( "_inkclose", "inkclose.i: 2.1) aaa = " + aaa.aaa + "; (aaa.cr[1] - aaa.dr[1]) - (olds + d_arsum) = " + string((aaa.cr[1] - aaa.dr[1]) - (olds + d_arsum)) + "; aas.fsum = " + string(aas.fsum)).
if (aaa.cr[1] - aaa.dr[1]) - (olds + d_arsum) < aas.fsum then do:
    find first inc100 where (inc100.bank eq s-vcourbank) and (inc100.iik = aas.aaa) and (inc100.num = integer(aas.fnum)) and
                            (inc100.mnu = "blk") and (inc100.stat eq 1) exclusive-lock no-error.
    if avail inc100 then do:
        assign inc100.stat2 = "03" inc100.mnu = "K2_sent".
        find current inc100 no-lock.
        create t-inc.
        assign t-inc.jss = inc100.jss
            t-inc.iik = inc100.iik
            t-inc.crc = inc100.crc
            t-inc.sum = inc100.sum
            t-inc.num = inc100.num
            t-inc.ref = inc100.ref
            t-inc.stat2 = inc100.stat2
            t-inc.bin = inc100.bin.
        for each b-inc100 where b-inc100.rgref = inc100.rgref no-lock:
            if b-inc100.stat = 1 and b-inc100.mnu = "blk" then do:
                find first b2-inc100 where b2-inc100.ref = b-inc100.ref exclusive-lock no-error.
                if avail b2-inc100 then do:
                    assign b2-inc100.stat2 = "03" b2-inc100.mnu = "K2_sent".
                    find current b2-inc100 no-lock.
                    create t-inc.
                    assign t-inc.jss = b2-inc100.jss
                        t-inc.iik = b2-inc100.iik
                        t-inc.crc = b2-inc100.crc
                        t-inc.sum = b2-inc100.sum
                        t-inc.num = b2-inc100.num
                        t-inc.ref = b2-inc100.ref
                        t-inc.stat2 = b2-inc100.stat2
                        t-inc.vo = inc100.vo
                        t-inc.bin = b2-inc100.bin.
                end.
            end. /*  if b-inc100.stat eq 1 and b-inc100.mnu = "blk" */
        end. /* for each b-inc100 */
    end. /*avail inc100*/
    run savelog( "_inkclose", "inkclose.i: 2.2) aaa = " + aaa.aaa + "; (aaa.cr[1] - aaa.dr[1]) - olds = " + string((aaa.cr[1] - aaa.dr[1]) - olds)).
    if (aaa.cr[1] - aaa.dr[1]) - olds <= 0 then next.
end. /*if (aaa.cr[1] - aaa.dr[1]) - */
/************************************************************************************ инкассовые ***************************************************/

if avail aaa and avail cif then do:
   /*зависла частичная оплата с данного счета*/
   d_arsummy = 0.
   for each aaar where aaar.a5 = aas.aaa and aaar.a4 <> "1" and aaar.a2 = aas.fnum no-lock:
      d_arsummy = d_arsummy + decimal(aaar.a3).
   end.
   run savelog( "_inkclose", "inkclose.i: 3) aaa = " + aaa.aaa + "; d_arsummy = " + string(d_arsummy)).

   if aas.docdat = ? then v-dt1 = aas.regdt. else v-dt1 = aas.docdat.

   d-SumOfPlat = 0.
   if (aaa.cr[1] - aaa.dr[1]) - d_arsum  > 0 then do:
      v-opl = "".
      if decimal(aas.docprim) - d_arsummy <= ((aaa.cr[1] - aaa.dr[1]) - decimal(d_arsum) - olds) then do:
         d-SumOfPlat = decimal(aas.docprim) - decimal(d_arsummy).
         v-opl = "Оплата И.Р номер " +  string(aas.fnum,"99999999999999999") + " от " + string(v-dt1) + " КБК " + string(aas.kbk) + " " + string(aas.docnum).
      end.
      if decimal(aas.docprim) - d_arsummy >  ((aaa.cr[1] - aaa.dr[1]) - decimal(d_arsum) - olds) then do:
         d-SumOfPlat = (aaa.cr[1] - aaa.dr[1]) - decimal(d_arsum) - olds - decimal(d_arsummy).
         v-opl = "Оплата И.Р номер " + string(aas.fnum,"99999999999999999") + " от " + string(v-dt1) + " КБК " + string(aas.kbk) + " " +
                 string(aas.docnum) + "          (Частичная оплата)".
      end.
      run savelog( "_inkclose", "inkclose.i: 4) aaa = " + aaa.aaa + "; d-SumOfPlat = " + string(d-SumOfPlat)).
      if d-SumOfPlat <= 0 then
         next.
      else do:
          find last b-blkaas where b-blkaas.aaa = aas.aaa and b-blkaas.sta = 1 no-lock no-error.
          if avail b-blkaas then next.
          find last b-blkaas where b-blkaas.aaa = aas.aaa and lookup(string(b-blkaas.sta), "11,16,17") <> 0 no-lock no-error.
          if avail b-blkaas then do:
             find last b-blkaas where b-blkaas.aaa = aas.aaa and b-blkaas.sta = 2 no-lock no-error.
             if avail b-blkaas then next.
          end.
      end.
      if v-bin and aas.nkbin = "" then do:
         find last taxnk where taxnk.rnn = aas.dpname no-lock no-error.
         if avail taxnk then aas.nkbin = taxnk.bin.
      end.
      if v-bin then find last taxnk where taxnk.bin = aas.nkbin no-lock no-error.
      else find last taxnk where taxnk.rnn = aas.dpname no-lock no-error.
      if avail taxnk and d-SumOfPlat > 0 then do:
         d-tmpSum  = 0.
         d_sum     = 0.
         d_sum     = aaa.hbal.
         t-sum = 0.

         for each taas1 where taas1.aaa = aas.aaa and lookup(string(taas1.sta), "2,4,5,6,7,9") <> 0 no-lock:
             t-sum = t-sum + taas1.chkamt.
         end.
         find sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = aaa.cif and sub-cod.d-cod = "secek" no-lock no-error.
         if not avail sub-cod or sub-cod.ccode <> "msc" then do:
	 	    v_sec = string(sub-cod.ccode).
         end. else v_sec = "".

         if time < 50400 then r-cover = 1. /* SCLEAR00 */
         else r-cover = 2. /* SGROSS00 */

         run inktax
             (aas.fnum,           /* Номер документа */
             d-SumOfPlat,  /* Сумма платежа   */
             aas.aaa,      /* Счет отправителя*/
             /*string(comm.taxnk.bik,"999999999")*/ 'KKMFKZ2A',   /* Банк получателя */
             /*string(comm.taxnk.iik,"999999999")*/'KZ24070105KSN0000000',   /* Счет получателя */
             aas.kbk,      /* КБК */
             true,         /* Тип бюджета - проверяется если есть КБК */
             /*aas.bnf*/
             taxnk.name,      /* Бенефициар      */
             /*taxnk.rnn*/ aas.dpname,    /* РНН Бенефициара */
             aas.knp,      /* KNP */
             integer(substr(cif.geo,3,1) + v_sec),      /* Kod */
             /*integer(comm.taxnk.kod) */
             11            /*integer(comm.taxnk.kbe)*/, /* Kbe */
             v-opl, /* Назначение платежа */
             "INK",        /* Код очереди */
             "0",          /* Кол-во экз. */
             r-cover,      /* remtrz.cover (для проверки даты валютированият.е. 1-CLEAR00 или 2-SGROSS00) */
             cif.jss,      /* РНН отправителя */
             trim(trim(cif.prefix) + " " + trim(cif.name)),    /* s-fiozer        */
             aas.nkbin,    /* БИН Бенефициара */
             cif.bin). /* БИН отправителя */
         run savelog( "_inkclose", "inkclose.i: 5) aaa = " + aaa.aaa + "; inktax return-value = " + return-value).
         if return-value <> "" then do:
            create t-iaccs.
                t-iaccs.iaaa = aas.aaa.
                t-iaccs.icif = aaa.cif.
                t-iaccs.fsum = aas.fsum.
                t-iaccs.docdat = aas.docdat.
                t-iaccs.knp = aas.knp.
                t-iaccs.kbk = aas.kbk.
                t-iaccs.fnum = aas.fnum.
            /* таблица неоплаченных RMZ */
            create aaar.
                aaar.a1 = return-value.        /* rmz      */
                aaar.a2 = aas.fnum.            /* номер ИР */
                aaar.a3 = string(d-SumOfPlat). /* сумм     */
                aaar.a5 = aas.aaa.
                aaar.a6 = string(g-today).
                run savelog( "_inkclose", "inkclose.i: 6) aaa = " + aaa.aaa + "; aas.fnum = " + aas.fnum).
            /*признак ИР была служебка от бугалтерии*/
            find last sub-cod where sub-cod.acc = return-value and sub-cod.sub = 'rmz' and sub-cod.d-cod = 'pdoctng' exclusive-lock no-error.
            if avail sub-cod then do:
               sub-cod.d-cod = 'pdoctng'.
               sub-cod.ccode = '03'.
            end. else do:
               create sub-cod.
               sub-cod.acc = return-value.
               sub-cod.sub = 'rmz'.
               sub-cod.d-cod = 'pdoctng'.
               sub-cod.ccode = '03'.
            end.
            put stream m-out unformatted aaa.aaa + "+УСПЕШНО формирование rmz " + return-value  skip.
            find first cmp no-lock no-error.
            find sysc where sysc.sysc = "bnkadr" no-lock no-error.
            if avail cmp and avail sysc then do:
               run mail(entry(5, sysc.chval, "|"), "METROCOMBANK <abpk@metrocombank.kz>", "Сформировано платежное поручение на оплату ИР №" + entry(1,cmp.addr[1]), entry(1,cmp.addr[1]) + "\n\n" + "Сформировано платежное поручение  "  + return-value + " на оплату Инкассового распоряжения. Необходимо проверить реквизиты и акцептовать.", "1", "", "").
               run mail("id00787@metrocombank.kz", "METROCOMBANK <abpk@metrocombank.kz>", "Сформировано платежное поручение на оплату ИР №" + entry(1,cmp.addr[1]), entry(1,cmp.addr[1]) + "\n\n" + "Сформировано платежное поручение  "  + return-value + " на оплату Инкассового распоряжения. Необходимо проверить реквизиты и акцептовать.", "1", "", "").
            end. else do:
              run mail("id00787@metrocombank.kz", "METROCOMBANK <abpk@metrocombank.kz>", "Ошибка в inkclose.i", "Условие avail cmp and avail sysc вернуло false" , "1", "", "").
            end.

            run savelog( "_inkclose", "inkclose.i: 7) aaa = " + aaa.aaa + "; УСПЕШНО формирование rmz = " + return-value).
         end. else do:
            put stream m-out unformatted aaa.aaa + "-ОШИБКА формирование rmz " + rdes  skip.
         end.
      end. /* avail taxnk */
   end. /*if (aaa.cr[1] - aaa.dr[1]) - d_arsum  > 0 then do:*/
end. /*if avail aaa and avail cif then do:*/

