/* lcbo2exp.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        Expire - акцепт второго менеджера бэк-офиса + проводки
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
        07/04/2011 id00810
 * BASES
        BANK COMM
 * CHANGES
        15/04/2011 id00810 - для события Cancel
        29/07/2011 id00810 - счет DepAcc вместо 285521 для покрытого PG (c 01/08/2011)
        05/10/2011 id00810 - учет лимита
        28.06.2012 Lyubov  - добавила проводки по комиссиям, для PG/EXPG создаются 2 проводки 220310 -> 286920 и 286920 -> 4612(20/11)
        29.06.2012 Lyubov  - изменила отправку писем, теперь адреса берутся из справ. bookcod, METROCOMBANK заменила на FORTEBANK
        10.07.2012 Lyubov  - добавила проводки для непокрытых сделок по списанию несамортизированного остатка
        31.07.2012 Lyubov  - исправлены ошибки
*/

{global.i}

def shared var s-lc      like lc.lc.
def shared var s-event   like lcevent.event.
def shared var s-number  like lcevent.number.
def shared var s-sts     like lcevent.sts.
def shared var v-lcsts   as   char.
def shared var s-lcprod  as   char.
def shared var v-cif     as   char.
def shared var v-cifname as   char.
def shared var v-rcacc   as   char.
def shared var s-ourbank as   char no-undo.

def new shared var s-jh like jh.jh.

def var v-crc      as int  no-undo.
def var v-collacc  as char no-undo.
def var v-comacc   as char no-undo.
def var v-depacc   as char no-undo.
def var v-param    as char no-undo.
def var vdel       as char no-undo initial "^".
def var rcode      as int  no-undo.
def var rdes       as char no-undo.
def var v-lccow    as char no-undo.
def var v-sum      as deci no-undo extent 2.
def var v-num      as char no-undo extent 2.
def var v-dacc     as char no-undo.
def var v-cacc     as char no-undo.
def var v-levD     as int  no-undo.
def var v-levc     as int  no-undo.
def var v-rem      as char no-undo.
def var v-yes      as logi no-undo init yes.
def var v-str      as char no-undo.
def var v-sp       as char no-undo.
def var v-maillist as char no-undo extent 2.
def var v-trx      as char no-undo.
def var v-krit     as char no-undo.
def var v-zag      as char no-undo.
def var i          as int  no-undo.
def var k          as int  no-undo.
def var v-gar      as logi no-undo.
def var v-limsum   as deci no-undo.
def var v-dlacc    as char no-undo init '612530'.
def var v-clacc    as char no-undo init '662530'.
def var v-text     as char no-undo init 'возобновляемым'.
def var v-limcrc   as int  no-undo.
def var v-numlim   as int  no-undo.

def buffer b-lceventres for lceventres.

/*{LC.i}*/
pause 0.
if lookup(s-sts,'BO1,ERR') = 0 then do:
    message "Event status should be BO2 or Err!" view-as alert-box error.
    return.
end.

message 'Do you want to change event status?' VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE ' QUESTION !' update v-yes.
if not v-yes then return.

find first lc where lc.lc = s-lc no-lock no-error.
if not avail lc then return.
if s-lcprod = 'pg' then v-gar = yes.

find first lch where lch.lc = s-lc and lch.kritcode = 'Cover' no-lock no-error.
if avail lch then v-lccow = lch.value1.
if v-lccow = '' then do:
    message "Field Covered/uncovered is empty!" view-as alert-box error.
    return.
end.

find first lch where lch.lc = s-lc and lch.kritcode = 'lcCrc' no-lock no-error.
if avail lch then v-crc = int(lch.value1).

if v-lccow = '0' then do:
    find first lch where lch.lc = s-lc and lch.kritcode = 'CollAcc' no-lock no-error.
    if avail lch then v-collacc = lch.value1.
    if v-collacc = '' then do:
        message "Field CollAcc is empty!" view-as alert-box error.
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
    message "Field ComAcc is empty!" view-as alert-box error.
    return.
end.

