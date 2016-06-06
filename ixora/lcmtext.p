/* lcmtext.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        External Charges - MT756 и МТ202
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
        29/03/2011 id00810
 * BASES
        BANK COMM
 * CHANGES
        08/04/2011 id00810 - корректировка вывода поля 58D
        03/06/2011 id00810 - обработка полей MT750 для Advice of Discrepancy, MT752 для Authorisation to Pay
        28/06/2011 id00810 - ошибка: не было двоеточия перед номером поля в МТ
        04/08/2011 id00810 - {cr-swthead.i} формирование заголовка сообщения
        13/09/2011 id00810 - обработка ошибки копирования в SWIFT
        14/10/2011 id00810 - обработка полей МТ740 для Authorization to Reimburse, MT742 для Reimbursement Claim
        10/02/2012 id00810 - определение каталога swift через функцию get-path
        20/04/2012 id00810 - перекомпиляция в связи с изменением cr-swthead.i
        24/04/2012 evseev - изменения в .i
        25.06.2012 Lyubov - добавлено поле BenefAcc для 58А
        09/10/2012 id00810 - добавлена проверка значения поля BenefAcc (не пусто)
*/

{global.i}
def input param p-kodf  as char.
def input param p-yn    as log.
def shared var s-lc     like lc.lc.
def shared var s-event  like lcevent.event.
def shared var s-number like lcevent.number.

def var v-bank   as char no-undo.
def var s-value1 as char no-undo.
def var v-file0  as char no-undo.
def var v-namef  as char no-undo.
def var v-opt    as log  no-undo.
def var v-result as char no-undo.
def var k        as int  no-undo.
def var i        as int  no-undo.
def var j        as int  no-undo.
def var v-sym    as char no-undo.
def var v-swt    as char no-undo.
def stream out.
def buffer b-lceventh for lceventh.

def temp-table wrk no-undo
  field id        as integer
  field nom-f     as char
  field name-f    as char
  field datacode1 as char
  field datacode2 as char
  index idx is primary id.

{cr-swthead.i}

find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
v-bank = trim(sysc.chval).
v-swt = get-path('swtpath').

v-file0 = 'MT' + p-kodf.
empty temp-table wrk.

for each codfr where codfr.codfr   = v-file0 no-lock.
        create wrk.
        assign wrk.id        = int(codfr.name[2])
               wrk.nom-f     = codfr.code
               wrk.name-f    = codfr.name[1]
               wrk.datacode1 = codfr.name[3]
               wrk.datacode2 = codfr.name[4] no-error.
end.

output stream out to value(v-file0 + if p-yn then '' else  '.txt').

if p-yn then do:
    s-value1 = replace(s-lc,"/", "_") + string(s-number) + p-kodf + substr(s-event,1,1).
    find first lceventh where lceventh.bank = v-bank and lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number and lceventh.kritcode = 'InsTo' + p-kodf no-lock no-error.
    if not avail lceventh then
    find first lceventh where lceventh.bank = v-bank and lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number and lceventh.kritcode = 'InstTo' no-lock no-error.
    if avail lceventh and trim(lceventh.value1) <> '' then put stream out unformatted cr-swthead (p-kodf,trim(lceventh.value1)).
    put stream out unformatted '\{4:' skip.
    v-sym = ':'.
end.
else do:
    find first codific where codific.codfr = v-file0 no-lock no-error.
    if avail codific then v-namef = codific.name.
    put stream out unformatted 'MT' p-kodf ':' v-namef skip(2)
                                'To Institution '.
    find first lceventh where lceventh.bank = v-bank and lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number and lceventh.kritcode = 'InsTo' + p-kodf no-lock no-error.
    if not avail lceventh then
    find first lceventh where lceventh.bank = v-bank and lceventh.bank = v-bank and lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number and lceventh.kritcode = 'InstTo' no-lock no-error.

    if avail lceventh and trim(lceventh.value1) <> '' then do:
        find first swibic where swibic.bic = lceventh.value1 no-lock no-error.
        if avail swibic then put stream out unformatted swibic.bic skip swibic.name skip.
        else put stream out unformatted lceventh.value1 skip.
    end.
    put stream out unformatted 'Priority N' skip(2).
end.

