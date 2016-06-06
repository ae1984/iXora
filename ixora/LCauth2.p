/*LCauth2.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        Проводки по выдаче аккредитива
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
        09/09/2010 aigul
 * BASES
        BANK COMM
 * CHANGES
        23/09/2010 galina - поменяла формат ввода поля 39:A (Percent Credit Amount Tolerance)
        11/10/2010 galina - поправила валюту комиссии и запись в таблицу LCres
                            для проверки баланса учитываем только сумму покрытия
        13/10/2010 galina - перекомпиляция
        13/12/2010 Vera   - назначение платежа в lcres.rem
        30/12/2010 Vera   - уточненен расчет остатка, добавлены сообщения для пользователя о совершенных операциях, рассылка писем
        21/01/2011 id00810 - уточнение статусов, добавление полей Аппликант и Бенефициар в сообщение
        27/01/2011 id00810 - для импортной гарантии
        28/02/2011 id00810 - исправлена ошибка в сообщении (кавычки)
        02/03/2011 id00810 - переход на pksysc для определения адресатов сообщения
        21/04/2011 id00810 - для резервного аккредитива SBLC
        13/07/2011 id00810 - новый реквизит для PG 'MT760'
        29/07/2011 id00810 - счет DepAcc вместо 285521 для покрытого PG (c 01/08/2011)
        15/08/2011 id00810 - изменения в связи с MT720
        13/09/2011 id00810 - обработка ошибки копирования в SWIFT
        29/09/2011 id00810 - проводки по лимиту
        17/01/2012 id00810 - добавлена новая переменная s-fmt
        30/01/2011 id00810 - изменение в назначении платежа для комиссий
        06/06/2012 Lyubov  - добавила КОД, КБЕ, КНП в транзакции
        28.06.2012 Lyubov  - для гарантий проводки делаются иначе
        29.06.2012 Lyubov  - изменила отправку писем, теперь адреса берутся из справ. bookcod, METROCOMBANK заменила на FORTEBANK
        02.07.2012 Lyubov  - раскомментировала смену статуса
        18.07.2012 Lyubov  - при создании проводки по лимиту запись создается также в lcres
        06.02.2013 dmitriy - проводки для Partial Covered
        14.03.2013 Lyubov  - ТЗ №1726, изменила счет для 966 комиссии с 285532 на 286931
        21.11.2013 Lyubov  - ТЗ 1363, добавила проводки для forte confirmation
*/
{global.i}

def shared var s-lc       like LC.LC.
def shared var v-lcsts    as char.
def shared var v-lcerrdes as char.
def shared var s-lcprod   as char.
def shared var s-lccor    like lcswt.lccor.
def shared var s-corsts   like lcswt.sts.
def shared var s-ourbank  as char no-undo.
def shared var v-cif      as char.
def shared var v-cifname  as char.
def shared var s-fmt      as char.
def var v-dacc        as char no-undo.
def var v-dacc-amount as deci no-undo.

def var v-exabout     as char no-undo.
def var v-sum         as deci no-undo.
def var v-per         as deci no-undo.
def var v-crc         as int  no-undo.
def var v-collacc     as char no-undo.
def var v-comacc      as char no-undo.
def var v-depacc      as char no-undo.

def var v-param       as char no-undo.
def var vdel          as char no-undo initial "^".
def var rcode         as int  no-undo.
def var rdes          as char no-undo.
def new shared var s-jh like jh.jh.
def var v-lccow       as char no-undo.
def var v-lc-amount   as deci no-undo.
def var v-st          as logi no-undo.
DEF VAR VBANK         AS CHAR no-undo.
def var v-gl          as char no-undo.

def var v-sumall      as deci no-undo.
def var v-sum1        as deci no-undo.
def var v-sum2        as deci no-undo.
def var v-yes         as logi no-undo.
def var v-str         as char no-undo.
def var v-sp          as char no-undo.
def var v-file        as char no-undo.
def var v-maillist    as char no-undo extent 2.
def var v-trx         as char no-undo.
def var v-krit        as char no-undo.
def var v-zag         as char no-undo.
def var i             as int  no-undo.
def var k             as int  no-undo.
def var v-700         as log  no-undo.
def var v-logsno      as char no-undo init "no,n,нет,н,1".
def var v-gar         as log  no-undo.
def var v-720         as logi no-undo.
def var v-numlim      as int  no-undo.
def var v-revolv      as char no-undo.
def var v-dlacc       as char no-undo init '662530'.
def var v-clacc       as char no-undo init '612530'.
def var v-text        as char no-undo init 'возобновляемым'.
def var v-lim-amount  as deci no-undo.
def var v-limcrc      as int  no-undo.
def var v-rem         as char no-undo.
def var v-covAmt      as deci no-undo.
def var v-uncovAmt    as deci no-undo.
def var v-forcon      as logi no-undo.

