/* 2ltrx_uv.i
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Для валютных платежей на очереди 2L определяется, нужно ли блокировать сумму на транзитном счете
            или счете клиента, или это возвратный платеж
        По этим данным проводка делается на счет клиента или транзитный счет, после проводки выдается уведомление
 * RUN

 * CALLER
        2ltrx.i
 * SCRIPT

 * INHERIT

 * MENU
        5-9-3
 * AUTHOR
        01.11.2002 kanat - stdoc_out.i
 * CHANGES
        08.10.2003 nadejda  - файл stdoc_out разбит на 2 части, выдача уведомлений перенесена в 2ltrx_out.i
        11.11.2003 nadejda  - сделала поиск транзитного счета с учетом статуса клиента ФЛ/ЮЛ
        12.07.2004 saltanat - включена переменная mustvalcon, которая является признаком отношения суммы к Вал.Контролю
        14.07.2004 saltanat - включена проверка через сист. настр. файл для тенговых платежей явл. ли транзитными платежами
        31/05/06 marinav - rko -> spf
        26.12.2008 galina - убрала проверку наличия признака rmzval в sub-cod
                            добавила проверку block_choice = ?
        26.08.2009 galina - не спрашиваем о возврате платежа
        18.05.2012 aigul - тз962 - ПОДТЯГИВАТЬ АРП СЧЕТА
*/

{vc.i}
{vc-crosscurs.i}

DEFINE STREAM s1.
def var out as char.
def var return_choice as logical init false.
def var block_choice as logical init false.
def var blockvc_choice as logical init false.
def var state_choice as logical init false.
def var cbreg_choice as logical init false.
def var contract_number as integer.
def var vc_docs as integer.
def var vc_knp as char.
def var vc_remcrc as integer.
def var vc_kurs_plat like ncrc.rate[1].
def var vc_kurs_contr like ncrc.rate[1].
def var vc_kross like vcdocs.cursdoc-con.
def var vc_dnnum as char format "x(30)".
def var vc_cifname as char format "x(100)".
def var s_remtrz_sum as char.
def var remtrz_usd like remtrz.amt.
def var s_remtrz_usd as char.
def new shared var s-contract like vccontrs.contract.
def new shared var s-vcourbank as char.
def new shared var s-cif like cif.cif.
def var vc_remknp as char format "x(3)".
def var vc_crcdes as char.
def var vc_crccod as char.
def var vc_blkgl as integer init 286060.
def var v-proftcn as char.
def var v-racc as char.
def var v-transit as logical.
def var v-depname as char.
def var v-bensts as char.
def var mustvalcon as logical init false.

if remtrz.fcrc = 1 then do:
    find sysc where sysc.sysc = "vctran" no-lock no-error.
    if avail sysc then if (remtrz.tcrc = 1) and (lookup(v-arp, sysc.chval) > 0) then mustvalcon = true.
end.
else do:
    find first arp where arp.gl = 223730 and arp.crc = remtrz.fcrc and arp.arp = v-arp no-lock no-error.
    if avail arp then mustvalcon = true.
end.

if (remtrz.tcrc <> 1 or mustvalcon) and (lookup(remtrz.rsub, "cif,arp,card,valcon,vcon") > 0 or remtrz.rsub begins "spf-") then do:

  /* счет ГК транзитных счетов */
  find sysc where sysc.sysc = "vc-arp" no-lock no-error.
  if avail sysc then vc_blkgl = sysc.inval.

  /* Департамент текущего офицера */
  find ofc where ofc.ofc = g-ofc no-lock no-error.
  v-proftcn = ofc.titcd.

    /*
  MESSAGE skip " Зачисление возвратного платежа по импортному контракту?" skip(1)
    VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
    TITLE " ВАЛЮТНЫЙ КОНТРОЛЬ - ВОЗВРАТ " UPDATE return_choice.

  if return_choice then do:
    v-racc = v-arp.*/

    /* а вдруг указали-то транзитный счет? */
