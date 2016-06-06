/*LC2auth2.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        Проводки по изменениям аккредитива
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
        26/11/2010 galina
 * BASES
        BANK COMM
 * CHANGES
        05/01/2011 Vera - добавлены сообщения для пользователя о совершенных операциях, рассылка писем
        06/01/2011 Vera - изменение в учете платежей
        10/02/2011 id00810 - закомментировала комиссии
        28/02/2011 id00810 - для всех импортных аккредитивов и гарантии
        27/04/2011 id00810 - переход на pksysc для определения адресатов сообщения
        12/05/2011 id00810 - вызов lcmtamd, изменение в учете сумм и даты истечения
        24/05/2011 id00810 - использование функции chk-f
        28/06/2011 id00810 - ошибка в определении даты истечения
        29/07/2011 id00810 - счет DepAcc вместо 285521 для покрытого PG (c 01/08/2011)
        13/09/2011 id00810 - обработка ошибки копирования в SWIFT
        03/10/2011 id00810 - проводки по лимиту
        23/01/2012 id00810 - проверка суммы ддя проводок по лимиту
        06/02/2012 id00810 - добавлены комиссии
        08.06.2012 Lyubov  - добавила КОД, КБЕ, КНП в проводки
        28.06.2012 Lyubov  - для PG проводки делаются иначе
        29.06.2012 Lyubov  - изменила отправку писем, теперь адреса берутся из справ. bookcod, METROCOMBANK заменила на FORTEBANK
        31.07.2012 Lyubov  - исправила текущую сумму сделки
*/
{global.i}
{chk-f.i}

def shared var s-lc       like LC.LC.
def shared var v-lcsts    as char.
def shared var v-lcerrdes as char.
def shared var s-amdsts   like lcamend.sts.
def shared var s-lcamend  like lcamend.lcamend.
def shared var v-cif      as char.
def shared var v-cifname  as char.
def new shared var s-jh  like jh.jh.
def var v-amount   as char no-undo.
def var v-incdec   as int  no-undo.
def var v-sum      as deci no-undo.
def var v-per      as deci no-undo.
def var v-crc      as int  no-undo.
def var v-collacc  as char no-undo.
def var v-comacc   as char no-undo.
def var v-depacc   as char no-undo.
def var v-param    as char no-undo.
def var vdel       as char no-undo initial "^".
def var rcode      as int  no-undo.
def var rdes       as char no-undo.
def var v-lccow    as char no-undo.
def var v-st       as logi no-undo.
DEF VAR VBANK      AS CHAR no-undo.
def var v-gl       as char no-undo.
def var v-sumall   as deci no-undo.
def var v-sum1     as deci no-undo.
def var v-sum2     as deci no-undo.
def var v-yes      as logi no-undo init yes.
def var v-str      as char no-undo.
def var v-sp       as char no-undo.
def var v-trx      as char no-undo.
def var v-krit     as char no-undo.
def var v-maillist as char no-undo extent 2.
def var v-zag      as char no-undo.
def var i          as int  no-undo.
def var k          as int  no-undo.
def var v-logsno   as char no-undo init "no,n,нет,н,1".
def var v-gar      as logi no-undo.
def var v-numlim      as int  no-undo.
def var v-revolv      as char no-undo.
def var v-dlacc       as char no-undo init '662530'.
def var v-clacc       as char no-undo init '612530'.
def var v-text        as char no-undo init 'возобновляемым'.
def var v-lim-amount  as deci no-undo.
def var v-limcrc      as int  no-undo.
def buffer b-crc for crc.
def buffer b-lcamendres for lcamendres.
def shared var v-lcsumorg as deci.
def shared var v-lcsumcur as deci.
def shared var v-lcdtexp  as date.
def shared var s-lcprod   as char.

pause 0.
if lookup(s-amdsts,'BO1,MNG,ERR') = 0 then do:
    message "Letter of credit's status should be BO1 or MNG or Err!" view-as alert-box.
    return.