def buffer b-crc for crc.


pause 0.
if v-lcsts <> 'BO1' and v-lcsts <> 'Err' then do:
    message "Letter of credit's status should be BO1 or Err!" view-as alert-box error.
    return.
end.
else do:

message 'Do you want to change Credit status?' VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE ' QUESTION !' update v-yes.
if not v-yes then return.

{chk-f.i}
if s-lcprod = 'pg' then do:
    v-gar = yes.
    find first lch where lch.lc = s-lc and lch.kritcode = 'ForCon' and lch.value1 = "yes" no-lock no-error.
    if avail lch and lch.value1 = 'yes' then v-forcon = yes.
end.
if s-lcprod = 'imlc' and s-fmt = '720' then v-720 = yes. /*then do:
    find first lch where lch.lc = s-lc and lch.kritcode = 'fmt' no-lock no-error.
    if avail lch then if lch.value1 = 'mt720' then v-720 = yes.
end.*/
/*Run postings*/
find first lch where lch.lc = s-lc and lch.kritcode = 'lcCrc' no-lock no-error.
if avail lch then v-crc = integer(lch.value1).

find first lch where lch.lc = s-lc and lch.kritcode = 'ComAcc' no-lock no-error.
if avail lch then v-comacc = lch.value1.

FIND FIRST SYSC WHERE SYSC.SYSC = "OURBNK" NO-LOCK NO-ERROR.
IF AVAIL SYSC AND SYSC.CHVAL <> '' THEN VBANK =  SYSC.CHVAL.

