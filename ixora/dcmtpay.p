/* dcmtpay.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        DC, ODC - Payment: формирование сообщений MT*
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
        13/02/2012 id00810
 * BASES
        BANK COMM
 * CHANGES
 */

{global.i}
def input param p-kodf  as char.
def input param p-yn    as log.
def shared var s-lc     like lc.lc.
def shared var s-lcpay  like lcpay.lcpay.
def var s-value1 as char no-undo.
def var v-file0  as char no-undo.
def var v-namef  as char no-undo.
def var v-opt    as log  no-undo.
def var v-result as char no-undo.
def var k        as int  no-undo.
def var i        as int  no-undo.
def var j        as int  no-undo.
def var v-sym    as char no-undo.
def var v-date   as char no-undo.
def var v-swt    as char no-undo.

def stream out.
def buffer b-lcpayh for lcpayh.

def temp-table wrk no-undo
  field id        as integer
  field nom-f     as char
  field name-f    as char
  field datacode1 as char
  field datacode2 as char
  index idx is primary id.

find first lc where lc.lc = s-lc no-lock no-error.
if not avail lc then return.

{cr-swthead.i}
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
    s-value1 = replace(s-lc,"/", "_") + p-kodf.
    find first lcpayh where lcpayh.bank = lc.bank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'RemBank' no-lock no-error.
    if avail lcpayh and trim(lcpayh.value1) <> '' then put stream out unformatted cr-swthead (p-kodf,trim(lcpayh.value1)).
    put stream out unformatted '\{4:' skip.
    v-sym = ':'.
end.
else do:
    find first codific where codific.codfr = v-file0 no-lock no-error.
    if avail codific then v-namef = codific.name.
    put stream out unformatted 'MT' p-kodf ':' v-namef skip(2)
                                'To Institution '.
    find first lcpayh where lcpayh.bank = lc.bank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'RemBank' no-lock no-error.
    if avail lcpayh and trim(lcpayh.value1) <> '' then do:
        find first swibic where swibic.bic = lcpayh.value1 no-lock no-error.
        if avail swibic then put stream out unformatted swibic.bic skip swibic.name skip.
        else put stream out unformatted lcpayh.value1 skip.
    end.
    put stream out unformatted 'Priority N' skip(2).
end.

find first b-lcpayh where b-lcpayh.lc = s-lc and b-lcpayh.kritcode = 'MatDt' no-lock no-error.
if avail b-lcpayh and b-lcpayh.value1 ne ? and b-lcpayh.value1 ne '' then v-date = datestr(b-lcpayh.value1).

for each wrk no-lock:
    if wrk.datacode1 eq '' then next.
    find first lcpayh where lcpayh.bank = lc.bank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = wrk.datacode1 no-lock no-error.
    if avail lcpayh and lcpayh.value1 <> '' then do:
        if can-do('OrdBnk,SCorr,RCorr,ActBnk,BenBnk',lcpayh.kritcode) then do:
            find first b-lcpayh where b-lcpayh.bank = lc.bank and b-lcpayh.lc = s-lc and b-lcpayh.lcpay = s-lcpay and b-lcpayh.kritcode = lcpayh.kritcode + 'Op' no-lock no-error.
            if avail b-lcpayh and b-lcpayh.value1 ne '' then do:
                if b-lcpayh.value1 = 'a' then v-opt = yes. else v-opt = no.
                put stream out unformatted v-sym substr(wrk.nom-f,1,length(wrk.nom-f) - 1) b-lcpayh.value1  ':'.
            end.
            else put stream out unformatted v-sym wrk.nom-f ':' .
        end.
        else if lcpayh.kritcode = 'CurCode' and v-date ne '' and wrk.nom-f = '32a' then put stream out unformatted v-sym substr(wrk.nom-f,1,length(wrk.nom-f) - 1) 'A:'.
        else put stream out unformatted v-sym wrk.nom-f ':' .
        if not p-yn then put stream out unformatted wrk.name-f skip.
        find first lckrit where lckrit.datacode = lcpayh.kritcode no-lock no-error.
        if avail lckrit then do:
            if lckrit.datatype = 'd' then put stream out unformatted datestr(lcpayh.value1).
            else if lckrit.datatype = 'r' then put stream out unformatted numstr(lcpayh.value1).
            else if trim(lckrit.dataSpr) <> '' then do:
                find first codfr
                where      codfr.codfr = trim(lckrit.dataSpr)
                and        codfr.code  = lcpayh.value1
                no-lock no-error.
                if avail codfr then do:
                    if lcpayh.kritcode = 'CurCode' and v-date ne '' and wrk.nom-f = '32a'then put stream out unformatted v-date .
                    put stream out unformatted caps(codfr.name[1]).
                end.
                else put stream out unformatted lcpayh.value1.
            end.
            else if lookup(lcpayh.kritcode,'OrdBnk,SCorr,RCorr,ActBnk,BenBnk,StoRInf,DetCharg,DetAmtAd') > 0 then do:
                if not p-yn and (lookup(lcpayh.kritcode,'OrdBnk,SCorr,RCorr,ActBnk,BenBnk') > 0 and v-opt) then do:
                    find first swibic where swibic.bic = lcpayh.value1 no-lock no-error.
                    if avail swibic then put stream out unformatted swibic.bic skip swibic.name skip.
                end.
                else do:
                    k = length(lcpayh.value1).
                    i = 1.
                    repeat:
                        put stream out unformatted caps(trim(substr(lcpayh.value1,i,35))) SKIP.
                        k = k - 35.
                        if k <= 0 then leave.
                        i = i + 35.
                    end.
               end.
            end.
            else do i = 1 to num-entries(lcpayh.value1,chr(1)):
               put stream out unformatted entry(i,lcpayh.value1,chr(1)) skip.
            end.
        end.
    end.

    if  wrk.datacode2 ne '' then do:
        do j = 1 to num-entries(wrk.datacode2):
            find first lcpayh where lcpayh.bank = lc.bank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = entry(j,wrk.datacode2) no-lock no-error.
            if avail lcpayh and lcpayh.value1 <> '' then do:
                find first lckrit where lckrit.datacode = lcpayh.kritcode no-lock no-error.
                if avail lckrit then do:
                    if lckrit.datatype = 'd' then put stream out unformatted datestr(lcpayh.value1).
                    else if lckrit.datatype = 'r' then put stream out unformatted numstr(lcpayh.value1).
                    else if trim(lckrit.dataSpr) <> '' then do:
                        find first codfr
                        where      codfr.codfr = trim(lckrit.dataSpr)
                        and        codfr.code  = lcpayh.value1
                        no-lock no-error.
                        if avail codfr then put stream out unformatted caps(codfr.name[1]).
                        else put stream out unformatted lcpayh.value1.
                    end.
                    else put stream out unformatted lcpayh.value1.
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
    input through  value("cp " + s-value1 + " /data/export/mt700;echo $?").
    repeat:
        import unformatted v-result.
    end.
    if v-result <> "0" then
    message "Произошла ошибка при копировании файла" s-value1 " в архив /data/export/mt700." skip(1) "Код ошибки " v-result view-as alert-box buttons ok title " ОШИБКА ! ".

    unix silent rm -f value (s-value1).
    unix silent rm -f value (v-file0).
end.
else do:
    unix silent cptwin value(v-file0 + '.txt') winword.
    unix silent rm -f value(v-file0 + '.txt').
end.