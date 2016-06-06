/* CImain_ps.p
 * MODULE
        Платежная система
 * DESCRIPTION
        Процесс-селектор CI
 * RUN

 * CALLER
        CI_ps.p
 * SCRIPT

 * INHERIT

 * MENU
        5.1
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        12.03.2003 sasco    - обработка полочек x-pref и x-name
        02.03.2004 nadejda  - обработка входящих платежей органов Казначейства для филиалов - на полочку excheq
        12.07.2004 saltanat - добавила для полочки valcon заполнение справочника rmzval
        02.09.2004 dpuchkov - перекомпиляция.
        29.10.2004 sasco    - проверка на РНН
        25.11.2004 sasco    - не проверять наименование для платежей на сумму < 10000 KZT
        26.08.2005 kanat    - добавил условие для тенговых платежей - если валюта счета не равна валюте платежа -> уходят на полочку 2L
        09.02.2006 marinav  - проверка на РНН и name для филиалов клиента (платежи на филиал клиента)
        01/06/06/ marinav -   rko -> spf
        04/10/06   tsoy усли платежи карточек интернет то не садим на 2l
        02/12/2008 galina - для полочки valcon - сверка наименования
        30/03/2010 galina - обработка для фин.мониторинга согласно ТЗ 623 от 19/02/2010
        19/04/2010 galina - добавила для фин.мониторинга согласно ТЗ 650 от 19/02/2010
        12/05/2010 galina - добавила пополнение счета на сумму >= 7000000 для фин.мониторинга
        04.06.10 marinav- изменился список казначейских платежей , условие по дебиторам
        28/07/2010 galina - добавила переводы благотвор.организаций для фин.мониторинга
        21/09/2010 galina - online запрос по спискам террористов
        27.09.2010 marinav - дебиторов на полочку
        09/11/2010 madiyar - отключаем фин. мониторинг (пока только закомментил, на всякий случай)
        25.01.2011 marinav - изменения в связи с переходом на БИН/ИИН
        10.01.2012 Luiza   - выполняем проверку наименования для всех, а не только для платежей на сумму >= 10000 KZT
        10.01.2012 Luiza   - если платеж поступил на счет 220530 проверку на совпадение наименования не выполняем
        03.05.2012 aigul - добавила списание комиссии за ЭЦП
        08.08.2012 evseev - ТЗ-1344
        08.10.2012 evseev - ТЗ-797
        12/10/2012 madiyar - обработка статуса 2 kfmAMLOnline
        21.12.2012 k.gitalov - форматирование + добавил NO-WAIT
        20.12.2012 evseev - ТЗ-1622
        03.01.2013 evseev - перекомпиляция
        31.01.2013 evseev - tz-1647
        10.07.2013 evseev - tz-1892

*/


{global.i}
{lgps.i}

{name-compare.i}
{comm-rnn.i}
{findstr.i}
{chbin.i}

def var v-s1 as char. /* наименование клиента */
def var v-s2 as char. /* РНН клиента */
def var v-bbbb as char.
def var i as int.
def var gv-s1 as char NO-UNDO init "".
def var tmpi as int NO-UNDO.
def var rnnind as int NO-UNDO.
def var tmpd as decimal NO-UNDO.
define variable rmz_rnn as character.

def var v-kartel as char init "011999832".

def var linjl like remtrz.cracc.
def var v-bnk as logical.
def var must_valcon as logical.
def var v-excheq as decimal init 3000000.  /* входящие платежи Казначейства Минфина с суммой больше этой попадают на доп.контроль */

def var v-prefix as char.
def var bad-rnn as logical.
def var v-monamt as deci no-undo.
def var v-monamt2 as deci no-undo.
def var v-str as char no-undo.
def buffer b-remtrz for remtrz.
def var v-sumkz as decimal no-undo.
def var v-rsub as char.

bad-rnn = no.

