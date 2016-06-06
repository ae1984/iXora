/* spremtrz.p
 * MODULE
        Платежная система
 * DESCRIPTION
        Штамп проводок в 5.3.*
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
        20.11.2001 by sasco - для статуса в cursts.sts = "BAC"
                              подождать контроля в 2.4.1.1
        28.11.2003 sasco  - вместо МТ100 - МТ103
        12.12.2003 sasco  - переделал сообщение о свифте на более понятное
        27.12.2005 nataly - для валютных переводов ФЛ добавила проверку на заполнение справочников zdcavail,zsgavail,iso3166.
        06.10.2008 galina - записываем в поле remtrz.vcact кто проставил штамп
        27.07.2011 aigul  - добавила уведомления для платежей
        08.08.2011 aigul  - добавила бд COMM
        26.01.2012 aigul  - исправила поиск рмз
        31.05.2012 aigul  - сделала исключения для ГК 2206-2217
        19/06/2012 Luiza  - сохраняем значение remtrz.odr
        26.06.2012 damir  - закоментил заполнение swift макета, RKO_LOGI = no.
*/

def shared var s-remtrz like remtrz.remtrz.
def var c-gl like gl.gl.
def var v-yes as log initial true format "Да/Нет".
def buffer sub-cod2 for sub-cod.
def var v-chk as logical initial yes.
def var v-docs as int.
{lgps.i}
/**aigul*/
def var v-rez as char.
def var v-fiz as char.
def var v-sts as logical initial no.
def var  v-sum-usd as decimal.
def var v-knp-chk as char.
def var  v-coutry as char.
def buffer b-ncrchis for ncrchis.
def buffer b-vcdocs for vcdocs.
def buffer b-vccontrs for vccontrs.
def var v-ordord as char.
find first remtrz where remtrz.remtrz = s-remtrz no-lock no-error.
if avail remtrz and remtrz.tcrc <> 1 then do:
    v-ordord = remtrz.ord.
    v-sum-usd = 0.
    find last ncrchis where ncrchis.rdt <= remtrz.rdt and ncrchis.crc = 2 no-lock no-error.
    if avail ncrchis then do:
        find last b-ncrchis where b-ncrchis.rdt <= remtrz.rdt and b-ncrchis.crc = remtrz.tcrc no-lock
        no-error.
        if avail b-ncrchis then v-sum-usd = remtrz.amt * b-ncrchis.rate[1] / ncrchis.rate[1].
    end.
    v-knp-chk = "".
    find first sub-cod where sub-cod.sub = 'rmz' and sub-cod.acc = s-remtrz
                and sub-cod.d-cod = 'iso3166' no-lock no-error.
                if avail sub-cod then v-coutry = sub-cod.ccode.
    find first sub-cod where sub-cod.sub = 'rmz' and sub-cod.acc = s-remtrz
    and sub-cod.d-cod = 'eknp' no-lock no-error.
    if avail sub-cod then do:
        v-rez = substr(sub-cod.rcode,1,1).
        v-fiz = substr(sub-cod.rcode,2,1).
        v-knp-chk = substr(sub-cod.rcode,7,3).
        v-sts = no.

            if (v-sum-usd >= 100000 and remtrz.drgl = 220520) and
            (v-knp-chk = '510' or v-knp-chk = '520'  or v-knp-chk = '540' or  v-knp-chk matches '8*')
            then v-sts = yes.
            if (v-sum-usd >= 500000 and remtrz.drgl = 220520) and (v-knp-chk = '722' or  v-knp-chk ='560')
            then v-sts = yes.
            if
            (
            (v-knp-chk = '311' or v-knp-chk = '321')
            and
            (substr(sub-cod.rcode,1,1) = "1" and (substr(sub-cod.rcode,2,1) = "9" or substr(sub-cod.rcode,2,1) = "7" ))
            and
            (substr(sub-cod.rcode,4,1) = "1" and (substr(sub-cod.rcode,5,1) = "9" or substr(sub-cod.rcode,5,1) = "7" ))
            and v-coutry <> "KZ"
            )
            then do:
                v-sts = yes.
            end.
            if (v-sts and (remtrz.drgl = 220520 or remtrz.drgl = 220420
                        or substr(string(remtrz.drgl),1,4) = '2206' or substr(string(remtrz.drgl),1,4) = '2207'
                        or substr(string(remtrz.drgl),1,4) = '2215' or substr(string(remtrz.drgl),1,4) = '2217'
                        or substr(string(remtrz.drgl),1,4) = '2219'
                        or substr(string(remtrz.drgl),1,4) = '2203')) then do:
                message "Данный перевод подлежит уведомлению НБРК," skip
                "подтверждаете регистрацию контракта и платежа в 9-1" view-as alert-box error buttons yes-no title " ВНИМАНИЕ ! " update v-chk.
                if v-chk = no then do:
                    message "Акцепт не возможен!" view-as alert-box.

                    return.
                end.
                if v-chk then do:
                    find first aaa where aaa.aaa = remtrz.sacc no-lock no-error.
                    if avail aaa then do:
                        find first vccontrs where vccontrs.cif = aaa.cif no-lock no-error.
                        if avail vccontrs then do:
                            for each b-vccontrs no-lock:
                                for each vcdocs where vcdocs.contract = vccontrs.contract no-lock:
                                    find first b-vcdocs where b-vcdocs.dnnum = substr(remtrz.remtrz,4,6) no-lock no-error.
                                    if avail b-vcdocs then do:
                                        if b-vcdocs.pcrc <> remtrz.fcrc or b-vcdocs.sum <> remtrz.amt or remtrz.rdt <> b-vcdocs.dndate then do:
                                            message "Данные проводки не соответсвуют данным платежа в контракте!" skip
                                            "Операция завершена!" view-as alert-box.
                                            return.
                                        end.
                                    end.
                                    if not avail b-vcdocs then do:
                                        find first b-vcdocs where b-vcdocs.dnnum = substr(remtrz.remtrz,5,6) no-lock no-error.
                                        if avail b-vcdocs then do:
                                            if b-vcdocs.pcrc <> remtrz.fcrc or b-vcdocs.sum <> remtrz.amt or remtrz.rdt <> b-vcdocs.dndate then do:
                                                message "Данные проводки не соответсвуют данным платежа в контракте!" skip
                                                "Операция завершена!" view-as alert-box.
                                                return.
                                            end.
                                        end.
                                        if not avail b-vcdocs then do:
                                            message "Не найден документ в контракте!" view-as alert-box.
                                            return.
                                        end.
                                    end.
                                end.
                            end.
                        end.
                        if not avail vccontrs then do:
                            message "Не найден контракт! Операция завершена!" view-as alert-box.
                            return.
                        end.
                    end.
                end.
            end.

    end.