find first lceventh where lceventh.bank = s-ourbank and lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number and lceventh.kritcode = 'OutBal' no-lock no-error.
if avail lceventh then v-sum[1] = deci(lceventh.value1).

find first lceventh where lceventh.bank = s-ourbank and lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number and lceventh.kritcode = 'Claims' no-lock no-error.
if avail lceventh then v-sum[2] = deci(lceventh.value1).

find first lceventh where lceventh.bank = lc.bank and lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number and lceventh.kritcode = 'Limits' no-lock no-error.
if avail lceventh then v-limsum = deci(lceventh.value1).

assign v-num[1] = '1-st' v-num[2] = '2-nd'.

/*Run postings*/
do i = 1 to 2:
   if v-sum[i] = 0 then next.
   if i = 1 then
    if not v-gar then find first lceventres where lceventres.lc = s-lc and lceventres.event = s-event and lceventres.number = s-number and lceventres.levD = 22 no-lock no-error.
                 else find first lceventres where lceventres.lc = s-lc and lceventres.event = s-event and lceventres.number = s-number and lceventres.levD = 1  and lceventres.dacc = v-depacc no-lock no-error.
   else find first lceventres where lceventres.lc = s-lc and lceventres.event = s-event and lceventres.number = s-number and (lceventres.levc = 23 or lceventres.levc = 24 or lceventres.cacc = '605561' or lceventres.cacc = '605562') no-lock no-error.
   if avail lceventres then do:
    message "Attention! The " + v-num[i] + " posting for event was done earlier!" view-as alert-box info.
   end.
   else do:
       if i = 1 then do:
        if not v-gar then
        assign v-dacc  = v-collacc
               v-cacc  = v-collacc
               v-levD  = 22
               v-levC  = 1
               v-param = string(v-sum[1]) + vdel + string(v-crc) + vdel + v-collacc + vdel + s-lc
               v-trx   = 'cif0017'.
        else
        assign v-dacc  = v-depacc
               v-cacc  = v-collacc
               v-levD  = 1
               v-levC  = 1
               v-param = string(v-sum[1]) + vdel + string(v-crc) + vdel + v-dacc + vdel + v-collacc + vdel + 'Возврат покрытия ' + s-lc + vdel + '1' + vdel + '4' + vdel + '181'
               v-trx   = 'cif0020'.
        v-rem   = 'Возврат покрытия ' + s-lc.
       end.
       else  do:
        if s-lcprod = 'imlc' then
        assign v-dacc  = if v-lccow = '0' then '652000' else '650510'
                    v-cacc  = if v-lccow = '0' then v-collacc else v-comacc
                    v-levD  = 1
                    v-levC  = if v-lccow = '0' then 23 else 24
                    v-param = string(v-sum[2]) + vdel + string(v-crc) + vdel + v-dacc + vdel + string(v-levC) + vdel + v-cacc + vdel + s-lc
                    v-trx   = 'cif0018'.
        else
        assign v-dacc  = if v-lccow = '0' then '655561' else '655562'
                    v-cacc  = if v-lccow = '0' then '605561' else '605562'
                    v-levD  = 1
                    v-levC  = 1
                    v-param = string(v-sum[2]) + vdel + string(v-crc) + vdel + v-dacc + vdel + v-cacc + vdel + 'Возврат требований/обязательств по гарантии ' + s-lc
                    v-trx   = 'uni0144'.
        v-rem   = 'Возврат требований/обязательств ' + s-lc.
       end.
       s-jh = 0.
       run trxgen (v-trx, vdel, v-param, "cif" , s-lc , output rcode, output rdes, input-output s-jh).
         if rcode ne 0 then do:
              message rdes.
              pause.
              message "The " + v-num[i] + " posting was not done!" view-as alert-box error.
              find first lceventh where lceventh.bank = s-ourbank and lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number and lceventh.kritcode = 'ErrDes' no-lock no-error.
              if avail lceventh then find current lceventh exclusive-lock.
              if not avail lceventh then create lceventh.
              assign  lceventh.lc       = s-lc
                      lceventh.event    = s-event
                      lceventh.number   = s-number
                      lceventh.bank     = s-ourbank
                      lceventh.kritcode = 'ErrDes'
                      lceventh.value1   = string(rcode) + ' ' + rdes.
              run lcstse(s-sts,'Err').
              return.
           end.

       if s-jh > 0 then do:
            create  lceventres.
            assign  lceventres.lc      = s-lc
                    lceventres.event   = s-event
                    lceventres.number  = s-number
                    lceventres.dacc    = v-dacc
                    lceventres.cacc    = v-cacc
                    lceventres.amt     = v-sum[i]
                    lceventres.crc     = v-crc
                    lceventres.com     = no
                    lceventres.comcode = ''
                    lceventres.rwho    = g-ofc
                    lceventres.rwhn    = g-today
                    lceventres.jh      = s-jh
                    lceventres.jdt     = g-today
                    lceventres.trx     = v-trx
                    lceventres.levD    = v-levD
                    lceventres.levC    = v-levC
                    lceventres.bank    = s-ourbank
                    lceventres.rem     = v-rem.
       end.
       message "The " + v-num[i] + " posting was done!" view-as alert-box info.
   end.
