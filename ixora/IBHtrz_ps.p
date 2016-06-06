/* IBHtz_ps.p
 * MODULE
        Платежная система
 * DESCRIPTION
        Процесс, который обрабатывает документы Интернет Офиса - создание внешнего платежа
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU
        5-1
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        30.07.2003 sasco    - Переделал удаление RMZ так, чтобы сначала QUE, только потом REMTRZ
        25.09.2003 nadejda  - убрала ненужные коды комиссий и поставила по умолчанию комиссии за счет отправителя для внешних валютных платежей
        12.10.2003 kanat    - Добавил Ширину Н. в расылку по почте
        31.10.2003 sasco    - Добавил проверку на v-reterr, запись значения в LOG, отправку по почте на it@elexnet.kz
        04.11.2003 sasco    - заменил в remtrz.sqn dep-date на valdate; убрал проверку на повторный номер документа за дату валютирования
        12.11.2003 sasco    - вернул в remtrz.sqn проверку на повторный номер документа за дату валютирования
        04.11.2003 sasco    - сделал выбор валюты комиссии в зависимости от счета комиссии
        27.02.2004 kanat    - убрал 5 тип платежа при проверке на время обработки платежных поручений процессом IBH.
        05.03.2004 nadejda  - разрешила заявки на конв/реконв после времени отсечки
        16.03.2004 sasco    - добавил отправку писем с подверждением на e-mail менеджерам (с разбивкой по филиалам)
        16.03.2004 sasco    - добавил charset KOI8
        17.03.2004 sasco    - добавил текст e-mail про просьюу обработать менеджером
        20.04.2004 isaev    - добавил адрес в список рассылки
        21.04.2004 dpuchkov - добавил автоматическую проверку кодового слова
        27.04.2004 isaev    - исправлена авт. проверка код. фразы (для табл. ib.usr теперь используется buffer busr)
        27.04.2004 tsoy     - Сохраняются дополнительные данные для физ лиц
        21.05.2004 sasco    - Убрал отправку мыла на sasco, isaev @ texakabank.kz
        05.07.2004 tsoy     - Добавил рассылку REMTRZ при повторном номере документа
        07.07.2004 tsoy     - Если платеж срочный то провести по ГРОССУ независимо от времени
        07.07.2004 tsoy     - Установка счета комиcсии для всех видов заявок на покупку валюты
        22.07.2004 tsoy     - Если платеж на филиал то заменить БИК на TXBxx
        01.09.2004 sasco    - переделал e-mail c support@ на it@
        03.09.2004 sasco    - переделал e-mail c support@ на it@
        08.10.2004 sasco    - добавил first, no-error в поиск otk
        01.02.2005 tsoy     - добавил saitahunova@elexnet.kz
        18.02.2005 tsoy     - добавил время создания платежа.
        10.03.2005 tsoy     - по умолчанию платежное поручение
        14.03.2005 tsoy     - добавил копирование файлов зарплатных проектов по карточкам.
        05.04.2005 u00121   - было так output through value("ftp -nc develop") no-echo. ,  стало так output through value("ftp -nc bankonline") no-echo.
        08.04.2005 tsoy     - добавил   v-reterr = 0.
        03.06.2005 tsoy     - Изменил даты валютирования     remtrz.valdt1 = today и remtrz.valdt2 = doc.valdate
        03.06.2005 u00121   - согласно СЗ _ 1311 от 21.01.2005 г. сотрудники РКО должны получать уведомления только о платежах своих клиентов, адресс РКО определяется по полю cif.jame из таблицы ppoin поле mail
        06.06.2005 tsoy     - Если срочный то статус проставляется еще и в справочник subcod urgency
        06.06.2005 tsoy     - Если валютный то дата валютирования как прежде
        08.06.2005 tsoy     - удралил вложенный do end.
        09.06.2005 tsoy     - для валютных вернул переопределение valdt2
        04.08.2005 Ten      - добавил обработку doc.filial and doc.rnn
        04.08.2005 tsoy     - добавил проверку эцп для authptype = otp
        31.08.2005 tsoy     - убрал пробелы из деталей чтоб получилось ровно 140 символов а не 143
        19.02.2006 tsoy     - изменил коментарий
        07.04.2006 ten      - Обработка цели покупки иностранной валюты.
        12.05.2006 tsoy     - Удалил Ширину из рассылки
        18.05.2006 tsoy     - убрал слэш из ba
        12ю07ю2006 Тен      - проставил комиссии за перевод для международных пл.поручений
        24.06.2006 tsoy     - пропускаем палтежи на Арп для Картела
        30.08.2006 tsoy     - -c убрал из ftp, добавили перенаправление ftp в /dev/null
        26.09.2006 tsoy     - ftp поменял на scp
        26.09.2006 tsoy     - испарвил пути, также вывод в лог инфы по результатам работы scp
        16.03.2011 id00004  - добавил обработку комиссии За счет отправителя, получателя
        01/04/2011 madiyar - изменился справочник pdoctng, исправил инициализацию значения справочника
        03/11/2011 id00004 - добавил снятие комиссии для платежей в валютах GBP, SEK, AUD, CHF по распоряжению ОД
        06.06.2012 evseev - отструктурировал код, добавил логирование для выявление бездействующего кода
        15.06.2012 evseev - удалил 1200строк не рабочего кода
        20.09.2012 evseev - ТЗ-1520
        18.10.2012 evseev - убрал exclusive-lock в for each
        18.09.2013 evseev - tz-926
        14.11.2013 zhassulan - ТЗ 1313, добавлено: тип комиссии SHA, код комиссии 304
*/



