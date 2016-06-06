/*lclimbo2.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        Limits - акцепт второго менеджера бэк-офиса + проводки
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        14-7-1-1 опция BO2
 * AUTHOR
        26/09/2011 id00810
 * BASES
        BANK COMM
 * CHANGES
*/
{global.i}

def shared var s-cif       as char.
def shared var s-number    as int.
def shared var s-ourbank   as char no-undo.
def shared var v-limsts    as char.
def shared var v-cifname   as char.

def var v-revolv    as char no-undo.
def var v-amount    as char no-undo.
def var v-crc       as int  no-undo.
def var v-dacc      as char no-undo init '612530'.
def var v-cacc      as char no-undo init '662530'.
def var v-text      as char no-undo init 'возобновляемым'.
def var i           as int  no-undo.
def var k           as int  no-undo.
def var v-logsno    as char init "no,n,нет,н,1".
def var v-param     as char no-undo.
def var vdel        as char no-undo initial "^".
def var rcode       as int  no-undo.
def var rdes        as char no-undo.
def var v-trx       as char no-undo.
def var v-yes       as logi no-undo.
def new shared var s-jh like jh.jh.

pause 0.
if v-limsts <> 'BO1' and v-limsts <> 'Err' then do:
    message "Limit's status should be BO1 or Err!" view-as alert-box error.
    return.
end.

message 'Do you want to change Limit status?' VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE ' QUESTION !' update v-yes.
if not v-yes then return.

find first lclimit where lclimit.bank = s-ourbank and lclimit.cif = s-cif and lclimit.number = s-number no-lock no-error.
if not avail lclimit then return.

find first lclimith where lclimith.cif = s-cif and lclimith.number = s-number  and lclimith.kritcode = 'Revolv' no-lock no-error.
if avail lclimith then v-revolv = lclimith.value1.
if lookup(v-revolv,v-logsno) > 0 then assign v-dacc = '612540' v-cacc = '662540' v-text = 'невозобновляемым'.

find first lclimith where lclimith.cif = s-cif and lclimith.number = s-number  and lclimith.kritcode = 'Amount' no-lock no-error.
if avail lclimith then v-amount = lclimith.value1.
if v-amount = '' then do:
    message "Field Amount is empty!" view-as alert-box error.
    return.
end.
find first lclimith where lclimith.cif = s-cif and lclimith.number = s-number  and lclimith.kritcode = 'lcCrc' no-lock no-error.
if avail lclimith then v-crc = int(lclimith.value1).
if v-crc = 0 then do:
    message "Field Currency Code is empty!" view-as alert-box error.
    return.
end.
find first crc where crc.crc = v-crc no-lock no-error.
if not avail crc then return.

 find first lclimitres where lclimitres.bank = s-ourbank and lclimitres.cif = s-cif and lclimitres.number = s-number and lclimitres.dacc = v-dacc and lclimitres.cacc = v-cacc no-lock no-error.
 if avail lclimitres then message "Attention! The posting for Limit was done earlier!" view-as alert-box info.
 else do:
     assign v-param = v-amount + vdel + string(v-crc) + vdel + v-dacc + vdel + v-cacc + vdel + 'Создание доступного остатка по ' + v-text + ' кредитам в рамках ТФ, ' + vdel + v-cifname
            v-trx   = 'vnb0005'.
     s-jh = 0.
     run trxgen (v-trx, vdel, v-param, "cif" , s-cif , output rcode, output rdes, input-output s-jh).
     if rcode ne 0 then do:
          message rdes.
          pause.
          message "The posting for Limit was not done!" view-as alert-box error.
          find first lclimith where lclimith.cif = s-cif and lclimith.number = s-number  and lclimith.kritcode = 'ErrDes' no-lock no-error.
          if avail lclimith then find current lclimith exclusive-lock.
          if not avail lclimith then create lclimith.
          assign lclimith.bank     = s-ourbank
                 lclimith.cif      = s-cif
                 lclimith.number   = s-number
                 lclimith.kritcode = 'ErrDes'
                 lclimith.value1   = string(rcode) + ' ' + rdes.
          run lclimsts(v-limsts,'Err').
          return.
     end.

     if s-jh > 0 then do:
         create lclimitres.
         assign lclimitres.bank     = s-ourbank
                lclimitres.cif      = s-cif
                lclimitres.number   = s-number
                lclimitres.dacc    = v-dacc
                lclimitres.cacc    = v-cacc
                lclimitres.amt     = deci(v-amount)
                lclimitres.crc     = v-crc
                lclimitres.rwho    = g-ofc
                lclimitres.rwhn    = g-today
                lclimitres.jh      = s-jh
                lclimitres.jdt     = g-today
                lclimitres.trx     = v-trx
                lclimitres.rem     = 'Создание доступного остатка по ' + v-text + ' кредитам в рамках ТФ, ' + vdel + v-cifname
                .
     end.
     message "The posting for Limit was done!" view-as alert-box info.
 end.

run lclimsts(v-limsts,'FIN').

if v-limsts = 'ERR' then do:
    find first lclimith where lclimith.cif = s-cif and lclimith.number = s-number  and lclimith.kritcode = 'ErrDes' no-lock no-error.
    if avail lclimith then do:
        find current lclimith exclusive-lock.
        lclimith.value1 = ''.
        find current lclimith no-lock no-error.
    end.
end.