end.
if v-limsum > 0 then do:
    find first lch where lch.lc = s-lc and lch.kritcode = 'NLim' no-lock no-error.
    if avail lch then v-numlim = int(lch.value1).
    find first lclimith where lclimith.cif = v-cif and lclimith.number = v-numlim and lclimith.kritcode = 'lcCrc' no-lock no-error.
    if avail lclimith then v-limcrc = int(lclimith.value1).
    find first lclimitres where lclimitres.bank = s-ourbank and lclimitres.cif = v-cif and lclimitres.number = int(lch.value1) and lclimitres.lc = s-lc and lclimitres.info[1] = 'expire' no-lock no-error.
    if avail lclimitres then do:
        message "Attention! The limit-posting for event was done earlier!" view-as alert-box info.
    end.
    else do:
         assign v-param = string(v-limsum) + vdel + string(v-limcrc) + vdel + v-dlacc + vdel +
                                  v-clacc + vdel + 'Восстановление доступного остатка по ' + v-text + ' кредитам в рамках ТФ, ' + v-cifname
                        v-trx   = 'uni0144'.
            s-jh = 0.
            run trxgen (v-trx, vdel, v-param, "cif" , s-lc , output rcode, output rdes, input-output s-jh).
            if rcode ne 0 then do:
               message rdes.
               pause.
               message "The posting for limit was not done!" view-as alert-box error.
               find first lceventh where lceventh.bank = s-ourbank and lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number and lceventh.kritcode = 'ErrDes' no-lock no-error.
               if avail lceventh then find current lceventh exclusive-lock.
               if not avail lceventh then create lceventh.
               assign  lceventh.lc       = s-lc
                       lceventh.event    = s-event
                       lceventh.number   = s-number
                       lceventh.bank     = s-ourbank
                       lceventh.kritcode = 'ErrDes'
                       lceventh.value1   = string(rcode) + ' ' + rdes.
              run lcstse(s-sts,'Err').
              return.
            end.
            if s-jh > 0 then do:
                create lclimitres.
                assign lclimitres.cif     =  v-cif
                       lclimitres.number  = v-numlim
                       lclimitres.lc      = s-lc
                       lclimitres.dacc    = v-dlacc
                       lclimitres.cacc    = v-clacc
                       lclimitres.amt     = v-limsum
                       lclimitres.crc     = v-limcrc
                       lclimitres.rwho    = g-ofc
                       lclimitres.rwhn    = g-today
                       lclimitres.jh      = s-jh
                       lclimitres.jdt     = g-today
                       lclimitres.trx     = v-trx
                       lclimitres.rem     = 'Восстановление доступного остатка по ' + v-text + ' кредитам в рамках ТФ, ' + v-cifname
                       lclimitres.bank    = s-ourbank
                       lclimitres.info[1] = 'expire'.
            end.
            message "The posting for limit was done!" s-jh view-as alert-box info.
    end.