/**/
{global.i}
{lgps.i}

{Hvars_ps.i}

v-reterr = 0.

define input parameter p_txbtime as integer no-undo.
def new shared var ks-remtrz like remtrz.remtrz .
def var v-clnsts1 as char.
def buffer b-netbank for netbank.
def  var v-tmpdec as deci.

run savelog("IBHtrz_ps", "94. Начало...").

find last sysc where sysc.sysc = "ourbnk" no-lock no-error.
def var v-sndr as char.

for each netbank where netbank.txb = sysc.chval and netbank.type = 3 no-lock:
    run savelog("IBHtrz_ps", "100. " + netbank.rmz).
    find last que where que.remtrz = substr(netbank.rmz,4, length(netbank.rmz)) exclusive-lock no-error.
    if avail que then do:
       run savelog("IBHtrz_ps", "103.").
       delete que.
       release que.
       find first b-netbank where b-netbank.id = netbank.id and b-netbank.txb = sysc.chval and b-netbank.type = 3 exclusive-lock no-error.
       if avail b-netbank then do:
          b-netbank.type = 5.
          find current b-netbank no-lock no-error.
       end. else run savelog("IBHtrz_ps", "107. " + netbank.rmz + " " + string(netbank.id)).
    end.
end.

for each netbank where netbank.txb = sysc.chval and (netbank.type = 1 or netbank.type = 2) no-lock:
    if netbank.rmz begins "RMZ" then do:
       find last que where  que.remtrz = netbank.rmz no-lock no-error.
       if avail que then next.
       find last remtrz where remtrz.remtrz = netbank.rmz exclusive-lock no-error.
       if avail remtrz then do:
          find first bankl where bankl.bank = remtrz.scbank  no-lock no-error .
          if avail bankl then
             if bankl.nu = 'u' then v-sndr = 'u'. else v-sndr = 'n' .
          else v-sndr = '' .
          run savelog("IBHtrz_ps", "121. " + remtrz.remtrz + " " + v-sndr).
          if remtrz.svccgr = 0 then do:
            /* если это внешний валютный платеж, то проставить по умолчанию комиссию за счет отправителя */
            if remtrz.fcrc <> 1 and v-sndr = "o" and remtrz.rbank <> ourbank then do:
               find first bankl where bankl.bank = remtrz.rbank no-lock no-error .
               if (not avail bankl) or (avail bankl and bankl.nu = "n") then do:
                  run savelog("IBHtrz_ps", "127. " + remtrz.remtrz).
                  v-clnsts1 = "0".
                  find sub-cod where sub-cod.sub = "cln" and sub-cod.d-cod = "clnsts" and sub-cod.acc = netbank.cif no-lock no-error.
                  if avail sub-cod and sub-cod.ccode <> "msc" then v-clnsts1 = sub-cod.ccode.
                  case remtrz.fcrc :
                    when 4 then do:
                      run savelog("IBHtrz_ps", "133. " + remtrz.remtrz).
                      if v-clnsts1 = "0" then remtrz.svccgr = 218.
                                         else remtrz.svccgr = if ourbank = "TXB00" then 209 else 217.
                    end.
                    when 3 then do:
                      run savelog("IBHtrz_ps", "138. " + remtrz.remtrz).
                      if v-clnsts1 = "0" then remtrz.svccgr = /* if ourbank = "TXB01" then 219 else */ 205.
                                         else remtrz.svccgr = 209.
                    end.
                    otherwise do:
                      run savelog("IBHtrz_ps", "143. " + remtrz.remtrz).
                      if v-clnsts1 = "0" then remtrz.svccgr = 205.
                                         else remtrz.svccgr = 209.
                    end.
                  end case.
               end.
            end.
          end.
          /*  Ten - комиссии за перевод для международных пл.поручений  */
          if remtrz.tcrc <> 1 then do:
             run savelog("IBHtrz_ps", "153. " + remtrz.remtrz).
             if (remtrz.tcrc = 2 or remtrz.tcrc = 3 or remtrz.tcrc = 6 or remtrz.tcrc = 7 or remtrz.tcrc = 8 or remtrz.tcrc = 9) and remtrz.bi = "OUR" then remtrz.svccgr = 205.
             else if (remtrz.tcrc = 2 or remtrz.tcrc = 3 or remtrz.tcrc = 6 or remtrz.tcrc = 7 or remtrz.tcrc = 8 or remtrz.tcrc = 9) and remtrz.bi = "SHA" then remtrz.svccgr = 304.
             else if (remtrz.tcrc = 2 or remtrz.tcrc = 3 or remtrz.tcrc = 6 or remtrz.tcrc = 7 or remtrz.tcrc = 8 or remtrz.tcrc = 9) and remtrz.bi = "BEN" then remtrz.svccgr = 204.
             else if remtrz.tcrc = 4 then remtrz.svccgr = 218.
             find sub-cod where sub-cod.sub = "cln" and sub-cod.d-cod = "clnsts" and sub-cod.acc = netbank.cif no-lock no-error.
             if avail sub-cod and  sub-cod.ccode = "1" then do:
                if (remtrz.tcrc = 2 or remtrz.tcrc = 3 or remtrz.tcrc = 6 or remtrz.tcrc = 7 or remtrz.tcrc = 8 or remtrz.tcrc = 9) and remtrz.bi = "OUR" then remtrz.svccgr = 209.
                else if (remtrz.tcrc = 2 or remtrz.tcrc = 3 or remtrz.tcrc = 6 or remtrz.tcrc = 7 or remtrz.tcrc = 8 or remtrz.tcrc = 9) and remtrz.bi = "BEN" then remtrz.svccgr = 208.
                else if remtrz.tcrc = 4 then remtrz.svccgr = 217.
             end.
          end.
          /*Валютный внутрибанковский платеж*/
          if (remtrz.tcrc = 2 or  remtrz.tcrc = 3 or remtrz.tcrc = 4 or remtrz.tcrc = 6 or remtrz.tcrc = 7 or remtrz.tcrc = 8 or remtrz.tcrc = 9) and remtrz.ptype = 'M' then do:
             run savelog("IBHtrz_ps", "166. " + remtrz.remtrz).
             remtrz.svccgr = 571.
          end.
          if (remtrz.tcrc = 2 or  remtrz.tcrc = 3 or remtrz.tcrc = 4 or remtrz.tcrc = 6 or remtrz.tcrc = 7 or remtrz.tcrc = 8 or remtrz.tcrc = 9) and remtrz.ptype = '4' then do:
             run savelog("IBHtrz_ps", "170. " + remtrz.remtrz).
             remtrz.svccgr = 571.
          end.
          /* расчет суммы комиссии */
          ks-remtrz = remtrz.remtrz.
          if remtrz.svccgr ne 0 then do:
             run savelog("IBHtrz_ps", "176. " + remtrz.remtrz).
             run comisnb.
             /*установка суммы комиссии*/
            v-tmpdec = 0.
            find first comm.swbody where comm.swbody.rmz = remtrz.remtrz and comm.swbody.type  = "F" and comm.swbody.swfield = "71" exclusive-lock no-error.
            if avail comm.swbody then do:
                run savelog("IBHtrz_ps",  "183. " + string(remtrz.svccgr) + " | " + string(remtrz.svca) ).
                if remtrz.svcrc = 1 then do:
                    find first crc where crc.crc = remtrz.tcrc no-lock no-error.
                    v-tmpdec = remtrz.svca.
                    v-tmpdec = v-tmpdec / crc.rate[1].
                    v-tmpdec = round(v-tmpdec,2).
                end. else if remtrz.svcrc <> remtrz.tcrc then do:
                    v-tmpdec = remtrz.svca.
                    find first crc where crc.crc = remtrz.svcrc no-lock no-error.
                    v-tmpdec = v-tmpdec * crc.rate[1].
                    find first crc where crc.crc = remtrz.tcrc no-lock no-error.
                    v-tmpdec = v-tmpdec / crc.rate[1].
                    v-tmpdec = round(v-tmpdec,2).
                end. else do:
                    find first crc where crc.crc = remtrz.tcrc no-lock no-error.
                    v-tmpdec = remtrz.svca.
                end.
               comm.swbody.content[1] = crc.code + trim(replace(string(v-tmpdec,">>>>>>>>>>>>>>>9.99"),".",",")).
               run toLogSWBody.
            end.
            find first comm.swbody where comm.swbody.rmz = remtrz.remtrz and comm.swbody.type  = "A" and comm.swbody.swfield = "32" no-lock no-error.
            if avail comm.swbody then do:
               v-tmpdec = v-tmpdec + deci(replace(substr(comm.swbody.content[1],10),',','.')).
            end.
            /*
            здесь выполнить заполение поля 33B  это сумам полей 32А+71F
            33B Currency/Instructed Amount 3!a15d
            */
            find first crc where crc.crc = remtrz.tcrc no-lock no-error.
            find first comm.swbody where comm.swbody.rmz = remtrz.remtrz and comm.swbody.type  = "B" and comm.swbody.swfield = "33" exclusive-lock no-error.
            if avail comm.swbody then do:
               comm.swbody.content[1] = crc.code + trim(replace(string(v-tmpdec,">>>>>>>>>>>>>>>9.99"),".",",")).
            end.
          end.
          create que.
          que.remtrz = remtrz.remtrz.
          que.pid = "IBH".
          que.rcid = recid(remtrz) .
          que.ptype = remtrz.ptype.
          if v-reterr = 0 then  do:
              run savelog("IBHtrz_ps", "185. " + remtrz.remtrz).
              que.rcod = '0' .
          end. else do:
              run savelog("IBHtrz_ps", "188. " + remtrz.remtrz).
              que.rcod = '1'.
              que.pvar = string(v-reterr).
          end.
          if remtrz.ptype = 'M' then do:
              find first bank.arp where bank.arp.arp = remtrz.racc /*v-ba*/ no-lock no-error .
              if avail bank.arp then do:
                 run savelog("IBHtrz_ps", "195. " + remtrz.remtrz).
                 remtrz.rsub = 'arp'.
                 remtrz.cracc = remtrz.racc /*v-ba*/ .
                 remtrz.crgl  = arp.gl.
              end.
          end.
          if remtrz.ptype = 'M' and ( remtrz.cracc eq '' or remtrz.crgl = 0 ) then do:
             run savelog("IBHtrz_ps", "202. " + remtrz.remtrz).
             que.rcod = '2'.
          end.
          que.con  = 'F'.
          que.dp   = today.
          que.tp   = time.
          if v-pri = 'E' then do:
             run savelog("IBHtrz_ps", "209. " + remtrz.remtrz + " 9999").
             que.pri = 9999.
          end. else if v-pri = 'U' then do:
             run savelog("IBHtrz_ps", "212. " + remtrz.remtrz + " 19999").
             que.pri = 19999.
          end. else do:
             run savelog("IBHtrz_ps", "215. " + remtrz.remtrz + " 29999").
             que.pri = 29999 .
          end.
       end.
    end.