for each wrk no-lock:
    if wrk.datacode1 eq '' then next.
    find first lceventh where lceventh.bank = v-bank and lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number and lceventh.kritcode = wrk.datacode1 no-lock no-error.
    if avail lceventh and lceventh.value1 <> '' then do:
        if lookup(lceventh.kritcode,'AccIns,BenIns,AccBnk,SCorr,RCorr,NBank,BenBnk') > 0 then do:
            find first b-lceventh where b-lceventh.bank = v-bank and b-lceventh.lc = s-lc and b-lceventh.event = s-event and b-lceventh.number = s-number and b-lceventh.kritcode = lceventh.kritcode + 'Op' no-lock no-error.
            if avail b-lceventh and b-lceventh.value1 ne '' then do:
                if b-lceventh.value1 = 'a' then v-opt = yes. else v-opt = no.
                put stream out unformatted v-sym substr(wrk.nom-f,1,length(wrk.nom-f) - 1) b-lceventh.value1  ':'.
            end.
            else put stream out unformatted v-sym wrk.nom-f ':' .
        end.
        else if lookup(lceventh.kritcode,'NetAmt,TAmtCl') > 0 then do:
            find first b-lceventh where b-lceventh.bank = v-bank and b-lceventh.lc = s-lc and b-lceventh.event = s-event and b-lceventh.number = s-number and b-lceventh.kritcode = lceventh.kritcode + 'Op' no-lock no-error.
            if avail b-lceventh and b-lceventh.value1 ne '' then do:
                if b-lceventh.value1 = 'a' then v-opt = yes. else v-opt = no.
                put stream out unformatted v-sym substr(wrk.nom-f,1,length(wrk.nom-f) - 1) b-lceventh.value1  ':'.
            end.
            else put stream out unformatted v-sym wrk.nom-f ':' .
        end.
        else if lookup(lceventh.kritcode,'lccrc,PrincCrc,AddCrc') > 0 and wrk.datacode2 ne '' then do:
            find first b-lceventh where b-lceventh.bank = v-bank and b-lceventh.lc = s-lc and b-lceventh.event = s-event  and b-lceventh.number = s-number and b-lceventh.kritcode = entry(1,wrk.datacode2) no-lock no-error.
            if avail b-lceventh and b-lceventh.value1 <> '' and b-lceventh.value1 <> '0' then put stream out unformatted v-sym wrk.nom-f ':' .
            else next.
        end.

        else put stream out unformatted v-sym wrk.nom-f ':' .
        if not p-yn then put stream out unformatted wrk.name-f skip.
        find first lckrit where lckrit.datacode = lceventh.kritcode no-lock no-error.
        if avail lckrit then do:
            if lckrit.datatype = 'd' then put stream out unformatted datestr(lceventh.value1).
            else if lckrit.datatype = 'r' then do:
                if lookup(lceventh.kritcode,'NetAmt,TAmtCl,Amount') > 0 then do:
                    if (v-opt = yes and lookup(lceventh.kritcode,'NetAmt,TAmtCl') > 0) or (lceventh.kritcode = 'Amount' and s-event = 'adva') then do:
                        if s-event = 'adva' then find first b-lceventh where b-lceventh.bank = v-bank and b-lceventh.lc = s-lc and b-lceventh.event = s-event and b-lceventh.number = s-number and b-lceventh.kritcode = 'Date' no-lock no-error.
                        else find first b-lceventh where b-lceventh.bank = v-bank and b-lceventh.lc = s-lc and b-lceventh.event = s-event and b-lceventh.number = s-number and b-lceventh.kritcode = 'VDate' no-lock no-error.
                        if avail b-lceventh then put stream out unformatted datestr(b-lceventh.value1).
                    end.
                    find first b-lceventh where b-lceventh.bank = v-bank and b-lceventh.lc = s-lc and b-lceventh.event = s-event and b-lceventh.number = s-number and b-lceventh.kritcode = 'lcCrc' no-lock no-error.
                    if not avail b-lceventh then find first b-lceventh where b-lceventh.bank = v-bank and b-lceventh.lc = s-lc and b-lceventh.event = s-event and b-lceventh.number = s-number and b-lceventh.kritcode = 'TAmtCrc' no-lock no-error.
                    if avail b-lceventh and b-lceventh.value1 ne '' then do:
                        find first crc where crc.crc = int(b-lceventh.value1) no-lock no-error.
                        if avail crc then put stream out unformatted crc.code.
                    end.
                end.
                put stream out unformatted numstr(lceventh.value1).
            end.
            else if trim(lckrit.dataSpr) <> '' then do:
                find first codfr
                where      codfr.codfr = trim(lckrit.dataSpr)
                and        codfr.code  = lceventh.value1
                no-lock no-error.
                if avail codfr then put stream out unformatted caps(codfr.name[1]).
                else put stream out unformatted lceventh.value1.
            end.
            else if lookup(lceventh.kritcode,'AccIns,BenIns,Scor756,RCor,SRInf' + p-kodf + ',ChargDed,ChargAdd,StoRInf,Discrep,AccBnk,SCorr,RCorr,ChargesD,NBank,Benef,DrfAt,AdAmCov,DefPayD,OthChr,Narrat,Charges,BenBnk') > 0 then do:
                if lceventh.kritcode = 'BenIns' then do:
                        find first b-lceventh where b-lceventh.bank = v-bank and b-lceventh.lc = s-lc and b-lceventh.event = s-event and b-lceventh.number = s-number and b-lceventh.kritcode = 'BenefAcc' no-lock no-error.
                        if avail b-lceventh and b-lceventh.value1 ne '' then put stream out unformatted '/' + b-lceventh.value1 skip.
                end.
                if not p-yn and ((lookup(lceventh.kritcode,'AccIns,BenIns,AccBnk,SCorr,RCorr,NBank,BenBnk') > 0 and v-opt)
                               or lookup(lceventh.kritcode,'Scor756,RCor')  > 0) then do:
                    find first swibic where swibic.bic = lceventh.value1 no-lock no-error.
                    if avail swibic then put stream out unformatted swibic.bic skip swibic.name skip.
                end.
                else do:
                    k = length(lceventh.value1).
                    i = 1.
                    repeat:
                        put stream out unformatted caps(trim(substr(lceventh.value1,i,35))) skip.
                        k = k - 35.
                        if k <= 0 then leave.
                        i = i + 35.
                    end.
               end.
            end.
            else if lceventh.kritcode = 'SCor202' then put stream out unformatted '/' lceventh.value1.
            else do i = 1 to num-entries(lceventh.value1,chr(1)):
               put stream out unformatted entry(i,lceventh.value1,chr(1)).
            end.
        end.
    end.
    if  wrk.datacode2 ne '' then do:
        do j = 1 to num-entries(wrk.datacode2):
            find first lceventh where lceventh.bank = v-bank and lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number and lceventh.kritcode = entry(j,wrk.datacode2) no-lock no-error.
            if avail lceventh and lceventh.value1 <> '' then do:
                find first lckrit where lckrit.datacode = lceventh.kritcode no-lock no-error.
                if avail lckrit then do:
                    if lckrit.datatype = 'd' then put stream out unformatted datestr(lceventh.value1).
                    else if lckrit.datatype = 'r' then put stream out unformatted numstr(lceventh.value1).
                    else if trim(lckrit.dataSpr) <> '' then do:
                        find first codfr
                        where      codfr.codfr = trim(lckrit.dataSpr)
                        and        codfr.code  = lceventh.value1
                        no-lock no-error.
                        if avail codfr then do:
                            if codfr.codfr = 'lcby' then put stream out unformatted skip 'BY ' + caps(codfr.name[1]).
                            else put stream out unformatted caps(codfr.name[1]).
                        end.
                        else put stream out unformatted lceventh.value1.
                    end.
                    else put stream out unformatted lceventh.value1.
                end.
            end.
        end.
    end.
    put stream out unformatted skip.