function DelSpecChar returns char (input parm1 as char).
  def var v-tmpstr as char.
  v-tmpstr = parm1.
  v-tmpstr = replace(v-tmpstr,'_','').
  v-tmpstr = replace(v-tmpstr,'(','').
  v-tmpstr = replace(v-tmpstr,')','').
  v-tmpstr = replace(v-tmpstr,'=','').
  v-tmpstr = replace(v-tmpstr,"'",'').
  v-tmpstr = replace(v-tmpstr,'+','').
  v-tmpstr = replace(v-tmpstr,':','').
  v-tmpstr = replace(v-tmpstr,'?','').
  v-tmpstr = replace(v-tmpstr,'!','').
  v-tmpstr = replace(v-tmpstr,'"','').
  v-tmpstr = replace(v-tmpstr,'%','').
  v-tmpstr = replace(v-tmpstr,'&','').
  v-tmpstr = replace(v-tmpstr,'*','').
  v-tmpstr = replace(v-tmpstr,'<','').
  v-tmpstr = replace(v-tmpstr,'>','').
  v-tmpstr = replace(v-tmpstr,';','').
  v-tmpstr = replace(v-tmpstr,'@','').
  v-tmpstr = replace(v-tmpstr,'#','').

  return v-tmpstr.
end function.


def var v-kazn as char.

find first sysc where sysc.sysc = 'kazn' no-lock no-error.
if avail sysc then v-kazn = sysc.chval.

find  sysc where sysc.sysc = "linkjl" no-lock  no-error.
if avail sysc then linjl = sysc.chval.

find sysc where sysc.sysc = "ourbnk" no-lock no-error.
if avail sysc then do:
  if sysc.chval = "TXB00" then v-bnk = false.
  else v-bnk = true.
end.
else  v-bnk = false.