if not v-720 then do:
    find first lch where lch.lc = s-lc and lch.kritcode = 'Cover' no-lock no-error.
    if avail lch then v-lccow = lch.value1.
    if v-lccow = '' then do:
        message "Field Covered/uncovered is empty!" view-as alert-box error.
        return.
    end.

    if v-lccow = "2" then do:
        find first lch where lch.lc = s-lc and lch.kritcode = 'CovAmt' no-lock no-error.
        if avail lch then v-covAmt = int(lch.value1).

        find first lch where lch.lc = s-lc and lch.kritcode = 'UncAmt' no-lock no-error.
        if avail lch then v-uncovAmt = int(lch.value1).
    end.

    find first lch where lch.lc = s-lc and lch.kritcode = 'NLim' no-lock no-error.
    if avail lch then v-numlim = int(lch.value1).

    if v-gar and v-lccow = '0' then do:
        find first lch where lch.lc = s-lc and lch.kritcode = 'DepAcc' no-lock no-error.
        if avail lch then v-depacc = lch.value1.
        if v-depacc = '' then do:
            message "Field Collateral Deposit Account is empty!" view-as alert-box error.
            return.
        end.
    end.

    find first lch where lch.lc = s-lc and lch.kritcode = 'ExAbout' no-lock no-error.
    if avail lch then v-exabout = lch.value1.
    if v-exabout = '' then do:
        message "Field ExAbout is empty!" view-as alert-box error.
        return.
    end.

    if v-exabout = '1' then do:
        v-per = 0.
        find first lch where lch.lc = s-lc and kritcode = 'PerAmt' no-lock no-error.
        if avail lch and trim(lch.value1) <> '' then do:
            v-per = int(entry(1,lch.value1, '/')).
            if v-per > 0 then do:
                find first lch where lch.lc = s-lc and kritcode = 'Amount' no-lock no-error.
                if avail lch then v-sum = decimal(lch.value1) + (decimal(lch.value1) * (v-per / 100)).
            end.
            if v-per <= 0 then do:
                find first lch where lch.lc = s-lc and kritcode = 'Amount' no-lock no-error.
                if avail lch then v-sum = decimal(lch.value1).
            end.
        end.
        else do:
            message "Field PerAmt is empty!" view-as alert-box error.
            return.
        end.
    end.
    else do:
        find first lch where lch.lc = s-lc and kritcode = 'Amount' no-lock no-error.
        if avail lch then v-sum = decimal(lch.value1).
    end.

    /*check balance*/
    v-sum2 = 0.
    if v-lccow = '0' then do:
        v-sum2 = v-sum.
        /* проверим, не списалось ли уже покрытие */
        /*!!*/
        if v-gar then find first lcres where lcres.lc = s-lc and lcres.levC = 1 and lcres.cacc = v-depacc and lcres.jh > 0 no-lock no-error.
                 else find first lcres where lcres.lc = s-lc and lcres.levC = 22 and lcres.jh > 0 no-lock no-error.
        if avail lcres then v-sum2 = v-sum2 - lcres.amt.
    end.

    v-sum1 = 0.
    for each lcres where lcres.lc = s-lc and lcres.com = yes and lcres.jh = 0 no-lock:
        v-sum1 = v-sum1 + lcres.amt.
    end.

    find first lch where lch.lc = s-lc and lch.kritcode = 'CollAcc' no-lock no-error.
    if avail lch then v-collacc = lch.value1.

    if v-collacc = v-comacc then do:
        v-sumall = v-sum1 + v-sum2.
        find first aaa where aaa.aaa = v-collacc no-lock no-error.
        if avail aaa then do:
            if v-sumall > aaa.cbal - aaa.hbal then do:
                message "Lack of the balance Collateral Debit Account (" + aaa.aaa + ")!" view-as alert-box error.
                return.
            end.
        end.
    end.
    else do:
        find first aaa where aaa.aaa = v-collacc no-lock no-error.
        if avail aaa then do:
            if v-sum2 > aaa.cbal - aaa.hbal then do:
                message "Lack of the balance Collateral Debit Account (" + aaa.aaa + ")!" view-as alert-box error.
                return.
            end.
        end.

        find first aaa where aaa.aaa = v-comacc no-lock no-error.
        if avail aaa then do:
            if v-sum1 > aaa.cbal - aaa.hbal then do:
                message " Lack of the balance Commissions Debit Account (" + aaa.aaa + ")!" view-as alert-box error.
                return.
            end.
        end.
    end.

    /*LC POSTINGS*/
    /*Covered*/
    if v-lccow = '0' then do:
        /*1-st posting*/
        if v-gar then find first lcres where lcres.LC = s-lc and not lcres.com and lcres.levC = 1 and lcres.cacc = v-depacc no-lock no-error.
                 else find first lcres where lcres.LC = s-lc and not lcres.com and lcres.levC = 22 no-lock no-error.

        /*find first lcres where lcres.lc = s-lc and (lcres.levC = 22 or lcres.cacc = '285521') no-lock no-error.*/
        if avail lcres then do:
           message "Attention! The 1-st posting for covered LC was done earlier!" view-as alert-box info.
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
                 message "The 1-st posting for covered LC was not done!" view-as alert-box error.
                 find first lch where lch.lc = s-lc and kritcode = 'ErrDes' no-lock no-error.
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
                create lcres.
                assign lcres.lc      = s-lc
                       lcres.dacc    = v-collacc
                       lcres.cacc    = if not v-gar then v-collacc else v-depacc
                       lcres.amt     = v-sum
                       lcres.crc     = v-crc
                       lcres.com     = no
                       lcres.comcode = ''
                       lcres.rwho    = g-ofc
                       lcres.rwhn    = g-today
                       lcres.jh      = s-jh
                       lcres.jdt     = g-today
                       lcres.trx     = v-trx
                       lcres.levC    = if not v-gar then 22 else 1
                       lcres.levD    = 1
                       lcres.rem     = 'Списание покрытия ' + s-lc
                       lcres.bank    = VBANK
                       v-st = yes.
            end.
            message "The 1-st posting for covered LC was done!" view-as alert-box info.
        end.

        /*2-nd posting*/
        if not v-gar then find first lcres where lcres.lc = s-lc and lcres.levD = 23 no-lock no-error.
                     else find first lcres where lcres.lc = s-lc and lcres.levD = 1 and lcres.dacc = '605561' no-lock no-error.
        if avail lcres then do:
           message "Attention! The 2-nd posting for covered LC was done earlier!" view-as alert-box info.
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
               message "The 2-nd posting for covered LC was not done!" view-as alert-box error.
               find first lch where lch.lc = s-lc and kritcode = 'ErrDes' no-lock no-error.
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
                create lcres.
                assign lcres.lc      = s-lc
                       lcres.dacc    = if not v-gar then v-collacc else '605561'
                       lcres.cacc    = if not v-gar then '652000'  else '655561'
                       lcres.amt     = v-sum
                       lcres.crc     = v-crc
                       lcres.com     = no
                       lcres.comcode = ''
                       lcres.rwho    = g-ofc
                       lcres.rwhn    = g-today
                       lcres.jh      = s-jh
                       lcres.jdt     = g-today
                       lcres.trx     = v-trx
                       lcres.levC    = 1
                       lcres.levD    = if not v-gar then 23 else 1
                       lcres.rem     = 'Требования/обязательства ' + s-lc
                       lcres.bank    = VBANK.
                v-st = yes.
            end.
            message "The 2-nd posting for covered LC was done!" view-as alert-box info.
        end.
    end.