end.

if s-event = 'cnl' and v-lccow = '1' then do:
    if not v-gar then find first lceventres where lceventres.lc = s-lc and lceventres.event = s-event and lceventres.number = s-number and lceventres.dacc = '285531' no-lock no-error.
                 else find first lceventres where lceventres.lc = s-lc and lceventres.event = s-event and lceventres.number = s-number and lceventres.dacc = '285532' no-lock no-error.
        if avail lceventres then message "Attention! The posting for event was done earlier!" view-as alert-box info.
    else do:
         find lcres where lcres.lc = s-lc and lookup(lcres.comcod,'966,970') > 0 no-lock no-error.
         find last lc where lc.lc = s-lc and lc.comsum > 0 no-lock no-error.
         if avail lc then do:
             v-dacc = if not v-gar then v-comacc else '285532'.
             v-cacc = v-comacc.
             v-levD = if not v-gar then 25 else 1.
             v-levC = 1.
             if v-rcacc = '1' then do:
                 if v-gar then assign v-param = string(lc.comsum) + vdel + string(lcres.crc) + vdel + v-dacc + vdel + string(v-levC) + vdel + v-cacc + vdel + 'Возврат суммы излишне уплаченного комиссионного вознаграждения по ' + s-lc
                                      v-trx   = 'cif0018'.
                 else assign v-param = string(lc.comsum) + vdel + string(lcres.crc) + vdel + v-comacc + vdel + 'Возврат суммы излишне уплаченного комиссионного вознаграждения по ' + s-lc  + vdel + '1' + vdel + '4' + vdel + '840'
                             v-trx   = 'cif0016'.
             end.
             else do:
                 if v-gar then assign v-param = string(lc.comsum) + vdel + string(lcres.crc) + vdel + v-dacc + vdel + '461220' + vdel + 'Возврат суммы излишне уплаченного комиссионного вознаграждения по ' + s-lc
                                      v-trx   = 'uni0144'.
                 else assign v-param = string(lc.comsum) + vdel + string(lcres.crc) + vdel + v-comacc + vdel + '461220' + vdel + 'Возврат суммы излишне уплаченного комиссионного вознаграждения по ' + s-lc
                             v-trx   = 'cif0012'.
             end.
                s-jh = 0.


                run trxgen (v-trx, vdel, v-param, "cif" , s-lc , output rcode, output rdes, input-output s-jh).
             if rcode ne 0 then do:
                  message rdes.
                  pause.
                  message "The " + v-num[i] + " posting was not done!" view-as alert-box error.
                  find first lceventh where lceventh.bank = s-ourbank and lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number and lceventh.kritcode = 'ErrDes' no-lock no-error.
                  if avail lceventh then find current lceventh exclusive-lock.
                  if not avail lceventh then create lceventh.
                  assign  lceventh.lc       = s-lc
                          lceventh.event    = s-event
                          lceventh.number   = s-number
                          lceventh.bank     = s-ourbank
                          lceventh.kritcode = 'ErrDes'
                          lceventh.value1   = string(rcode) + ' ' + rdes.
                  run lcstse(s-sts,'Err').
                  return.
               end.
           if s-jh > 0 then do:
                create  lceventres.
                assign  lceventres.lc      = s-lc
                        lceventres.event   = s-event
                        lceventres.number  = s-number
                        lceventres.dacc    = v-dacc
                        lceventres.cacc    = if v-rcacc = '1' then v-cacc else '461220'
                        lceventres.amt     = lc.comsum
                        lceventres.crc     = lcres.crc
                        lceventres.com     = yes
                        lceventres.comcode = lcres.comcod
                        lceventres.rwho    = g-ofc
                        lceventres.rwhn    = g-today
                        lceventres.jh      = s-jh
                        lceventres.jdt     = g-today
                        lceventres.trx     = v-trx
                        lceventres.levD    = v-levD
                        lceventres.levC    = v-levC
                        lceventres.bank    = s-ourbank
                        lceventres.rem     = 'Амортизация комиссионного вознаграждения'.
           end.

           if s-jh > 0 then do:
               find first b-lceventres where rowid(b-lceventres) = rowid(lceventres) exclusive-lock no-error.
               if avail b-lceventres then
               assign b-lceventres.rwho   = g-ofc
                      b-lceventres.rwhn   = g-today
                      b-lceventres.jh     = s-jh
                      b-lceventres.jdt    = g-today.
           find current b-lceventres no-lock no-error.
               find first lc where lc.lc = s-lc exclusive-lock no-error.
               if b-lceventres.levC = 25 or b-lceventres.cacc = '285532' then lc.comsum = lc.comsum + b-lceventres.amt.
               else lc.comsum = lc.comsum - b-lceventres.amt.
               find current lc no-lock no-error.
           end.
           message " The POSTING was done! " view-as alert-box info.

        end.
    end.