end.

    message 'Do you want to change Credit status?' VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE ' QUESTION !' update v-yes.
    if not v-yes then return.

    if s-lcprod = 'pg' then v-gar = yes.
    find first lch where lch.lc = s-lc and lch.kritcode = 'lcCrc' no-lock no-error.
    if avail lch then v-crc = integer(lch.value1).

    find first lch where lch.lc = s-lc and lch.kritcode = 'Cover' no-lock no-error.
    if avail lch then v-lccow = lch.value1.
    if v-lccow = '' then do:
        message "Field Covered/uncovered is empty!" view-as alert-box.
        return.
    end.

    find first lch where lch.lc = s-lc and lch.kritcode = 'NLim' no-lock no-error.
    if avail lch then v-numlim = int(lch.value1).

    if v-lccow = '0' then do:
        find first lch where lch.lc = s-lc and lch.kritcode = 'CollACC' no-lock no-error.
        if avail lch then v-collacc = lch.value1.
        if v-collacc = '' then do:
            message "Field CollAcc is empty!" view-as alert-box.
            return.
        end.
        if v-gar then do:
            find first lch where lch.lc = s-lc and lch.kritcode = 'DepAcc' no-lock no-error.
            if avail lch then v-depacc = lch.value1.
            if v-depacc = '' then do:
                message "Field Collateral Deposit Accout is empty!" view-as alert-box.
                return.
            end.
        end.
    end.

    find first lch where lch.lc = s-lc and lch.kritcode = 'ComAcc' no-lock no-error.
    if avail lch then v-comacc = lch.value1.
    if v-comacc = '' then do:
        message "Field ComAcc is empty!" view-as alert-box.
        return.
    end.

    FIND FIRST SYSC WHERE SYSC.SYSC = "OURBNK" NO-LOCK NO-ERROR.
    IF AVAIL SYSC AND SYSC.CHVAL <> '' THEN VBANK =  SYSC.CHVAL.

    find first lcamendh where lcamendh.bank = vbank and lcamendh.lc = s-lc and lcamendh.lcamend = s-lcamend and lcamendh.kritcode = 'IncAmt' no-lock no-error.
    if avail lcamendh and lcamendh.value1 <> '' then assign v-incdec = 1 v-amount = lcamendh.value1.
    else do:
        find first lcamendh where lcamendh.bank = vbank and lcamendh.lc = s-lc and lcamendh.lcamend = s-lcamend and lcamendh.kritcode = 'DecAmt' no-lock no-error.
        if avail lcamendh and lcamendh.value1 <> '' then assign v-incdec = -1 v-amount = lcamendh.value1.
    end.

    find first lcamendh where lcamendh.bank = vbank and lcamendh.lc = s-lc and lcamendh.lcamend = s-lcamend and lcamendh.kritcode = 'PerAmtT' no-lock no-error.
    if avail lcamendh and lcamendh.value1 <> '' then do:
        v-per = int(entry(1,lcamendh.value1, '/')).
        if v-per > 0 then v-sum = (decimal(v-amount) + (decimal(v-amount) * (v-per / 100))).
        if v-per <= 0 then v-sum = decimal(v-amount).
    end.
    else v-sum = decimal(v-amount).

    /*check balance*/
    v-sum2 = 0.
    if v-lccow = '0' and v-incdec = 1 then do:
        v-sum2 = v-sum.
        /* проверим, не списалось ли уже покрытие */
        if not v-gar then find first lcamendres where lcamendres.LC = s-lc and lcamendres.lcamend = s-lcamend and not lcamendres.com and lcamendres.levC = 22 and lcamendres.jh > 0 no-lock no-error.
                     else find first lcamendres where lcamendres.LC = s-lc and lcamendres.lcamend = s-lcamend and not lcamendres.com and lcamendres.levC = 1 and lcamendres.cacc = v-depacc no-lock no-error.

        if avail lcamendres then v-sum2 = v-sum2 - lcamendres.amt.
    end.
    v-sum1 = 0.
    v-sumall = v-sum1 + v-sum2.

    find first aaa where aaa.aaa = v-collacc no-lock no-error.
    if avail aaa then do:
        if v-sumall > aaa.cbal - aaa.hbal then do:
            message "Lack of the balance Collateral Debit Account (" + aaa.aaa + ")!" view-as alert-box error.
            return.
        end.
    end.

    /*POSTINGS*/
    /*Covered*/
    if v-lccow = '0' then do:
        if v-incdec = 1 then do:
            /*1-st posting*/
            if not v-gar then find first lcamendres where lcamendres.lc = s-lc and lcamendres.lcamend = s-lcamend and not lcamendres.com and lcamendres.levC = 22 no-lock no-error.
                         else find first lcamendres where lcamendres.lc = s-lc and lcamendres.lcamend = s-lcamend and not lcamendres.com and lcamendres.levC = 1 and lcamendres.cacc = v-depacc no-lock no-error.
            if avail lcamendres then do:
                message "Attention! The 1-st posting for covered LC(Increase) was done earlier!" view-as alert-box info.
            end.
            else do:
                if not v-gar
                then assign v-param = string(v-sum) + vdel + string(v-crc) + vdel + v-collacc + vdel + s-lc + vdel + '1' + vdel + '4' + vdel + '181'
                            v-trx   = 'cif0013'.
                else assign v-param = string(v-sum) + vdel + string(v-crc) + vdel + v-collacc + vdel + v-depacc + vdel + 'Списание покрытия ' + s-lc + vdel + '1' + vdel + '4' + vdel + '181'
                            v-trx   = 'cif0020'.
                s-jh = 0.
                run trxgen (v-trx, vdel, v-param, "cif" , s-lc , output rcode, output rdes, input-output s-jh).
                if rcode ne 0 then do:
                    message rdes.
                    pause.
                    message "The 1-st posting for covered LC(Increase) was not done!" view-as alert-box error.
                    find first lcamendh where lcamendh.bank = vbank and lcamendh.lc = s-lc and lcamendh.lcamend = s-lcamend and lcamendh.kritcode = 'ErrDes' no-lock no-error.
                    if avail lcamendh then find current lcamendh exclusive-lock.
                    if not avail lcamendh then create lcamendh.
                    assign lcamendh.lc       = s-lc
                           lcamendh.lcamend  = s-lcamend
                           lcamendh.kritcode = 'ErrDes'
                           lcamendh.value1   = string(rcode) + ' ' + rdes
                           lcamendh.bank     = vbank.
                    run LCsts2(s-amdsts,'Err').
                    return.
                end.
                if s-jh > 0 then do:
                    create lcamendres.
                    assign lcamendres.lc      = s-lc
                           lcamendres.lcamend = s-lcamend
                           lcamendres.dacc    = v-collacc
                           lcamendres.cacc    = if not v-gar then v-collacc else v-depacc
                           lcamendres.amt     = v-sum
                           lcamendres.crc     = v-crc
                           lcamendres.com     = no
                           lcamendres.comcode = ''
                           lcamendres.rwho    = g-ofc
                           lcamendres.rwhn    = g-today
                           lcamendres.jh      = s-jh
                           lcamendres.jdt     = g-today
                           lcamendres.trx     = v-trx
                           lcamendres.levC    = if not v-gar then 22 else 1
                           lcamendres.levD    = 1
                           lcamendres.rem     = 'Списание покрытия ' + s-lc
                           lcamendres.bank    = VBANK.
                    v-st = yes.
                end.
                message "The 1-st posting for covered LC(Increase) was done!" view-as alert-box info.
            end.

            /*2-nd posting*/
            if not v-gar then find first lcamendres where lcamendres.lc = s-lc and lcamendres.lcamend = s-lcamend and not lcamendres.com and lcamendres.levD = 23 no-lock no-error.
                         else find first lcamendres where lcamendres.lc = s-lc and lcamendres.lcamend = s-lcamend and not lcamendres.com and lcamendres.levD = 1 and lcamendres.dacc = '605561' no-lock no-error.
            if avail lcamendres then do:
                message "Attention! The 2-nd posting for covered LC(Increase) was done earlier!" view-as alert-box info.
            end.
            else do:
                if not v-gar
                then assign v-param = string(v-sum) + vdel + string(v-crc) + vdel + '23' + vdel + v-collacc + vdel +
                                      '652000' + vdel + s-lc
                            v-trx   = 'cif0014'.
                else assign v-param = string(v-sum) + vdel + string(v-crc) + vdel + '605561' + vdel +
                                      '655561' + vdel + 'PG треб/обязат по вып покрыт/непокрыт аккредитивам ' + s-lc
                            v-trx   = 'uni0144'.

                s-jh = 0.
                run trxgen (v-trx, vdel, v-param, "cif" , s-lc , output rcode, output rdes, input-output s-jh).
                if rcode ne 0 then do:
                    message rdes.
                    pause.
                    message "The 2-nd posting for covered LC(Increase) was not done!" view-as alert-box error.
                    find first lcamendh where lcamendh.bank = vbank and lcamendh.lc = s-lc and lcamendh.lcamend = s-lcamend and lcamendh.kritcode = 'ErrDes' no-lock no-error.
                    if avail lcamendh then find current lcamendh exclusive-lock.
                    if not avail lcamendh then create lcamendh.
                    assign lcamendh.lc       = s-lc
                           lcamendh.lcamend  = s-lcamend
                           lcamendh.kritcode = 'ErrDes'
                           lcamendh.value1   = string(rcode) + ' ' + rdes
                           lcamendh.bank     = vbank.
                    run LCsts2(s-amdsts,'Err').
                    return.
                end.
                if s-jh > 0 then do:
                    create lcamendres.
                    assign lcamendres.lc      = s-lc
                           lcamendres.lcamend = s-lcamend
                           lcamendres.dacc    = if not v-gar then v-collacc else '605561'
                           lcamendres.cacc    = if not v-gar then '652000'  else '655561'
                           lcamendres.amt     = v-sum
                           lcamendres.crc     = v-crc
                           lcamendres.com     = no
                           lcamendres.comcode = ''
                           lcamendres.rwho    = g-ofc
                           lcamendres.rwhn    = g-today
                           lcamendres.jh      = s-jh
                           lcamendres.jdt     = g-today
                           lcamendres.trx     = v-trx
                           lcamendres.levC    = 1
                           lcamendres.levD    = if not v-gar then 23 else 1
                           lcamendres.rem     = 'Треб/обязат. по покрыт/непокрыт.аккредитивам/гарантиям ' + s-lc
                           lcamendres.bank    = VBANK.
                    v-st = yes.
                end.
                message "The 2-nd posting for covered LC(Increase) was done!" view-as alert-box info.
            end.
        end.

        if v-incdec = -1 then do:
            /*1-st posting*/
            if not v-gar then find first lcamendres where lcamendres.lc = s-lc and lcamendres.lcamend = s-lcamend and not lcamendres.com and lcamendres.levD = 22 no-lock no-error.
                         else find first lcamendres where lcamendres.lc = s-lc and lcamendres.lcamend = s-lcamend and not lcamendres.com and lcamendres.levD = 1 and lcamendres.cacc = v-depacc no-lock no-error.
            if avail lcamendres then do:
                message "Attention! The 1-st posting for covered LC(Decrease) was done earlier!" view-as alert-box info.
            end.
            else do:
                if not v-gar
                then assign v-param = string(v-sum) + vdel + string(v-crc) + vdel + v-collacc + vdel + s-lc + ' Номер изменения ' + string(s-lcamend,'99')
                            v-trx   = 'cif0017'.
                else assign v-param = string(v-sum) + vdel + string(v-crc) + vdel + v-depacc + vdel + v-collacc + vdel + 'Возврат покрытия ' + s-lc + '.Номер изменения ' + string(s-lcamend,'99') + vdel + '1' + vdel + '4' + vdel + '181'
                            v-trx   = 'cif0020'.
                s-jh = 0.
                run trxgen (v-trx, vdel, v-param, "cif" , s-lc , output rcode, output rdes, input-output s-jh).
                    if rcode ne 0 then do:
                       message rdes.
                       pause.
                       message "The 1-st posting for covered LC(Decrease) was not done!" view-as alert-box error.
                       find first lcamendh where lcamendh.bank = vbank and lcamendh.lc = s-lc and lcamendh.lcamend = s-lcamend and lcamendh.kritcode = 'ErrDes' no-lock no-error.
                       if avail lcamendh then find current lcamendh exclusive-lock.
                       if not avail lcamendh then create lcamendh.
                       assign lcamendh.lc       = s-lc
                              lcamendh.lcamend  = s-lcamend
                              lcamendh.kritcode = 'ErrDes'
                              lcamendh.value1   = string(rcode) + ' ' + rdes
                              lcamendh.bank     = vbank.
                       run LCsts2(s-amdsts,'Err').
                       return.
                    end.
                if s-jh > 0 then do:
                    create lcamendres.
                    assign lcamendres.lc      = s-lc
                           lcamendres.lcamend = s-lcamend
                           lcamendres.cacc    = v-collacc
                           lcamendres.dacc    = if not v-gar then v-collacc else v-depacc
                           lcamendres.amt     = v-sum
                           lcamendres.crc     = v-crc
                           lcamendres.com     = no
                           lcamendres.comcode = ''
                           lcamendres.rwho    = g-ofc
                           lcamendres.rwhn    = g-today
                           lcamendres.jh      = s-jh
                           lcamendres.jdt     = g-today
                           lcamendres.trx     = v-trx
                           lcamendres.levC    = 1
                           lcamendres.levD    = if not v-gar then 22 else 1
                           lcamendres.rem     = 'Возврат покрытия ' + s-lc
                           lcamendres.bank    = VBANK.
                    v-st = yes.
                end.
                message "The 1-st posting for covered LC(Decrease) was done!" view-as alert-box info.
            end.
            /*2-nd posting*/
            if not v-gar then find first lcamendres where lcamendres.lc = s-lc and lcamendres.lcamend = s-lcamend and not lcamendres.com and lcamendres.levC = 23 no-lock no-error.
                         else find first lcamendres where lcamendres.lc = s-lc and lcamendres.lcamend = s-lcamend and not lcamendres.com and lcamendres.levC = 1 and lcamendres.cacc = '605561' no-lock no-error.

            if avail lcamendres then do:
                message "Attention! The 2-nd posting for covered LC(Decrease) was done earlier!" view-as alert-box info.
            end.
            else do:
                if not v-gar
                then assign v-param = string(v-sum) + vdel + string(v-crc) + vdel + '652000' + vdel + '23' + vdel +
                                      v-collacc + vdel + s-lc + ' Номер изменения ' + string(s-lcamend,'99')
                            v-trx   = 'cif0018'.
                else assign v-param = string(v-sum) + vdel + string(v-crc) + vdel + '655561' + vdel +
                                      '605561' + vdel + 'Возврат треб/обязат по покрыт/непокрыт.гарантиям ' + s-lc + '. Номер изменения ' + string(s-lcamend,'99')
                            v-trx   = 'uni0144'.
                s-jh = 0.
                run trxgen (v-trx, vdel, v-param, "cif" , s-lc , output rcode, output rdes, input-output s-jh).
                    if rcode ne 0 then do:
                       message rdes.
                       pause.
                       message "The 2-nd posting for covered LC(Decrease) was not done!" view-as alert-box error.
                       find first lcamendh where lcamendh.bank = vbank and lcamendh.lc = s-lc and lcamendh.lcamend = s-lcamend and lcamendh.kritcode = 'ErrDes' no-lock no-error.
                       if avail lcamendh then find current lcamendh exclusive-lock.
                       if not avail lcamendh then create lcamendh.
                       assign lcamendh.lc       = s-lc
                              lcamendh.lcamend  = s-lcamend
                              lcamendh.kritcode = 'ErrDes'
                              lcamendh.value1   = string(rcode) + ' ' + rdes
                              lcamendh.bank     = vbank.
                       run LCsts2(s-amdsts,'Err').
                       return.
                    end.
                    if s-jh > 0 then do:
                        create lcamendres.
                        assign lcamendres.lc      = s-lc
                               lcamendres.lcamend = s-lcamend
                               lcamendres.cacc    = if not v-gar then v-collacc else '605561'
                               lcamendres.dacc    = if not v-gar then '652000'  else '655561'
                               lcamendres.amt     = v-sum
                               lcamendres.crc     = v-crc
                               lcamendres.com     = no
                               lcamendres.comcode = ''
                               lcamendres.rwho    = g-ofc
                               lcamendres.rwhn    = g-today
                               lcamendres.jh      = s-jh
                               lcamendres.jdt     = g-today
                               lcamendres.trx     = v-trx
                               lcamendres.levD    = 1
                               lcamendres.levC    = if not v-gar then 23 else 1
                               lcamendres.rem     = 'Возврат треб/обязат. по покрыт/непокрыт.аккредитивам/гарантиям ' + s-lc
                               lcamendres.bank    = VBANK.
                        v-st = yes.
                  end.
                message "The 2-nd posting for covered LC(Decrease) was done!" view-as alert-box info.
              end.
          end.
     end.

    /*Uncovered*/
    if v-lccow = '1' then do:
        if v-incdec = 1 then do:
            if not v-gar then find first lcamendres where lcamendres.lc = s-lc and lcamendres.lcamend = s-lcamend and not lcamendres.com and lcamendres.levD = 24 no-lock no-error.
                         else find first lcamendres where lcamendres.lc = s-lc and lcamendres.lcamend = s-lcamend and not lcamendres.com and lcamendres.levD = 1 and lcamendres.dacc = '605562' no-lock no-error.

            if avail lcamendres then do:
                message "Attention! The 1-st posting for uncovered LC(Increase) was done earlier!" view-as alert-box info.
            end.
            else do:
                if not v-gar
                then assign v-param = string(v-sum) + vdel + string(v-crc) + vdel + '24' + vdel + v-comacc + vdel +
                                      '650510' + vdel + s-lc
                            v-trx   = 'cif0014'.
                else assign v-param = string(v-sum) + vdel + string(v-crc) + vdel + '605562' + vdel +
                                      '655562' + vdel + 'Треб/обязат по покрыт/непокрыт.гарантиям ' + s-lc
                            v-trx   = 'uni0144'.
                 s-jh = 0.
                run trxgen (v-trx, vdel, v-param, "cif" , s-lc , output rcode, output rdes, input-output s-jh).
                        if rcode ne 0 then do:
                           message rdes.
                           pause.
                           message "The 1-st posting for uncovered LC(Increase) was not done!" view-as alert-box error.
                           find first lcamendh where lcamendh.bank = vbank and lcamendh.lc = s-lc and lcamendh.lcamend = s-lcamend and lcamendh.kritcode = 'ErrDes' no-lock no-error.
                           if avail lcamendh then find current lcamendh exclusive-lock.
                           if not avail lcamendh then create lcamendh.
                           assign lcamendh.lc      = s-lc
                                  lcamendh.lcamend = s-lcamend
                                  lcamendh.kritcode = 'ErrDes'
                                  lcamendh.value1   = string(rcode) + ' ' + rdes
                                  lcamendh.bank     = vbank.
                           run LCsts2(s-amdsts,'Err').
                           return.
                        end.
                if s-jh > 0 then do:
                    create lcamendres.
                    assign lcamendres.lc      = s-lc
                           lcamendres.lcamend = s-lcamend
                           lcamendres.dacc    = if not v-gar  then v-comacc else '605562'
                           lcamendres.cacc    = if not v-gar  then '650510' else '655562'
                           lcamendres.amt     = v-sum
                           lcamendres.crc     = v-crc
                           lcamendres.com     = no
                           lcamendres.comcode = ''
                           lcamendres.rwho    = g-ofc
                           lcamendres.rwhn    = g-today
                           lcamendres.jh      = s-jh
                           lcamendres.jdt     = g-today
                           lcamendres.trx     = v-trx
                           lcamendres.levC    = 1
                           lcamendres.levD    = if not v-gar then 24 else 1
                           lcamendres.rem     = 'Треб/обязат. по покрыт/непокрыт.аккредитивам/гарантиям ' + s-lc
                           lcamendres.bank    = VBANK.
                    v-st = yes.
                end.
                message "The 1-st posting for uncovered LC(Increase) was done!" view-as alert-box info.
            end.
        end.
        if v-incdec = -1 then do:
            find first lcamendres where lcamendres.lc = s-lc and lcamendres.lcamend = s-lcamend and (lcamendres.levC = 24 or lcamendres.cacc = '605562') no-lock no-error.
            if avail lcamendres then do:
                message "Attention! The 1-st posting for uncovered LC(Decrease) was done earlier!" view-as alert-box info.
            end.
            else do:
                if not v-gar
                then assign v-param = string(v-sum) + vdel + string(v-crc) + vdel + '650510' + vdel + '24' + vdel + v-comacc + vdel + s-lc
                            v-trx   = 'cif0018'.
                else assign v-param = string(v-sum) + vdel + string(v-crc) + vdel + '655562' + vdel +
                                      '605562' + vdel + 'Возврат треб/обязат. по покрыт/непокрыт.гарантиям ' + s-lc
                            v-trx   = 'uni0144'.
                /*v-param = string(v-sum) + vdel + string(v-crc) + vdel + '650510' + vdel + '24' + vdel + v-comacc + vdel + s-lc.*/
                s-jh = 0.
                run trxgen (v-trx, vdel, v-param, "cif" , s-lc , output rcode, output rdes, input-output s-jh).
                       if rcode ne 0 then do:
                           message rdes.
                           pause.
                           message "The 1-st posting for uncovered LC(Decrease) was not done!" view-as alert-box error.
                           find first lcamendh where lcamendh.bank = vbank and lcamendh.lc = s-lc and lcamendh.lcamend = s-lcamend and lcamendh.kritcode = 'ErrDes' no-lock no-error.
                           if avail lcamendh then find current lcamendh exclusive-lock.
                           if not avail lcamendh then create lcamendh.
                           assign lcamendh.lc       = s-lc
                                  lcamendh.lcamend  = s-lcamend
                                  lcamendh.kritcode = 'ErrDes'
                                  lcamendh.value1   = string(rcode) + ' ' + rdes
                                  lcamendh.bank     = vbank.
                           run LCsts2(s-amdsts,'Err').
                           return.
                        end.
                if s-jh > 0 then do:
                    create lcamendres.
                    assign lcamendres.lc      = s-lc
                           lcamendres.lcamend = s-lcamend
                           lcamendres.cacc    = if not v-gar then v-comacc else '605562'
                           lcamendres.dacc    = if not v-gar then '650510' else '655562'
                           lcamendres.amt     = v-sum
                           lcamendres.crc     = v-crc
                           lcamendres.com     = no
                           lcamendres.comcode = ''
                           lcamendres.rwho    = g-ofc
                           lcamendres.rwhn    = g-today
                           lcamendres.jh      = s-jh
                           lcamendres.jdt     = g-today
                           lcamendres.trx     = v-trx
                           lcamendres.levD    = 1
                           lcamendres.levC    = if not v-gar then 24 else 1
                           lcamendres.rem     = 'Возврат треб/обязат. по покрыт/непокрыт.аккредитивам/гарантиям ' + s-lc
                           lcamendres.bank    = VBANK.
                    v-st = yes.
                end.
                message "The 1-st posting for uncovered LC(Decrease) was done!" view-as alert-box info.
            end.
        end.
    end.
    if v-numlim > 0 and v-sum <> 0 then do:
        /* posting - limit*/
        find first lclimit where lclimit.bank = vbank and lclimit.cif = v-cif and lclimit.number = v-numlim no-lock no-error.
        if avail lclimit then do:
        find first lclimith where lclimith.cif = lclimit.cif and lclimith.number = lclimit.number  and lclimith.kritcode = 'Revolv' no-lock no-error.
        if avail lclimith then v-revolv = lclimith.value1.
        if lookup(v-revolv,v-logsno) > 0 then assign v-dlacc = '662540' v-clacc = '612540' v-text = 'невозобновляемым'.

        find first lclimith where lclimith.cif = lclimit.cif and lclimith.number = lclimit.number and lclimith.kritcode = 'lcCrc' no-lock no-error.
        if avail lclimith then v-limcrc = int(lclimith.value1).
        if v-crc = v-limcrc then v-lim-amount = v-sum.
        else do:
            find first crc where crc.crc = v-crc no-lock no-error.
            find first b-crc where b-crc.crc = v-limcrc no-lock no-error.
            if avail b-crc then v-lim-amount = round((v-sum * crc.rate[1]) / b-crc.rate[1],2).
        end.

        find first lclimitres where lclimitres.bank = lclimit.bank and lclimitres.cif = lclimit.cif and lclimitres.number = lclimit.number and lclimitres.lc = s-lc and lclimitres.info[1] = 'append' no-lock no-error.

        /*find first lcres where lcres.lc = s-lc and not lcres.com and lcres.levD = 1 and lcres.dacc = v-dacc no-lock no-error.*/
       /*if not v-gar then find first lcres where lcres.lc = s-lc and lcres.levD = 23 no-lock no-error.
                     else find first lcres where lcres.lc = s-lc and lcres.levD = 1 and lcres.dacc = '605561' no-lock no-error.*/
        if avail lclimitres then do:
           message "Attention! The posting for limit LC was done earlier!" view-as alert-box info.
        end.
        else do:
             if v-incdec = 1
             then v-param = string(v-lim-amount) + vdel + string(v-limcrc) + vdel + v-dlacc + vdel +
                                  v-clacc + vdel + 'Списание доступного остатка по ' + v-text + ' кредитам в рамках ТФ, ' + v-cifname.
             else  v-param = string(v-lim-amount) + vdel + string(v-limcrc) + vdel + v-clacc + vdel +
                                  v-dlacc + vdel + 'Увеличение доступного остатка по ' + v-text + ' кредитам в рамках ТФ, ' + v-cifname.
            v-trx   = 'uni0144'.
            s-jh = 0.
            run trxgen (v-trx, vdel, v-param, "cif" , s-lc , output rcode, output rdes, input-output s-jh).
            if rcode ne 0 then do:
               message rdes.
               pause.
               message "The posting for limit was not done!" view-as alert-box error.
               find first lch where lch.lc = s-lc and lch.kritcode = 'ErrDes' no-lock no-error.
               if avail lch then find current lch exclusive-lock.
               if not avail lch then create lch.
               assign lch.lc       = s-lc
                      lch.kritcode = 'ErrDes'
                      lch.value1   = string(rcode) + ' ' + rdes
                      lch.bank     = vbank.
               run LCsts('BO1','Err').
               return.
            end.
            if s-jh > 0 then do:
                create lclimitres.
                assign lclimitres.cif     =  v-cif
                       lclimitres.number  = v-numlim
                       lclimitres.lc      = s-lc
                       lclimitres.dacc    = if v-incdec = 1 then v-dlacc else v-clacc
                       lclimitres.cacc    = if v-incdec = 1 then v-clacc else v-dlacc
                       lclimitres.amt     = v-lim-amount
                       lclimitres.crc     = v-limcrc
                       lclimitres.rwho    = g-ofc
                       lclimitres.rwhn    = g-today
                       lclimitres.jh      = s-jh
                       lclimitres.jdt     = g-today
                       lclimitres.trx     = v-trx
                       lclimitres.rem     = if v-incdec = 1 then 'Списание доступного остатка по ' + v-text + ' кредитам в рамках ТФ, ' + s-lc
                                                            else 'Увеличение доступного остатка по ' + v-text + ' кредитам в рамках ТФ, ' + s-lc
                       lclimitres.bank    = VBANK
                       lclimitres.info[1] = 'append'.
                v-st = yes.
            end.
            message "The posting for limit was done!" view-as alert-box info.
        end.
        end.
    end.
    /*Commission postings*/
    for each lcamendres where lcamendres.lc = s-lc and lcamendres.lcamend = s-lcamend and lcamendres.com and lcamendres.comcode ne '9990' and lcamendres.jh = 0 no-lock:
        if lcamendres.amt = 0 then next.
        find first tarif2 where tarif2.str5 = lcamendres.comcode and tarif2.stat = 'r' no-lock no-error.
        if not avail tarif2 then return.
        v-gl = string(tarif2.kont).
        if s-lcprod = 'PG' then
             assign v-param = string(lcamendres.amt) + vdel + v-comacc + vdel + '286920' + vdel + s-lc + ' ' + lcamendres.rem + vdel + string(lcamendres.amt) + vdel + string(tarif2.kont)
                    v-trx   = 'cif0023'.
        else assign v-param = string(lcamendres.amt) + vdel + string(lcamendres.crc) + vdel + v-comacc + vdel + string(tarif2.kont) + vdel + s-lc + ' ' + lcamendres.rem + vdel + '1' + vdel + '4' + vdel + '840'
                    v-trx   = 'cif0015'.

        s-jh = 0.
        run trxgen (v-trx, vdel, v-param, "cif" , s-lc , output rcode, output rdes, input-output s-jh).

        if rcode ne 0 then do:
            message rdes.
            pause.
            message "The commission posting (" + lcamendres.comcode + ") was not done!" view-as alert-box error.
            find first lcamendh where lcamendh.bank = vbank and lcamendh.lc = s-lc and lcamendh.lcamend = s-lcamend and lcamendh.kritcode = 'ErrDes' no-lock no-error.
            if avail lcamendh then find current lcamendh exclusive-lock.
            if not avail lcamendh then create lcamendh.
            assign lcamendh.lc       = s-lc
                   lcamendh.lcamend    = s-lcamend
                   lcamendh.bank     = vbank
                   lcamendh.kritcode = 'ErrDes'
                   lcamendh.value1   = string(rcode) + ' ' + rdes.
            run LCsts('BO1','Err').
            return.
        end.

        if s-jh > 0 then do:
            find first b-lcamendres where rowid(b-lcamendres) = rowid(lcamendres) exclusive-lock no-error.
            if avail b-lcamendres then
            assign b-lcamendres.rwho   = g-ofc
                   b-lcamendres.rwhn   = g-today
                   b-lcamendres.jh     = s-jh
                   b-lcamendres.jdt    = g-today
                   b-lcamendres.trx    = v-trx.
            v-st = yes.
            find current b-lcamendres no-lock no-error.
        end.
        message "The commission posting (" + lcamendres.comcode + ") was done!" view-as alert-box info.
    end.

    if (v-st = yes) or (v-st = no and s-amdsts <> 'FIN') then do:
        if chk-f("$HOME/.ssh/id_swift") ne '0' then do:
            message "There is no file $HOME/.ssh/id_swift!" view-as alert-box error.
            find first lcamendh where lcamendh.bank = vbank and lcamendh.lc = s-lc and lcamendh.lcamend = s-lcamend and lcamendh.kritcode = 'ErrDes' no-lock no-error.
            if avail lcamendh then find current lcamendh exclusive-lock.
            else create lcamendh.
            assign lcamendh.value1   = "There is no file $HOME/.ssh/id_swift!"
                   lcamendh.lc       = s-lc
                   lcamendh.lcamend  = s-lcamend
                   lcamendh.kritcode = 'ErrDes'
                   lcamendh.bank     = vbank.
            run LCsts2(s-amdsts,'Err').
            return.
        end.
        if s-lcprod <> 'pg' then do:
            find first lcamendh where lcamendh.bank = vbank and lcamendh.lc = s-lc and lcamendh.lcamend = s-lcamend and lcamendh.kritcode = 'MT707' no-lock no-error.
            if avail lcamendh and lookup(lcamendh.value1,v-logsno) = 0 then run lcmtamd.p ('707',yes) no-error. /*run LCmt707*/
        end.
        else run lcmtamd.p ('767',yes) no-error. /*run lcmt767*/

        if error-status:error then do:
            find first lcamendh where lcamendh.bank = vbank and lcamendh.lc = s-lc and lcamendh.lcamend = s-lcamend and lcamendh.kritcode = 'ErrDes' no-lock no-error.
            if avail lcamendh then find current lcamendh exclusive-lock.
            else create lcamendh.
            assign lcamendh.value1   = "File wasn't copied to SWIFT Alliance!"
                   lcamendh.lc       = s-lc
                   lcamendh.lcamend  = s-lcamend
                   lcamendh.kritcode = 'ErrDes'
                   lcamendh.bank     = vbank.
            run LCsts2(s-amdsts,'Err').
            v-lcerrdes = "File wasn't copied to SWIFT Alliance!".
            return.
        end.

        if s-amdsts = 'ERR' then do:
            find first lcamendh where lcamendh.bank = vbank and lcamendh.lc = s-lc and lcamendh.lcamend = s-lcamend and lcamendh.kritcode = 'ErrDes' no-lock no-error.
            if avail lcamendh then do:
                find current lcamendh exclusive-lock.
                lcamendh.value1 = ''.
                find current lcamendh no-lock no-error.
            end.
        end.
        run LCsts2(s-amdsts,'FIN').
        /* сообщение */
        find first bookcod where bookcod.bookcod = 'mdmail' and bookcod.code = 'MD2' no-lock no-error.
        if avail bookcod then do:
           do k = 1 to num-entries(bookcod.name,','):
              v-sp = entry(k,bookcod.name,',').
              do i = 1 to num-entries(v-sp):
                 if trim(entry(i,v-sp)) <> '' then do:
                    if v-maillist[k] <> '' then v-maillist[k] = v-maillist[k] + ','.
                    v-maillist[k] = v-maillist[k] + trim(entry(i,v-sp)).
                 end.
              end.
           end.
        end.
        if v-maillist[1] <> '' then do:
            v-zag = if s-lcprod = 'imlc' then ' аккредитива: ' else ' гарантии: '.
             v-str = 'Референс инструмента: ' + s-lc + '~n' + '~n' + 'Сумма сделки(первоначальная): '.

             find first lch where lch.lc = s-lc and lch.kritcode = 'Amount' no-lock no-error.
             if avail lch then do:
                 v-lcsumorg = deci(lch.value1).
                 v-lcsumcur = deci(lch.value1).
                 v-str = v-str + trim(replace(string(deci(lch.value1),'>>>>>>>>9.99'),'.',',')) + '~n' + '~n' + 'Сумма сделки(текущая): '.
             end.
             else  v-str = v-str + '~n' + '~n' + 'Сумма сделки(текущая): '.

             if not v-gar then
                 for each lcamendres where lcamendres.lc = s-lc and (lcamendres.levC = 23 or lcamendres.levD = 23 or lcamendres.levC = 24 or lcamendres.levD = 24) and lcamendres.jh > 0 no-lock:
                     find first jh where jh.jh = lcamendres.jh no-lock no-error.
                     if not avail jh then next.

                     if lcamendres.levD = 23 or lcamendres.levD = 24 then v-lcsumcur = v-lcsumcur + lcamendres.amt.
                     if lcamendres.levC = 23 or lcamendres.levC = 24 then v-lcsumcur = v-lcsumcur - lcamendres.amt.
                 end.
                 else
                 for each lcamendres where lcamendres.lc = s-lc and (lcamendres.dacc = '605561' or  lcamendres.dacc = '655561' or lcamendres.dacc = '605562' or  lcamendres.dacc = '655562') and lcamendres.jh > 0 no-lock:
                    find first jh where jh.jh = lcamendres.jh no-lock no-error.
                    if not avail jh then next.
                    if lcamendres.dacc = '605561' or lcamendres.dacc = '605562' then v-lcsumcur = v-lcsumcur  + lcamendres.amt.
                    else v-lcsumcur = v-lcsumcur  - lcamendres.amt.
                 end.
                 /* payment */
                 if not v-gar then
                 for each lcpayres where lcpayres.lc = s-lc and (lcpayres.levC = 23 or lcpayres.levC = 24) and lcpayres.jh > 0 no-lock:
                     find first jh where jh.jh = lcpayres.jh no-lock no-error.
                     if avail jh then v-lcsumcur = v-lcsumcur - lcpayres.amt.
                 end.
                 else
                 for each lcpayres where lcpayres.lc = s-lc and (lcpayres.dacc = '655561' or lcpayres.dacc = '655562') and lcpayres.jh > 0 no-lock:
                     find first jh where jh.jh = lcpayres.jh no-lock no-error.
                     if avail jh then v-lcsumcur = v-lcsumcur - lcpayres.amt.
                 end.
                 /* event */
                 for each lceventres where lceventres.lc = s-lc and (lceventres.levC = 23 or lceventres.levC = 24 or lceventres.dacc = '655561' or lceventres.dacc = '655562') and lceventres.jh > 0 no-lock:
                     find first jh where jh.jh = lceventres.jh no-lock no-error.
                     if avail jh then v-lcsumcur = v-lcsumcur - lceventres.amt.
                 end.
             v-str = v-str + trim(replace(string(v-lcsumcur,'>>>>>>>>9.99'),'.',',')) + '~n' + '~n' + 'Валюта сделки: '.

             find first lch where lch.lc = s-lc and lch.kritcode = 'lcCrc' no-lock no-error.
             if avail lch then do:
                find first crc where crc.crc = integer(lch.value1) no-lock no-error.
                if avail crc then v-str = v-str + crc.code + '~n' + '~n' + 'Дата выпуска'  + v-zag.
             end.
             else  v-str = v-str + '~n' + '~n' + 'Дата выпуска'  + v-zag.

             v-krit = if s-lcprod = 'imlc' then 'DtIs' else 'Date'.
             find first lch where lch.lc = s-lc and lch.kritcode = v-krit no-lock no-error.
             if avail lch then v-str = v-str + lch.value1 + '~n' + '~n' + 'Дата истечения'  + v-zag.
             else  v-str = v-str + '~n' + '~n' + 'Дата истечения'  + v-zag.

             find first lch where lch.lc = s-lc and lch.kritcode = 'DtExp' no-lock no-error.
             if avail lch then do:
                 find last lcamendh where lcamendh.lc = s-lc and lcamendh.kritcode = 'NewDtEx' and lcamendh.value1 ne '' no-lock no-error.
                 if avail lcamendh then assign v-str = v-str + lcamendh.value1 + '~n' v-lcdtexp = date(lcamendh.value1).
                 else assign v-str = v-str + lch.value1 + '~n' v-lcdtexp = date(lch.value1).
             end.
             else  v-str = v-str + '~n'.

             run mail(v-maillist[1],"FORTEBANK <abpk@fortebank.com>", "Изменение" + right-trim(v-zag,":") ,v-str, "", "","").
             if v-maillist[2] <> '' then run mail(v-maillist[2],"FORTEBANK <abpk@fortebank.com>", "Изменение" + right-trim(v-zag,":") ,v-str, "", "","").
        end.
    end.