end.
if p-yn then put stream out unformatted "-}" skip.
output stream out close.

if p-yn then do:
    unix silent value("un-win1 " + v-file0 + " " + s-value1).

    unix silent cptwin value(s-value1) notepad.

    v-result = ''.
    input through value ("scp -q -i $HOME/.ssh/id_swift -o PasswordAuthentication=no " + s-value1 + " " + v-swt + ";echo $?").
    repeat:
        import unformatted v-result.
    end.
    if v-result <> "0" then do:
        message skip "Произошла ошибка при копировании файла " s-value1 " в SWIFT Alliance." skip(1) "Код ошибки " v-result view-as alert-box buttons ok title " ОШИБКА ! ".
        unix silent rm -f value (s-value1).
        unix silent rm -f value (v-file0).
        return error.
    end.

    v-result = ''.
    input through  value("cp " + s-value1 + " /data/export/mtpay;echo $?").
    repeat:
        import unformatted v-result.
    end.
    if v-result <> "0" then
    message "Произошла ошибка при копировании файла" s-value1 " в архив /data/export/mtpay." skip(1) "Код ошибки " v-result view-as alert-box buttons ok title " ОШИБКА ! ".

    unix silent rm -f value (s-value1).
    unix silent rm -f value (v-file0).
end.
else do:
    unix silent cptwin value(v-file0 + '.txt') winword.
    unix silent rm -f value(v-file0 + '.txt').
end.