end.

/*Commission postings*/

for each lceventres where lceventres.lc = s-lc and lceventres.event = s-event and lceventres.number = s-number and lceventres.com and lceventres.jh = 0 and lookup(lceventres.comcod,'966,970') = 0 no-lock:

    if lceventres.amt = 0 then next.

    /*if lceventres.comcode = '970' then
        assign v-param = string(lceventres.amt) + vdel + string(lceventres.crc) + vdel + v-comacc + vdel + s-lc + ' ' + lceventres.rem + vdel + '1' + vdel + '4' + vdel + '840'
               v-trx   = if lceventres.levC = 25 then 'cif0011' else 'cif0016'.

    else if lceventres.comcode = '966' then do:
         if lceventres.cacc = '285532' then assign v-param = string(lceventres.amt) + vdel + string(lceventres.crc) + vdel + v-comacc + vdel + '285532' + vdel + s-lc + ' ' + lceventres.rem + vdel + '1' + vdel + '4' + vdel + '840'
                                                   v-trx   = 'cif0015'.
                                       else assign v-param = string(lceventres.amt) + vdel + string(lceventres.crc) + vdel + '285532' + vdel + v-comacc + vdel + 'Возврат комиссионного вознаграждения по гарантии ' + s-lc + ' ' + lceventres.rem
                                                   v-trx   = 'vnb0059'.
    end.*/

    else if lceventres.comcode = '9990' then
        assign v-param = string(lceventres.amt) + vdel + string(lceventres.crc) + vdel + v-comacc + vdel + '461220' + vdel + s-lc + ' ' + lceventres.rem + vdel + '1' + vdel + '4' + vdel + '840'
               v-trx   = 'cif0015'.

    else if lceventres.comcode = '' then do:
        if lceventres.crc > 1 then
            assign v-param = string(lceventres.amt) + vdel + string(lceventres.crc) + vdel + lceventres.dacc + vdel + lceventres.rem + vdel + '1' + vdel + '1' + vdel + '4' + vdel + '4' + vdel + '840' + vdel + '1' + vdel + lceventres.cacc
                   v-trx   = 'uni0022'.
        else assign v-param = string(lceventres.amt) + vdel + string(lceventres.crc) + vdel + lceventres.dacc + vdel + lceventres.cacc + vdel + lceventres.rem
                   v-trx   = 'uni0144'.
    end.

    else if lookup(s-lcprod,'PG,EXPG') > 0 and lookup(lceventres.comcode,'967,968,969,952,955,956,957,953,954,958,959,941,942,943,944,945,946,947') > 0 then do:
        find first tarif2 where tarif2.str5 = lceventres.comcode and tarif2.stat = 'r' no-lock no-error.
        assign v-param = string(lceventres.amt) + vdel + v-comacc + vdel + '286920' + vdel + s-lc + ' ' + lceventres.rem + vdel + string(lceventres.amt) + vdel + string(tarif2.kont)
               v-trx   = 'cif0023'.
    end.

    else do:
        find first tarif2 where tarif2.str5 = lceventres.comcode and tarif2.stat = 'r' no-lock no-error.
        if not avail tarif2 then return.
        assign v-param = string(lceventres.amt) + vdel + string(lceventres.crc) + vdel + v-comacc + vdel + string(tarif2.kont) + vdel + s-lc + ' ' + lceventres.rem + vdel + '1' + vdel + '4' + vdel + '840'
               v-trx   = 'cif0015'.
    end.

    s-jh = 0.
    run trxgen (v-trx, vdel, v-param, "cif" , s-lc , output rcode, output rdes, input-output s-jh).

    if rcode ne 0 then do:
       message rdes.
       pause.
       message "The commission posting (" + lceventres.comcode + ") was not done!" view-as alert-box error.
       find first lceventh where lceventh.bank = s-ourbank and lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number and lceventh.kritcode = 'ErrDes' no-lock no-error.
       if avail lceventh then find current lceventh exclusive-lock.
       if not avail lceventh then create lceventh.
       assign lceventh.lc       = s-lc
              lceventh.event    = s-event
              lceventh.number   = s-number
              lceventh.kritcode = 'ErrDes'
              lceventh.value1   = string(rcode) + ' ' + rdes
              lceventh.bank     = s-ourbank.
       run lcstse(s-sts,'Err').
       return.
    end.

    if s-jh > 0 then do:
        find first b-lceventres where rowid(b-lceventres) = rowid(lceventres) exclusive-lock no-error.
        if avail b-lceventres then
        assign b-lceventres.rwho   = g-ofc
               b-lceventres.rwhn   = g-today
               b-lceventres.jh     = s-jh
               b-lceventres.jdt    = g-today.

        find current b-lceventres no-lock no-error.
        if b-lceventres.comcode = '970' or b-lceventres.comcode = '966' then do:
            find first lc where lc.lc = s-lc exclusive-lock no-error.
            if b-lceventres.levC = 25 or b-lceventres.cacc = '285532' then lc.comsum = lc.comsum + b-lceventres.amt.
            else lc.comsum = lc.comsum - b-lceventres.amt.
            find current lc no-lock no-error.
        end.
    end.
    message "The commission posting (" + lceventres.comcode + ") was done!" view-as alert-box info.