end.
/**/
find sysc where sysc.sysc = "CASHGL".
c-gl = sysc.inval.
find first remtrz where remtrz.remtrz = s-remtrz.
if remtrz.jh1 eq ? then do:
 message " Сделайте проводку !!".
 bell. bell.
end.
else do:

 /* ----------------   20.11.2001 by sasco ----------------------------- */
 find cursts where cursts.acc = s-remtrz and cursts.sub = "rmz"
      no-lock no-error.
 if avail cursts then
    if cursts.sts = "bac" or cursts.sts = "bap" then do:
         message "Документ должен проконтролировать старший менеджер (в 2.4.1.1)".
         pause 7.
         undo.
    end.
 /* ----------------   20.11.2001          ----------------------------- */
  /* sasco */


/*---------------------------------------------------------------------------------*/
  {global.i}
  {get-dep.i}
  {rcomm-txb.i}

  if RKO_VALOUT() then
  do:
      /*update "Внимание! Валютный платеж!" skip RKO_LOGI label "Заполнить свифт-макет?"
      with side-labels centered row 5 frame getrkochfr.
      hide frame getrkochfr.*/

      /* RKO_LOGI: yes = SWIFT  | source = RKO    */
      /*           no  = branch | source = RKOTXB */
      RKO_LOGI = no.
      if not RKO_LOGI then
      do:
       if remtrz.source = "O" then do:
          remtrz.source = "RKOTXB".
          v-text = remtrz.remtrz + ", Режим 1-й проводки. Источник remtrz изменен: O -> RKOTXB".
          run lgps.
       end.
      end.
  end.


  if RKO_VALOUT()
  then do:
       hide all.

       message 'Исходящий перевод (СПФ)' skip
               'Введите данные в форму МТ103'
               view-as alert-box title 'Внимание'.
       run out-mt100.
       pause 0.

       if remtrz.source = "O" then do:
          remtrz.source = "RKO".
          v-text = remtrz.remtrz + ", Режим 1-й проводки (" + g-ofc + "). Источник remtrz изменен: O -> RKO".
          run lgps.
       end.

       hide all.
  end.


 find sub-cod where sub-cod.sub = 'rmz' and sub-cod.acc = s-remtrz and sub-cod.d-cod = 'eknp' no-lock no-error.
 if avail sub-cod and trim(substr(sub-cod.rcode,2,1)) = '9' then do:
  if remtrz.tcrc <> 1 or remtrz.fcrc <> 1
  then do:
    find sub-cod where sub-cod.sub = 'rmz' and sub-cod.acc = s-remtrz and  d-cod = 'zdcavail' no-lock no-error.
    if not avail sub-cod or sub-cod.ccod = 'msc' then do:
      message 'Не заполнен справочник "Наличие документа обоснования!"'  view-as  alert-box.
      undo,retry.
    end.
    if avail sub-cod and sub-cod.ccod = '2' then do:
     find sub-cod2 where sub-cod2.sub = 'rmz' and sub-cod2.acc = s-remtrz and  sub-cod2.d-cod = 'zsgavail'
          no-lock no-error.
      if not avail sub-cod2 or  sub-cod2.ccod <> '1' then do:
       message 'Не заполнен справочник zsgavail!'  view-as  alert-box.
       undo,retry.
      end.
    end.

    find sub-cod where sub-cod.sub = 'rmz' and sub-cod.acc = s-remtrz and  sub-cod.d-cod = 'iso3166' no-lock no-error.
    if not avail sub-cod or sub-cod.ccod = 'msc' then do:
      message 'Не заполнен справочник стран!'  view-as  alert-box.
      undo,retry.
    end.

  end.
 end.

 message " Штамповать ? " update v-yes.
 if v-yes then do:
 find jh where jh.jh = remtrz.jh1 no-error.