/*    if v-cif = "arp" then do:
      find arp where arp.arp = v-arp no-lock no-error.
      if arp.gl = vc_blkgl then do:
        find sub-cod where sub-cod.sub = "arp" and sub-cod.acc = arp.arp and
                           sub-cod.d-cod = "sproftcn" no-lock no-error.
        if avail sub-cod and sub-cod.ccode <> "msc" then do:
          find codfr where codfr.codfr = "sproftcn" and codfr.code = sub-cod.ccode no-lock no-error.
          v-depname = codfr.name[1].
        end.
        else v-depname = "Неизвестный департамент".

        state_choice = no.
        MESSAGE skip " Для зачисления суммы указан транзитный счет валютного контроля департамента : " v-depname
                skip(1) " Зачислить сумму на транзитный счет ?"
            VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
            TITLE " ВНИМАНИЕ ! "
            UPDATE block_choice.
        if not block_choice or block_choice = ? then return.*/
        /* ну значит это является блокировкой на транзитном счете */
    /*     end.
    end.

  end.
  else do:*/

    /*  проверим, какой счет был указан как счет получателя */
    if v-cif = "arp" then do:
      find arp where arp.arp = v-arp no-lock no-error.
      block_choice = (avail arp) and
                     (arp.gl = vc_blkgl) and
                     (arp.crc = remtrz.tcrc) and
                     (can-find (sub-cod where sub-cod.sub = "arp" and sub-cod.acc = arp.arp and
                           sub-cod.d-cod = "sproftcn" and sub-cod.ccode = v-proftcn no-lock)).
    end.
    /* если был указан транзитный счет валкона - не спрашивать об этом */
    if not block_choice or block_choice = ?  then do:
      MESSAGE skip    " Сумма подлежит блокировке на ТРАНЗИТНОМ счете валютного контроля ?"
              skip(1) " (В случае ответа ""Нет"" и указании клиентского счета~n сумма будет заблокирована на счете клиента до АКЦЕПТА платежа)"
          skip(1) VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
          TITLE " ВАЛЮТНЫЙ КОНТРОЛЬ - КОНТРОЛЬ ДОКУМЕНТОВ "
          UPDATE block_choice.
    end.

    if block_choice then do:
      /* блокируем на транзитном счете */

      /* найти признак ФЛ/ЮЛ по КБе платежа - для определения нужного транзитного счета */
      find sub-cod where sub-cod.sub = "rmz" and sub-cod.acc = remtrz.remtrz and sub-cod.d-cod = "eknp" no-lock no-error.
      v-bensts = trim(sub-cod.rcode).
      if v-bensts <> "" and num-entries (v-bensts) >= 2 then do:
        v-bensts = trim(entry(2, v-bensts)).
        if length(v-bensts) < 2 then v-bensts = "7". /* если КБе не проставлен - считаем юрлицом */
                             else v-bensts = substr(v-bensts, 2).
      end.
      else v-bensts = "7".  /* если ЕКНП не проставлены - считаем юрлицом */


      /* найти транзитный счет нужного Департамента с нужной валютой */

      if v-cif = "arp" then do:
        find arp where arp.arp = v-arp no-lock no-error.
        if not avail arp then do:
          message skip " Указанный счет не найден!~n Сумма будет зачислена на соответствующий платежу транзитный счет."
                  skip(1) view-as alert-box title "".
          v-arp = "".
        end.
        else do:
          if arp.gl <> vc_blkgl then do:
            message skip " Указанный счет не является транзитным счетом валютного контроля!~n Сумма будет зачислена на соответствующий платежу транзитный счет."
                    skip(1) view-as alert-box title "".
            v-arp = "".
          end.
          else do:
            if arp.crc <> remtrz.tcrc then do:
              message skip " Валюта указанного счета не совпадает с валютой платежа!~n Сумма будет зачислена на соответствующий платежу транзитный счет."
                      skip(1) view-as alert-box title "".
              v-arp = "".
            end.
            else do:
              find sub-cod where sub-cod.sub = "arp" and sub-cod.acc = arp.arp and sub-cod.d-cod = "sproftcn" no-lock no-error.
              if not avail sub-cod or sub-cod.ccode <> v-proftcn then do:
                message skip " Указанный счет не принадлежит Вашему департаменту!~n Сумма будет зачислена на соответствующий платежу транзитный счет."
                        skip(1) view-as alert-box title "".
                v-arp = "".
              end.
              else do:
                find sub-cod where sub-cod.sub = "arp" and sub-cod.acc = arp.arp and sub-cod.d-cod = "secek" no-lock no-error.
                if not avail sub-cod or (sub-cod.ccode = "9" and v-bensts <> "9") or (sub-cod.ccode <> "9" and v-bensts = "9") then do:
                  message skip " Признак ФЛ/ЮЛ указанного счета не совпадает с КБе платежа!~n Сумма будет зачислена на соответствующий платежу транзитный счет."
                          skip(1) view-as alert-box title "".
                  v-arp = "".
                end.
              end.
            end.
          end.
        end.
      end.
      else do:
        v-cif = "arp".
        v-arp = "".
      end.

      if v-arp = "" then do:
        /* найти транзитный счет */
        for each arp where arp.gl = vc_blkgl and arp.crc = remtrz.tcrc and
                 can-find (sub-cod where sub-cod.sub = "arp" and sub-cod.acc = arp.arp and
                           sub-cod.d-cod = "sproftcn" and sub-cod.ccode = v-proftcn no-lock) no-lock:
          /* ищем для ФЛ/ЮЛ */
          find sub-cod where sub-cod.sub = "arp" and sub-cod.acc = arp.arp and sub-cod.d-cod = "secek" no-lock no-error.
          if (sub-cod.ccode = "9" and v-bensts = "9") or (sub-cod.ccode <> "9" and v-bensts <> "9") then do:
            v-arp = arp.arp.
            leave.
          end.
        end.

        if v-arp = "" then do:
           message skip " Не найден транзитный счет Вашего департамента~n в валюте данного платежа или для ФЛ/ЮЛ !"
                   skip(1) view-as alert-box title " ОШИБКА! ".
           return.
        end.


      end.
    end.
    else do:

      /* а вдруг указали-то транзитный счет, а на вопрос о блокировке ответили НЕТ ? */
      if v-cif = "arp" then do:
        find arp where arp.arp = v-arp no-lock no-error.
        if arp.gl = vc_blkgl then do:
          /* проверка на совпадение департамента */
          find sub-cod where sub-cod.sub = "arp" and sub-cod.acc = arp.arp and
                             sub-cod.d-cod = "sproftcn" no-lock no-error.
          if not avail sub-cod or sub-cod.ccode <> v-proftcn then do:
            if avail sub-cod then do:
              find codfr where codfr.codfr = "sproftcn" and codfr.code = sub-cod.ccode no-lock no-error.
              v-depname = codfr.name[1].
            end.
            else v-depname = "Неизвестный департамент".

            state_choice = no.
            MESSAGE skip " Для зачисления суммы указан транзитный счет валютного контроля департамента : " v-depname
                    skip(1) " Зачислить сумму на указанный счет ?"
                VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
                TITLE " ВНИМАНИЕ ! "
                UPDATE block_choice.
            if not block_choice or block_choice = ? then return.
          end.

          /* проверка на совпадение статуса ФЛ/ЮЛ */
          find sub-cod where sub-cod.sub = "arp" and sub-cod.acc = arp.arp and sub-cod.d-cod = "secek" no-lock no-error.
          if (sub-cod.ccode = "9" and v-bensts <> "9") or (sub-cod.ccode <> "9" and v-bensts = "9") then do:
            state_choice = no.
            MESSAGE skip " Для зачисления суммы указан транзитный счет валютного контроля~n с признаком ФЛ/ЮЛ, не совпадающим с Кбе платежа !"
                    skip(1) " Зачислить сумму на указанный счет ?"
                VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
                TITLE " ВНИМАНИЕ ! "
                UPDATE block_choice.
            if not block_choice or block_choice = ? then return.
          end.
        end.
      end.
      else do:
        /* хоть и не на транзитном счете, а все равно заблокируем - наложим специнструкцию до акцепта */
        find aaa where aaa.aaa = v-arp no-lock no-error.
        blockvc_choice = (avail aaa).
      end.
    end.
  end.
/*end.*/