end.

run lcstse(s-sts,'FIN').
pause 0.
if s-event = 'exp' then run LCsts(v-lcsts,'CLS').
else run LCsts(v-lcsts,'CNL').
if s-sts = 'ERR' then do:
    find first lceventh where lceventh.bank = s-ourbank and lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number and lceventh.kritcode = 'ErrDes' no-lock no-error.
    if avail lceventh then do:
        find current lceventh exclusive-lock.
        lceventh.value1 = ''.
        find current lceventh no-lock no-error.
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
    v-zag = if s-lcprod = 'imlc' then ' аккредитива: ' else ' гарантии: '.

    v-str = 'Референс инструмента: ' + s-lc + '~n' + '~n' + 'Аппликант: '.

    v-krit = if s-lcprod = 'imlc' then 'Applic' else 'Princ'.
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

    v-krit = if s-lcprod = 'imlc' then 'DtIs' else 'Date'.
    find first lch where lch.lc = s-lc and lch.kritcode = v-krit no-lock no-error.
    if avail lch then v-str = v-str + lch.value1 + '~n' + '~n' + 'Дата истечения' + v-zag.
    else  v-str = v-str + '~n' + '~n' + 'Дата истечения' + v-zag.

    find first lch where lch.lc = s-lc and lch.kritcode = 'DtExp' no-lock no-error.
    if avail lch then v-str = v-str + lch.value1 + '~n'.
    else  v-str = v-str + '~n'.
    v-zag = (if s-event = 'exp' then 'Закрытие ' else 'Аннулирование ') + (if s-lcprod = 'imlc' then 'аккредитива' else 'гарантии').
    run mail(v-maillist[1],"FORTEBANK <abpk@fortebank.com>", v-zag,v-str, "", "","").
    if v-maillist[2] <> '' then run mail(v-maillist[2],"FORTEBANK <abpk@fortebank.com>", v-zag,v-str, "", "","").
end.