/*
  if jh.sts eq 6 then do:
   Message " Stamped already !! " . bell . pause .
   return .
  end.
*/

for each jl of jh no-lock :
 if jl.sts lt 5 then do:
   Message " Ваучер еще не напечатан !!! " . bell . pause .
   return .
 end.
end.

 v-yes = false.
 for each jl of jh.
  if jl.gl = c-gl then v-yes = true.
 end.

 if available jh and not v-yes then do transaction :
   for each jl of jh exclusive-lock :
    jl.sts = 6.
   end.
   jh.sts = 6.

 find first que where que.remtrz = remtrz.remtrz exclusive-lock no-error .
 if avail que and que.pid = m_pid then do :

  v-text = "1 проводка отштампована  " + remtrz.remtrz  .
  run lgps.
  que.rcod = "0".
  que.con = "F".
  que.dp = today.
  que.tp = time.

  /*29.10.2008 galina запишем кто проставил валютный контроль*/
  find current remtrz exclusive-lock.
  remtrz.vcact = g-ofc + "," + string(g-today,'99/99/9999').
  find current remtrz no-lock.
 /**/

 end.
end.
 else if v-yes then do transaction :
  bell. bell.
  message " Кассовая проводка !!!! " .
  pause 2.
 find first que where que.remtrz = remtrz.remtrz exclusive-lock no-error .

 if avail que and que.pid = m_pid and que.con ne "F" then do :
  v-text = "1 проводка отштампована -> кассиру " +   remtrz.remtrz  .
  run lgps.
  que.rcod = "10".
  que.con = "F".
  que.dp = today.
  que.tp = time.

  /*29.10.2008 galina запишем кто проставил валютный контроль*/
  find current remtrz exclusive-lock.
  remtrz.vcact = g-ofc + "," + string(g-today,'99/99/9999').
  if remtrz.ord = ? then remtrz.ord = v-ordord.

  if remtrz.ord = ? then do:
     run mail("IXqueuerr@fortebank.com", "bankadm@metrocombank.kz", "Поле ORD = ?", "spremtrz.p 305", "1", "", "").
  end.

  find current remtrz no-lock.
 /**/

 end.
 end.
 else do:
   message " Нет проводки !!!".
   bell. bell.
 end.
 end.
end.