/* dmitriy --------------------------------------------------------------------*/
    /*Partial Covered*/
    else if v-lccow = '2' then do:
        if v-per > 0 then do:
            v-covAmt = v-covAmt + (v-covAmt * (v-per / 100) ).
            v-uncovAmt = v-uncovAmt + (v-uncovAmt * (v-per / 100) ).
        end.

        /*1-st posting*/
        if v-gar then find first lcres where lcres.LC = s-lc and not lcres.com and lcres.levC = 1 and lcres.cacc = v-depacc no-lock no-error.
                 else find first lcres where lcres.LC = s-lc and not lcres.com and lcres.levC = 22 no-lock no-error.

        /*find first lcres where lcres.lc = s-lc and (lcres.levC = 22 or lcres.cacc = '285521') no-lock no-error.*/
        if avail lcres then do:
           message "Attention! The 1-st posting for covered LC was done earlier!" view-as alert-box info.
        end.
        else do:
            if not v-gar
            then assign v-param = string(v-covAmt) + vdel + string(v-crc) + vdel + v-collacc + vdel + s-lc + vdel + '1' + vdel + '4' + vdel + '181'
                        v-trx   = 'cif0013'.
            else assign v-param = string(v-covAmt) + vdel + string(v-crc) + vdel + v-collacc + vdel + v-depacc + vdel + 'Списание покрытия ' + s-lc + vdel + '1' + vdel + '4' + vdel + '181'
                        v-trx   = 'cif0020'.
            s-jh = 0.
            run trxgen (v-trx, vdel, v-param, "cif" , s-lc , output rcode, output rdes, input-output s-jh).
            if rcode ne 0 then do:
                 message rdes.
                 pause.
                 message "The 1-st posting for covered LC was not done!" view-as alert-box error.
                 find first lch where lch.lc = s-lc and kritcode = 'ErrDes' no-lock no-error.
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
                create lcres.
                assign lcres.lc      = s-lc
                       lcres.dacc    = v-collacc
                       lcres.cacc    = if not v-gar then v-collacc else v-depacc
                       lcres.amt     = v-covAmt
                       lcres.crc     = v-crc
                       lcres.com     = no
                       lcres.comcode = ''
                       lcres.rwho    = g-ofc
                       lcres.rwhn    = g-today
                       lcres.jh      = s-jh
                       lcres.jdt     = g-today
                       lcres.trx     = v-trx
                       lcres.levC    = if not v-gar then 22 else 1
                       lcres.levD    = 1
                       lcres.rem     = 'Списание покрытия ' + s-lc
                       lcres.bank    = VBANK
                       v-st = yes.
            end.
            message "The 1-st posting for covered LC was done!" view-as alert-box info.
        end.

        /*2-nd posting*/
        if not v-gar then find first lcres where lcres.lc = s-lc and lcres.levD = 23 no-lock no-error.
                     else find first lcres where lcres.lc = s-lc and lcres.levD = 1 and lcres.dacc = '605561' no-lock no-error.
        if avail lcres then do:
           message "Attention! The 2-nd posting for covered LC was done earlier!" view-as alert-box info.
        end.
        else do:
            if not v-gar
            then assign v-param = string(v-covAmt) + vdel + string(v-crc) + vdel + '23' + vdel + v-collacc + vdel +
                                  '652000' + vdel + s-lc
                        v-trx   = 'cif0014'.
            else assign v-param = string(v-covAmt) + vdel + string(v-crc) + vdel + '605561' + vdel +
                                  '655561' + vdel + 'PG треб/обязат по вып покрыт/непокрыт аккредитивам ' + s-lc
                        v-trx   = 'uni0144'.
            s-jh = 0.
            run trxgen (v-trx, vdel, v-param, "cif" , s-lc , output rcode, output rdes, input-output s-jh).
            if rcode ne 0 then do:
               message rdes.
               pause.
               message "The 2-nd posting for covered LC was not done!" view-as alert-box error.
               find first lch where lch.lc = s-lc and kritcode = 'ErrDes' no-lock no-error.
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
                create lcres.
                assign lcres.lc      = s-lc
                       lcres.dacc    = if not v-gar then v-collacc else '605561'
                       lcres.cacc    = if not v-gar then '652000'  else '655561'
                       lcres.amt     = v-covAmt
                       lcres.crc     = v-crc
                       lcres.com     = no
                       lcres.comcode = ''
                       lcres.rwho    = g-ofc
                       lcres.rwhn    = g-today
                       lcres.jh      = s-jh
                       lcres.jdt     = g-today
                       lcres.trx     = v-trx
                       lcres.levC    = 1
                       lcres.levD    = if not v-gar then 23 else 1
                       lcres.rem     = 'Требования/обязательства ' + s-lc
                       lcres.bank    = VBANK.
                v-st = yes.
            end.
            message "The 2-nd posting for covered LC was done!" view-as alert-box info.
        end.

        /*3-d posting*/
            if not v-gar then find first lcres where lcres.lc = s-lc and lcres.levD = 24 no-lock no-error.
                         else find first lcres where lcres.lc = s-lc and lcres.levD = 1 and lcres.dacc = '605562' no-lock no-error.
            if avail lcres then do:
               message "Attention! The 1-st posting for uncovered LC was done earlier!" view-as alert-box info.
            end.
            else do:
                if not v-gar
                then assign v-param = string(v-uncovAmt) + vdel + string(v-crc) + vdel + '24' + vdel + v-comacc + vdel +
                                      '650510' + vdel + s-lc
                            v-trx   = 'cif0014'.
                else assign v-param = string(v-uncovAmt) + vdel + string(v-crc) + vdel + '605562' + vdel +
                                      '655562' + vdel + 'PG треб/обязат по вып покрыт/непокрыт аккредитивам ' + s-lc
                            v-trx   = 'uni0144'.

                s-jh = 0.
                run trxgen (v-trx, vdel, v-param, "cif" , s-lc , output rcode, output rdes, input-output s-jh).
                        if rcode ne 0 then do:
                           message rdes.
                           pause.
                           message "The 1-st posting for uncovered LC was not done!" view-as alert-box error.
                           find first lch where lch.lc = s-lc and kritcode = 'ErrDes' no-lock no-error.
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
                    create lcres.
                    assign lcres.lc      = s-lc
                           lcres.dacc    = if not v-gar then v-comacc else '605562'
                           lcres.cacc    = if not v-gar then '650510' else '655562'
                           lcres.amt     = v-uncovAmt
                           lcres.crc     = v-crc
                           lcres.com     = no
                           lcres.comcode = ''
                           lcres.rwho    = g-ofc
                           lcres.rwhn    = g-today
                           lcres.jh      = s-jh
                           lcres.jdt     = g-today
                           lcres.trx     = v-trx
                           lcres.levC    = 1
                           lcres.levD    = if not v-gar then 24 else 1
                           lcres.rem     = 'Требования/обязательства ' + s-lc
                           lcres.bank    = vbank.
                    v-st = yes.
                end.
                message "The 1-st posting for uncovered LC was done!" view-as alert-box info.
            end.
        end.

        /*-----------------------------------------------------------------------------*/

        /*Uncovered*/
        else do:
            if not v-gar then find first lcres where lcres.lc = s-lc and lcres.levD = 24 no-lock no-error.
                         else find first lcres where lcres.lc = s-lc and lcres.levD = 1 and lcres.dacc = '605562' no-lock no-error.
            if avail lcres then do:
               message "Attention! The 1-st posting for uncovered LC was done earlier!" view-as alert-box info.
            end.
            else do:
                if not v-gar
                then assign v-param = string(v-sum) + vdel + string(v-crc) + vdel + '24' + vdel + v-comacc + vdel +
                                      '650510' + vdel + s-lc
                            v-trx   = 'cif0014'.
                else assign v-param = string(v-sum) + vdel + string(v-crc) + vdel + '605562' + vdel +
                                      '655562' + vdel + 'PG треб/обязат по вып покрыт/непокрыт аккредитивам ' + s-lc
                            v-trx   = 'uni0144'.

                s-jh = 0.
                run trxgen (v-trx, vdel, v-param, "cif" , s-lc , output rcode, output rdes, input-output s-jh).
                        if rcode ne 0 then do:
                           message rdes.
                           pause.
                           message "The 1-st posting for uncovered LC was not done!" view-as alert-box error.
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
                    create lcres.
                    assign lcres.lc      = s-lc
                           lcres.dacc    = if not v-gar then v-comacc else '605562'
                           lcres.cacc    = if not v-gar then '650510' else '655562'
                           lcres.amt     = v-sum
                           lcres.crc     = v-crc
                           lcres.com     = no
                           lcres.comcode = ''
                           lcres.rwho    = g-ofc
                           lcres.rwhn    = g-today
                           lcres.jh      = s-jh
                           lcres.jdt     = g-today
                           lcres.trx     = v-trx
                           lcres.levC    = 1
                           lcres.levD    = if not v-gar then 24 else 1
                           lcres.rem     = 'Требования/обязательства ' + s-lc
                           lcres.bank    = vbank.
                    v-st = yes.
                end.
                message "The 1-st posting for uncovered LC was done!" view-as alert-box info.
            end.
        end.

        if v-forcon then do:

            find first lcres where lcres.lc = s-lc and lcres.levD = 1 and lcres.dacc = '607510' no-lock no-error.
            if avail lcres then message "Attention! The 2-nd posting for uncovered LC was done earlier!" view-as alert-box info.
            else do:
                assign v-param = string(v-sum) + vdel + string(v-crc) + vdel + '607510' + vdel + '657510' + vdel + 'Возможные требования по принятым гарантиям ' + s-lc
                       v-trx   = 'uni0144'.
                s-jh = 0.
                run trxgen (v-trx, vdel, v-param, "cif" , s-lc , output rcode, output rdes, input-output s-jh).
                if rcode ne 0 then do:
                           message rdes.
                           pause.
                           message "The 2-nd posting for uncovered LC was not done!" view-as alert-box error.
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
                    create lcres.
                    assign lcres.lc      = s-lc
                           lcres.dacc    = '607510'
                           lcres.cacc    = '655710'
                           lcres.amt     = v-sum
                           lcres.crc     = v-crc
                           lcres.com     = no
                           lcres.comcode = ''
                           lcres.rwho    = g-ofc
                           lcres.rwhn    = g-today
                           lcres.jh      = s-jh
                           lcres.jdt     = g-today
                           lcres.trx     = v-trx
                           lcres.levC    = 1
                           lcres.levD    = if not v-gar then 24 else 1
                           lcres.rem     = 'Возможные требования по принятым гарантиям ' + s-lc
                           lcres.bank    = vbank.
                    v-st = yes.
                end.
                message "The 2-nd posting for uncovered LC was done!" view-as alert-box info.
            end.

            /* 3-rd posting */
            find first lcres where lcres.lc = s-lc and lcres.levD = 1 and lcres.dacc = '607510' no-lock no-error.
            if avail lcres then message "Attention! The 3-rd posting for uncovered LC was done earlier!" view-as alert-box info.
            else do:
                assign v-param = string(1) + vdel + string(1) + vdel + '733973' + vdel + '833900' + vdel + 'Оприходование контр-гарантии ' + s-lc
                       v-trx   = 'uni0144'.
                s-jh = 0.
                run trxgen (v-trx, vdel, v-param, "cif" , s-lc , output rcode, output rdes, input-output s-jh).
                if rcode ne 0 then do:
                           message rdes.
                           pause.
                           message "The 3-rd posting for uncovered LC was not done!" view-as alert-box error.
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
                    create lcres.
                    assign lcres.lc      = s-lc
                           lcres.dacc    = '733973'
                           lcres.cacc    = '833900'
                           lcres.amt     = 1
                           lcres.crc     = 1
                           lcres.com     = no
                           lcres.comcode = ''
                           lcres.rwho    = g-ofc
                           lcres.rwhn    = g-today
                           lcres.jh      = s-jh
                           lcres.jdt     = g-today
                           lcres.trx     = v-trx
                           lcres.levC    = 1
                           lcres.levD    = if not v-gar then 24 else 1
                           lcres.rem     = 'Оприходование контр-гарантии ' + s-lc
                           lcres.bank    = vbank.
                    v-st = yes.
                end.
                message "The 3-rd posting for uncovered LC was done!" view-as alert-box info.
            end.
        end.

        if v-numlim > 0 then do:
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

            find first lclimitres where lclimitres.bank = lclimit.bank and lclimitres.cif = lclimit.cif and lclimitres.number = lclimit.number and lclimitres.lc = s-lc and lclimitres.info[1] = 'create' no-lock no-error.
            if avail lclimitres then do:
               message "Attention! The posting for limit LC was done earlier!" view-as alert-box info.
            end.
            else do:
                assign v-param = string(v-lim-amount) + vdel + string(v-limcrc) + vdel + v-dlacc + vdel +
                                      v-clacc + vdel + 'Списание доступного остатка по ' + v-text + ' кредитам в рамках ТФ, ' + v-cifname
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
                           lclimitres.dacc    = v-dlacc
                           lclimitres.cacc    = v-clacc
                           lclimitres.amt     = v-lim-amount
                           lclimitres.crc     = v-limcrc
                           lclimitres.rwho    = g-ofc
                           lclimitres.rwhn    = g-today
                           lclimitres.jh      = s-jh
                           lclimitres.jdt     = g-today
                           lclimitres.trx     = v-trx
                           lclimitres.rem     = 'Списание доступного остатка по ' + v-text + ' кредитам в рамках ТФ, ' + v-cifname
                           lclimitres.bank    = VBANK
                           lclimitres.info[1] = 'create'.

                    create lcres.
                    assign lcres.lc      = s-lc
                           lcres.dacc    = v-dlacc
                           lcres.cacc    = v-clacc
                           lcres.amt     = v-lim-amount
                           lcres.crc     = v-limcrc
                           lcres.com     = no
                           lcres.comcode = ''
                           lcres.rwho    = g-ofc
                           lcres.rwhn    = g-today
                           lcres.jh      = s-jh
                           lcres.jdt     = g-today
                           lcres.trx     = v-trx
                           lcres.levC    = 1
                           lcres.levD    = 1
                           lcres.rem     = 'Списание доступного остатка по ' + v-text + ' кредитам в рамках ТФ, ' + v-cifname
                           lcres.bank    = vbank.

                    v-st = yes.
                end.
                message "The posting for limit was done!" view-as alert-box info.
            end.
        end.
    end.