do transaction :
    find first que where que.pid = m_pid and que.con = "W" use-index fprc  exclusive-lock no-error NO-WAIT.
    if avail que then do:
        que.dw = today.
        que.tw = time.
        que.con = "P".
        find first remtrz where remtrz.remtrz = que.remtrz exclusive-lock no-error NO-WAIT.
        if available remtrz then do:
            run savelog("CImain_ps","105. " + remtrz.remtrz + " " + remtrz.ptype + " " + remtrz.rsub + " " + string(remtrz.tcrc ) + " " + remtrz.ref).
            find jh where jh.jh = remtrz.jh1 no-lock no-error.
            if not available jh then do :
                que.dp = today.
                que.tp = time.
                que.con = "F".
                que.rcod = "10".
                v-text = "Ошибка ! 1 проводка не найдена для " + remtrz.remtrz.
                run lgps.
                return.
            end.
            if remtrz.crgl = 220530 and remtrz.sacc <> "KZ82470142860A000100" then do:
               que.dp = today.
               que.tp = time.
               que.con = "F".
               que.rcod = "1".
               remtrz.rsub = "x-pens".
               v-text = remtrz.remtrz + " Нельзя пополнить счет ГК 220530 со счета " + remtrz.sacc + " ! Перенос на полочку X-PENS" .
               run lgps.
               return.
            end.
            que.dp = today.
            que.tp = time.
            que.con = "F".
            must_valcon = no.
            /* обработка полочек РКО */
            if remtrz.rbank = "TXB00" then do:
                if (remtrz.ptyp = "7" and (remtrz.rsub begins "spf") and (remtrz.tcrc <> 1 or remtrz.fcrc <> 1) and remtrz.jh2 = ?) or (remtrz.ptyp = "3" and v-bnk and (not remtrz.sbank begins "TXB") and (remtrz.rsub begins "spf") and (remtrz.tcrc <> 1 or remtrz.fcrc <> 1) and remtrz.jh2 = ?) then do:
                    que.rcod = "1".
                    v-text = " Платеж " + remtrz.remtrz + " обработан. " + 'rcod = ' + que.rcod.
                    run lgps.
                    return.
                end.
            end.
            /* ОБРАБОТКА VALCON */
            if (remtrz.ptyp = "7" and (remtrz.rsub = "cif" or remtrz.rsub = "valcon") and (remtrz.tcrc <> 1 or remtrz.fcrc <> 1) and remtrz.jh2 = ?) or (remtrz.ptyp = "3" and v-bnk and (not remtrz.sbank begins "TXB") and (remtrz.rsub = "cif" or remtrz.rsub = "valcon") and (remtrz.tcrc <> 1 or remtrz.fcrc <> 1) and remtrz.jh2 = ?) then do:
                must_valcon = yes.
                remtrz.rsub = "valcon".
                que.rcod = "1".
                /* Заполнение справочника Принадлежности к Вал.контролю */
                find sub-cod where sub-cod.acc = remtrz.remtrz and sub-cod.sub = "rmz" and sub-cod.d-cod = "rmzval" no-error.
                if avail sub-cod then
                    sub-cod.ccode = "valcon".
                else do:
                    create sub-cod.
                    assign sub-cod.acc = remtrz.remtrz
                    sub-cod.sub = "rmz"
                    sub-cod.d-cod = "rmzval"
                    sub-cod.ccode = "valcon".
                end.
            end. else if (remtrz.ptype = "3" and remtrz.rsub = "cif" and (remtrz.tcrc <> 1 or remtrz.fcrc <> 1) and remtrz.jh2 = ?) then do:
                run savelog("CImain_ps","155. " + remtrz.remtrz + " " + remtrz.ptype + " " + remtrz.rsub + " " + string(remtrz.tcrc ) + " " + remtrz.ref).
                run savelog("CImain_ps","156. " + string(remtrz.jh2)).
                find first swift where swift.swift_id = int(remtrz.ref) no-lock no-error.
                if avail swift then do:
                    run savelog("CImain_ps","159. ").
                    must_valcon = yes.
                    remtrz.rsub = "valcon".
                    que.rcod = "1".
                    /* Заполнение справочника Принадлежности к Вал.контролю */
                    find sub-cod where sub-cod.acc = remtrz.remtrz and sub-cod.sub = "rmz" and sub-cod.d-cod = "rmzval" no-error.
                    if avail sub-cod then
                        sub-cod.ccode = "valcon".
                    else do:
                        create sub-cod.
                        assign sub-cod.acc = remtrz.remtrz
                        sub-cod.sub = "rmz"
                        sub-cod.d-cod = "rmzval"
                        sub-cod.ccode = "valcon".
                    end.
                end.
            end. else do:
                /* входящие платежи органов Казначейства должны пойти на полочку excheq */
                if remtrz.ptype = "3" then do :
                    /* найти минимальную сумму для полочки excheq */
                    find sysc where sysc.sysc = "EXCHEQ" no-lock no-error.
                    if avail sysc then v-excheq = sysc.deval.
                    find bankl where bankl.bank = remtrz.sbank no-lock no-error.
                    if avail bankl and bankl.name matches "*казнач*" and lookup(remtrz.sacc, v-kazn) > 0 and remtrz.amt > v-excheq then do:
                        remtrz.crgl = 0 .
                        remtrz.rsub = "excheq".
                        v-text = remtrz.remtrz + " Контроль платежных документов органов казначейства Министерства Финансов".
                        run lgps.
                    end.
                end.
                /* для полочек кроме excheq, valcon - сверка наименования для полочки valcon - сверка наименования*/
                /*if lookup(remtrz.rsub, "excheq,valcon") = 0 then do:*/
                if lookup(remtrz.rsub, "excheq") = 0 then do:
                    /* -------------------------------------------------------------*/
                    /* sasco - сверка формы собственности и наименования получателя */
                    /* только для платежей <!---с типом = "7"----> и валютой тенге  */
                    /* -------------------------------------------------------------*/
                    find first aaa where aaa.aaa = remtrz.racc no-lock no-error.
                    /*if not avail aaa then remtrz.rsub = "x-name".*/
                    if avail aaa and (remtrz.ptyp = "7" or remtrz.ptyp = "3") and aaa.crc = 1 then do:
                        find cif where cif.cif = aaa.cif no-lock no-error.
                        if not avail cif then leave.
                        rmz_rnn = substr((trim(remtrz.bn[1]) + trim(remtrz.bn[2]) + trim(remtrz.bn[3])) ,index((trim(remtrz.bn[1]) + trim(remtrz.bn[2]) + trim(remtrz.bn[3])),"/RNN/") + 5, 12 ) no-error.
                        /* sasco Проверка РНН --> */
                        if v-bin = no then do:
                           if trim(cif.jss) ne rmz_rnn then do :
                              find first clfilials where clfilials.cif = cif.cif and clfilials.rnn = rmz_rnn no-lock no-error.
                              if not avail clfilials then do:
                                 v-text = remtrz.remtrz + " Ошибка в РНН: в платеже " + rmz_rnn + " у клиента " + cif.jss.
                                 run lgps.
                                 bad-rnn = yes.
                              end.
                           end.
                        end. else do:
                           /*if trim(cif.bin) ne rmz_rnn then do :
                               find first clfilials where clfilials.cif = cif.cif and clfilials.rnn = rmz_rnn no-lock no-error.
                               if not avail clfilials then do:
                                   v-text = remtrz.remtrz + " Ошибка в ИИН/БИН: в платеже " + rmz_rnn + " у клиента " + cif.bin.
                                   run lgps.
                                   bad-rnn = yes.
                               end.
                           end.*/
                           if cif.bin <> rmz_rnn then remtrz.rsub = "RNN".
                        end.
                        if length (rmz_rnn) < 12 then do:
                            if v-bin = no then v-text = remtrz.remtrz + " Ошибка в РНН: неверная длина! РНН = [" + rmz_rnn + "]".
                            else v-text = remtrz.remtrz + " Ошибка в ИИН/БИН: неверная длина! ИИН/БИН = [" + rmz_rnn + "]".
                            run lgps.
                            bad-rnn = yes.
                        end.
                        /* <-- РНН */
                        /* вытащим наименование клиента */
                        v-s1 = "".
                        do i = 1 to 3:
                            v-bbbb = trim( remtrz.bn[i] ).
                            v-s1   = v-s1 + if length( v-bbbb ) = 60 then v-bbbb else v-bbbb + " ".
                        end.
                        v-bbbb = v-s1.
                        i = r-index( v-bbbb, "/RNN/" ).
                        if i <> 0 then do:
                            v-s1 = trim( substring( v-bbbb, 1, i - 1 )).
                            v-s2 = trim( substring( v-bbbb, i + 5, 12 )).
                        end. else do:
                            v-bbbb = "".
                            do i = 1 to 3:
                                v-bbbb = v-bbbb + trim(remtrz.bn[i]).
                            end.
                            i = r-index(v-bbbb, "/RNN/").
                            if i <> 0 then do:
                                v-s1 = trim(substring(v-bbbb, 1, i - 1)).
                                v-s2 = trim(substring(v-bbbb, i + 5, 12)).
                            end.
                        end.
                        if remtrz.rsub <> "RNN" then do:
                            if remtrz.crgl <> 220530 then do:  /* Luiza если платеж поступил на счет 220530 проверку на совпадение наименования не производим */
                                /*{trim-rnn.i}*/
                                run savelog('CImain_ps', '259. ' + v-bbbb + ' ' + cif.cif + ' ' + trim(cif.name) + ' ' + trim(cif.sname) + ' ' + cif.jss + ' ' + cif.bin + ' ' + rmz_rnn).
                                if (v-bin = no and cif.jss = rmz_rnn) or (v-bin = yes and cif.bin = rmz_rnn) then do:
                                    find crc where crc.crc = remtrz.tcrc no-lock no-error.
                                    if not avail crc then find crc where crc.crc = remtrz.fcrc no-lock no-error.
                                    if avail crc then do:
                                       if crc.crc = 1 then v-sumkz = remtrz.payment. else v-sumkz = remtrz.payment * crc.rate[1].
                                       if v-sumkz > 1000000 then do:
                                          if not(v-bbbb matches '*' + trim(DelSpecChar(cif.name)) + '*') then
                                             if not(v-bbbb matches '*' + trim(DelSpecChar(cif.sname)) + '*') then remtrz.rsub = "x-name".
                                       end.
                                    end.
                                end. else do:
                                   remtrz.rsub = "x-name".
                                end.
                                if cif.type = "P" then do:
                                    if trim(cif.pref) <> "" then do:
                                       if not(v-bbbb matches '*' + trim(DelSpecChar(cif.pref)) + ' *') then do:
                                          remtrz.rsub = "x-pref".
                                       end.
                                    end.
                                end. else do:
                                    v-rsub = remtrz.rsub.
                                    find first sub-cod where sub-cod.acc = cif.cif and sub-cod.d-cod = 'lnopf' no-lock no-error.
                                    if avail sub-cod then do:
                                       find first codfr where codfr.codfr = 'lnopf' and codfr.code = sub-cod.ccode no-lock no-error .
                                       if avail codfr then do:
                                          run savelog('CImain_ps', '279. ' + v-bbbb + ' ' + codfr.name[1]).
                                          if trim(codfr.name[1]) = '' then remtrz.rsub = "x-pref".
                                          if trim(codfr.name[1]) <> '' and not(v-bbbb matches '*' + trim(DelSpecChar(codfr.name[1])) + '*') then remtrz.rsub = "x-pref".
                                       end. else remtrz.rsub = "x-pref".
                                    end. else remtrz.rsub = "x-pref".
                                    if remtrz.rsub = "x-pref" and trim(cif.pref) <> '' and v-bbbb matches '*' + trim(DelSpecChar(cif.pref)) + ' *' then do:
                                       remtrz.rsub = v-rsub.
                                    end.
                                end.
                            end.
                        end.
                        /* -  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --*/
                    end. /* avail aaa */
                    /* -------------------------------------------------------------*/
                    /* END: сверка формы собств. и наименования получателя          */
                    /* -------------------------------------------------------------*/
                end.
            end. /* обработка VALCON */
            /* проверка remtrz.rsub на 'x-pref' и 'x-name' */
            if remtrz.rsub = "RNN"  then do:
                  que.rcod = "1".
                  v-text = remtrz.remtrz + " Несоответствие ИИН/БИН клиента. Перенос на полочку RNN".
                  run lgps.
            end. else if remtrz.rsub = "x-pref" or remtrz.rsub = "x-name" then do:
                  que.rcod = "1".
                  v-text = remtrz.remtrz + " Несоответствие " + (if remtrz.rsub = "x-pref" then "формы собств. клиента. Перенос на полочку X-PREF"
                  else "наименования клиента. Перенос на полочку X-NAME" ).
                  run lgps.
            end. else if v-bin = no and bad-rnn and not(remtrz.detpay[1] matches "*Комиссия за выпуск электронной*") then do:
                remtrz.rsub = "cif".
                que.rcod = "1".
                v-text = remtrz.remtrz + " Перенос на полочку CIF".
                run lgps.
            end. else if not must_valcon then do:
                que.rcod = "0".
                if remtrz.crgl = 0 then que.rcod = "1".
                /*запрос на терроризм*/
                /*проверка бенефициара на терроризм*/
                def var v-senderNameList as char.
                def var v-benNameList as char.
                def var v-benCountry as char.
                def var v-benName as char.
                def var v-senderCountry as char.
                def var v-senderName as char.
                def var v-pttype as integer.
                def var v-errorDes as char.
                def var v-operIdOnline as char.
                def var v-operStatus as char.
                def var v-operComment as char.
                def var v-prtFLNam as char.
                def var v-prtFFNam as char.
                def var v-prtFMNam as char.
                /*****проверка на список террористов******/
                v-benCountry  = ''.
                v-benName = ''.
                v-senderCountry = ''.
                v-senderName = ''.
                v-benNameList = ''.
                v-senderNameList = ''.
                v-errorDes = ''.
                v-operIdOnline = ''.
                v-operStatus = ''.
                v-operComment = ''.
                v-prtFLNam = ''.
                v-prtFFNam = ''.
                v-prtFMNam = ''.
                find first sub-cod where sub-cod.acc = remtrz.remtrz and sub-cod.sub = "rmz" and sub-cod.d-cod = "iso3166" use-index dcod no-lock no-error .
                if avail sub-cod and sub-cod.ccode <> 'msc' then v-senderCountry = sub-cod.ccode.
                v-senderName = entry(1,trim(remtrz.ord),'/').
                find first aaa where aaa.aaa = remtrz.racc no-lock no-error.
                /*тут добавим учредителей ЮЛ*/
                if avail aaa then do:
                    find first cif where cif.cif = aaa.cif no-lock no-error.
                    if avail cif then do:
                        if cif.type = 'B' then do:
                            v-benNameList = ''.
                            if cif.cgr <> 403 then do:
                               for each founder where founder.cif = cif.cif no-lock:
                                   if v-benNameList <> '' then v-benNameList = v-benNameList + '|'.
                                   if founder.ftype = 'B' then v-benNameList = v-benNameList + founder.name.
                                   if founder.ftype = 'P' then v-benNameList = v-benNameList + trim(founder.sname) + ' ' + trim(founder.fname) + ' ' + trim(founder.mname).
                               end.
                            end.
                            if cif.cgr = 403 then do:
                                find first sub-cod where sub-cod.acc = cif.cif and sub-cod.sub = "cln" and sub-cod.d-cod = "clnchf" use-index dcod no-lock no-error.
                                if avail sub-cod and sub-cod.ccode <> 'msc' then do:
                                    if num-entries(sub-cod.rcode,' ') > 0 then v-prtFLNam = entry(1,trim(sub-cod.rcode),' ').
                                    if num-entries(sub-cod.rcode,' ') >= 2 then v-prtFFNam = entry(2,trim(sub-cod.rcode),' ').
                                    if num-entries(sub-cod.rcode,' ') >= 3 then v-prtFMNam = entry(3,trim(sub-cod.rcode),' ').
                                end.
                                if v-prtFLNam <> '' then do:
                                    if v-benNameList <> '' then v-benNameList = v-benNameList + '|'.
                                    v-benNameList = v-benNameList + v-prtFLNam + '  ' + v-prtFFNam + ' ' + v-prtFMNam.
                                end.
                            end.
                            if v-benNameList <> '' then v-benNameList = v-benNameList + '|'.
                        end.
                        if cif.cgr <> 403 then v-benName = trim(cif.prefix) + ' ' + trim(cif.name).
                        if cif.type = 'P' then v-benName = v-prtFLNam + '  ' + v-prtFFNam + ' ' + v-prtFMNam.
                        if cif.cgr <> 403 then v-benName = trim(cif.prefix) + ' ' + trim(cif.name).
                    end.
                end. else v-benName = entry(1,trim(trim(remtrz.bn[1]) + ' ' + trim(remtrz.bn[2])),'/').
                if trim(v-benName + v-benCountry + v-senderCountry + v-senderName) <> '' then do:
                    if trim(v-senderCountry) <> '' then do:
                        find first code-st where code-st.code = v-senderCountry no-lock no-error.
                        if avail code-st then v-senderCountry = code-st.cod-ch.
                    end.
                    find first pksysc where pksysc.sysc = 'kfmOn' no-lock no-error.
                    if avail pksysc and pksysc.loval then do:
                        run kfmAMLOnline(remtrz.remtrz,
                                      v-benCountry,
                                      v-benName,
                                      v-benNameList,
                                      '1',
                                      '1',
                                      v-senderCountry,
                                      v-senderName,
                                      v-senderNameList,
                                      output v-errorDes,
                                      output v-operIdOnline,
                                      output v-operStatus,
                                      output v-operComment).
                        if trim(v-errorDes) <> '' then do:
                            que.rcod = "10".
                            v-text = remtrz.remtrz + " Ошибка проверки клиента (kfmAMLOnline) ->" + v-errorDes.
                            run lgps.
                            return.
                        end.
                        if v-operStatus = '0' then do:
                            remtrz.rsub = "kfm".
                            que.rcod = "1".
                            v-text = remtrz.remtrz + " Стоп операции по совпадению со списком террористов/ИПДЛ. Перенос на полочку KFM".
                            run lgps.
                            run kfmOnlineMail(remtrz.remtrz).
                        end.
                        if v-operStatus = '2' then do:
                            remtrz.rsub = "kfm".
                            que.rcod = "1".
                            v-text = remtrz.remtrz + " Проведение операции запрещено службой Комплаенс. Перенос на полочку KFM".
                            run lgps.
                            run kfmOnlineMail(remtrz.remtrz).
                        end.

                    end.
                end.
            end. else if not must_valcon then do:
                if remtrz.crgl = 0 then do:
                    que.rcod = "1".
                    if  remtrz.racc = v-kartel then
                    if remtrz.rbank = "TXB00" then do:
                        que.rcod = "0".
                        remtrz.crgl = 287032.
                        remtrz.cracc = v-kartel.
                    end.
                    find sysc where sysc.sysc  = "CRDKZTALM" no-lock no-error.
                    if avail sysc then do:
                        if  remtrz.racc = entry(1,sysc.chval) then
                        if remtrz.rbank = "TXB00" then do:
                            que.rcod = "0".
                            remtrz.crgl = 287053.
                            remtrz.cracc = entry(1,sysc.chval).
                        end.
                        if  remtrz.racc = entry(2,sysc.chval) then
                        if remtrz.rbank = "TXB00" then do:
                            que.rcod = "0".
                            remtrz.crgl = 279930.
                            remtrz.cracc = entry(2,sysc.chval).
                        end.
                    end.
                    find sysc where sysc.sysc  = "CRDUSDALM" no-lock no-error.
                    if avail sysc then do:
                        if  remtrz.racc = entry(1,sysc.chval) then
                        if remtrz.rbank = "TXB00" then do:
                            que.rcod = "0".
                            remtrz.crgl = 287053.
                            remtrz.cracc = entry(1,sysc.chval).
                        end.
                        if  remtrz.racc = entry(2,sysc.chval) then
                        if remtrz.rbank = "TXB00" then do:
                            que.rcod = "0".
                            remtrz.crgl = 279930.
                            remtrz.cracc = entry(2,sysc.chval).
                        end.
                    end.
                end.
                else if remtrz.info[3] begins "11B" then que.rcod = "5". else que.rcod = "0".
                if remtrz.cracc = linjl and remtrz.cracc  ne '' and linjl ne '' then que.rcod = '2'.
            end.
            if remtrz.tcrc = 1 then do:
                find first aaa where aaa.aaa = remtrz.racc no-lock no-error.
                if avail aaa and aaa.crc <> remtrz.tcrc then do:
                    que.rcod = "1".
                end.
            end.
            find first debgrp where debgrp.arp = remtrz.racc no-lock no-error.
            if avail debgrp then que.rcod = "1".
            if remtrz.detpay[1] matches "*Комиссия за выпуск электронной*" then do:
                remtrz.cracc = remtrz.racc.
                remtrz.crgl = 287082.
                remtrz.rsub = "arp".
                que.rcod = "5".
            end.
            v-text = " Платеж " + remtrz.remtrz + " обработан. " + 'rcod = ' + que.rcod.
            run lgps.
        end. else do:
          run savelog("CImain_ps","552. таблица remtrz блокирована m_pid = " + m_pid + " rmz = " + que.remtrz).
        end.
    end. else do:
       run savelog("CImain_ps","556. таблица que блокирована m_pid = " + m_pid).
    end.
end. /* do transaction */