end.
run savelog("IBHtrz_ps", "221. Конец...").


procedure toLogSWBody:
   run savelog("swiftmaket",  "IBHtrz_ps.p  swbody.rmz         " + comm.swbody.rmz) no-error.
   run savelog("swiftmaket",  "IBHtrz_ps.p  swbody.swfield     " + comm.swbody.swfield) no-error.
   run savelog("swiftmaket",  "IBHtrz_ps.p  swbody.type        " + comm.swbody.type) no-error.
   run savelog("swiftmaket",  "IBHtrz_ps.p  swbody.content[1]  " + comm.swbody.content[1]) no-error.
   run savelog("swiftmaket",  "IBHtrz_ps.p  swbody.content[2]  " + comm.swbody.content[2]) no-error.
   run savelog("swiftmaket",  "IBHtrz_ps.p  swbody.content[3]  " + comm.swbody.content[3]) no-error.
   run savelog("swiftmaket",  "IBHtrz_ps.p  swbody.content[4]  " + comm.swbody.content[4]) no-error.
   run savelog("swiftmaket",  "IBHtrz_ps.p  swbody.content[5]  " + comm.swbody.content[5]) no-error.
   run savelog("swiftmaket",  "IBHtrz_ps.p  swbody.content[6]  " + comm.swbody.content[6]) no-error.
end procedure.