end.
    /*Commission postings*/
    find first lcres where lcres.lc = s-lc and (lcres.comcode = '970' or lcres.comcode = '966') and lcres.amt > 0 and lcres.jh = 0 no-lock no-error.
    if avail lcres then do:
        v-rem = if num-entries(lcres.rem,';') = 2 then entry(1,lcres.rem,';') else lcres.rem.
        if not v-gar
            then assign v-param = string(LCres.amt) + vdel + string(lcres.crc) + vdel + v-comacc + vdel + s-lc + ' ' + v-rem + vdel + '1' + vdel + '4' + vdel + '181'
                        v-trx   = 'cif0011'.
            else assign v-param = string(LCres.amt) + vdel + string(lcres.crc) + vdel + v-comacc + vdel + '286931' + vdel + s-lc + ' ' + v-rem + vdel + '1' + vdel + '4' + vdel + '181'
                        v-trx   = 'cif0015'.
        s-jh = 0.
        run trxgen (v-trx, vdel, v-param, "cif" , s-lc , output rcode, output rdes, input-output s-jh).
                if rcode ne 0 then do:
                   message rdes.
                   pause.
                   message "The commission posting (" + lcres.comcode + ") was not done!" view-as alert-box error.
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
            find current lcres exclusive-lock no-error.
            if avail lcres then
            assign lcres.rwho = g-ofc
                   lcres.rwhn = g-today
                   lcres.jh   = s-jh
                   lcres.jdt  = g-today
                   lcres.trx  = v-trx.
            v-st = yes.
            find current LCres no-lock no-error.
            find first lc where lc.lc = s-lc exclusive-lock.
            lc.comsum = lcres.amt.
            find current lc no-lock.
        end.
        message "The commission posting (" + lcres.comcode + ") was done!" view-as alert-box info.
    end.

    for each lcres where lcres.lc = s-lc and lcres.com  and lcres.comcode <> '970' and lcres.comcode <> '966' and lcres.amt > 0 and lcres.jh = 0 exclusive-lock:
        find first tarif2 where tarif2.str5  = lcres.comcode and tarif2.stat = 'r' no-lock no-error.
        if avail tarif2 then v-gl = string(tarif2.kont).
        if v-gar then
             assign v-param = string(lcres.amt) + vdel + v-comacc + vdel + '286920' + vdel + s-lc + ' ' + lcres.rem + vdel + string(lcres.amt) + vdel + v-gl
                    v-trx   = 'cif0023'.
        else assign v-rem = if num-entries(lcres.rem,';') = 2 then entry(1,lcres.rem,';') else lcres.rem
                    v-param = string(LCres.amt) + vdel + string(lcres.crc) + vdel + v-comacc + vdel + v-gl + vdel + s-lc + ' ' + v-rem + vdel + '1' + vdel + '4' + vdel + '181'
                    v-trx = 'cif0015'.

        s-jh = 0.
        run trxgen (v-trx, vdel, v-param, "cif" , s-lc , output rcode, output rdes, input-output s-jh).
                if rcode ne 0 then do:
                   message rdes.
                   pause.
                   message "The commission posting (" + lcres.comcode + ") was not done!" view-as alert-box error.
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
            assign lcres.rwho = g-ofc
                   lcres.rwhn = g-today
                   lcres.jh   = s-jh
                   lcres.jdt  = g-today
                   lcres.trx  = v-trx.
           v-st = yes.
        end.
        message "The commission posting (" + lcres.comcode + ") was done!" view-as alert-box info.
    end.

        if chk-f("$HOME/.ssh/id_swift") ne '0' then do:
            message "There is no file $HOME/.ssh/id_swift!" view-as alert-box error.
            find first lch where lch.lc = s-lc and lch.kritcode = 'ErrDes' no-lock no-error.
            if avail lch then find current lch exclusive-lock.
            else create lch.
            assign lch.value1   = "There is no file $HOME/.ssh/id_swift!"
                   lch.lc       = s-lc
                   lch.kritcode = 'ErrDes'
                   lch.bank     = vbank.
            run LCsts(v-lcsts,'Err').
            return.
        end.

        if s-lcprod = 'imlc' then do:
            if not v-720 then run LCmt no-error.
            else run lcmtlch.p ('720', yes) no-error.
        end.
        else if s-lcprod = 'pg' then do:
            find first lch where lch.lc = s-lc  and lch.kritcode = 'MT760' no-lock no-error.
            if avail lch and lookup(lch.value1,v-logsno) = 0 then run pgmt no-error.
        end.
        else if s-lcprod = 'sblc' then do:
            /*find first lch where lch.lc = s-lc and lch.kritcode = 'fmt' no-lock no-error.
            if avail lch then do:
                if lch.value1 = 'mt700'
                then do:*/
            if s-fmt = '700' then do:
                v-700 = yes.
                run LCmt no-error.
            end.
            else do:
                run pgmt no-error.
            end.
            /*end.*/
            find first lch where lch.lc = s-lc and lch.kritcode = 'mt799' no-lock no-error.
            if avail lch and lch.value1 = 'yes' then do:
                run i799mt no-error.
                if not error-status:error then do:
                    run LCcorsts(s-corsts,'FIN').
                    find first lch where lch.lc = s-lc and  LCh.value4 = 'O799-' + string(s-lccor,'999999') and lch.kritcode = "TRNum" and lch.value1 <> '' no-lock no-error.
                    if avail lch and trim(lch.value1) <> '' then v-file = replace(lch.value1,"/", "_") + "_" + string(s-lccor,'999999').

                    find first LCswt where LCswt.LC = s-lc and LCswt.LCcor = s-lccor and LCswt.mt = 'I799' exclusive-lock no-error.
                    assign LCswt.fname1 = v-file
                           LCswt.dt     = g-today.
                    find current LCswt no-lock no-error.
                end.
            end.
        end.
        if error-status:error then do:
            find first lch where lch.lc = s-lc and lch.kritcode = 'ErrDes' no-lock no-error.
            if avail lch then find current lch exclusive-lock.
            else create lch.
            assign lch.value1   = "File wasn't copied to SWIFT Alliance!"
                   lch.lc       = s-lc
                   lch.kritcode = 'ErrDes'
                   lch.bank     = vbank.
            find current lch no-lock no-error.
            run LCsts(v-lcsts,'Err').
            v-lcerrdes = "File wasn't copied to SWIFT Alliance!".
            return.
        end.

        run LCsts(v-lcsts,'FIN').

        if v-lcsts = 'ERR' then do:
            find first lch where lch.lc = s-lc and lch.kritcode = 'ErrDes' no-lock no-error.
            if avail lch then do:
                find current lch exclusive-lock.
                lch.value1 = ''.
                find current lch no-lock no-error.
            end.
        end.
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
            v-zag = if s-lcprod = 'imlc' then ' аккредитива: ' else if s-lcprod = 'pg' then ' гарантии: ' else ' резервного аккредитива: '.

            v-str = 'Референс инструмента: ' + s-lc + '~n' + '~n' + 'Аппликант: '.

            v-krit = if s-lcprod = 'imlc' or v-700 then 'Applic' else 'Princ'.
            find first lch where lch.lc = s-lc and lch.kritcode = v-krit no-lock no-error.
            if avail lch then v-str = v-str + trim(substr(lch.value1,1,35)) + '~n' + '~n' + 'Бенефициар: '.
            else  v-str = v-str + '~n' + '~n' + 'Бенефициар: '.

            find first lch where lch.lc = s-lc and lch.kritcode = 'Benef' no-lock no-error.
            if avail lch then v-str = v-str + trim(substr(lch.value1,1,35)) + '~n' + '~n' + 'Сумма сделки: '.
            else  v-str = v-str + '~n' + '~n' + 'Сумма сделки: '.

            find first lch where lch.lc = s-lc and lch.kritcode = 'Amount' no-lock no-error.
            if avail lch then do:
                v-str = v-str + trim(replace(string(deci(lch.value1),'>>>>>>>>9.99'),'.',',')) + '~n' + '~n' + 'Валюта сделки: '.
            end.
            else  v-str = v-str + '~n' + '~n' + 'Валюта сделки: '.

            find first lch where lch.lc = s-lc and lch.kritcode = 'lcCrc' no-lock no-error.
            if avail lch then do:
               find first crc where crc.crc = integer(lch.value1) no-lock no-error.
               if avail crc then v-str = v-str + crc.code + '~n' + '~n' + 'Дата выпуска' + v-zag.
            end.
            else  v-str = v-str + '~n' + '~n' + 'Дата выпуска' + v-zag.

            v-krit = if s-lcprod = 'imlc' or v-700 then 'DtIs' else 'Date'.
            find first lch where lch.lc = s-lc and lch.kritcode = v-krit no-lock no-error.
            if avail lch then v-str = v-str + lch.value1 + '~n' + '~n' + 'Дата истечения' + v-zag.
            else  v-str = v-str + '~n' + '~n' + 'Дата истечения' + v-zag.

            find first lch where lch.lc = s-lc and lch.kritcode = 'DtExp' no-lock no-error.
            if avail lch then v-str = v-str + lch.value1 + '~n'.
            else  v-str = v-str + '~n'.
            v-zag = 'Выпуск' + right-trim(v-zag,': ').
            run mail(v-maillist[1],"FORTEBANK <abpk@fortebank.com>", v-zag,v-str, "", "","").
            if v-maillist[2] <> '' then run mail(v-maillist[2],"FORTEBANK <abpk@fortebank.com>", v-zag,v-str, "", "","").
        end.
end.