/* lcmtamd.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        Формирование сообщений MT* по таблице lcamendh
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
        12/05/2011 id00810
 * BASES
        BANK COMM
 * CHANGES
    28/06/2011 id00810 - ошибка: не было двоеточия перед номером поля в МТ
    04/08/2011 id00810 - {cr-swthead.i} формирование заголовка сообщения
    13/09/2011 id00810 - обработка ошибки копирования в SWIFT
    10/02/2012 id00810 - определение каталога swift через функцию get-path
    20/04/2012 id00810 - перекомпиляция в связи с изменением cr-swthead.i
    24/04/2012 evseev - изменения в .i
 */

{global.i}
def input param p-kodf  as char.
def input param p-yn    as log.
def shared var s-lc      like lc.lc.
def shared var s-lcamend like lcamend.lcamend.
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
def buffer b-lcamendh for lcamendh.

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
    find first lcamendh where lcamendh.bank = v-bank and lcamendh.lc = s-lc and lcamendh.lcamend = s-lcamend and lcamendh.kritcode = 'NumAmend' no-lock no-error.
    if avail lcamendh and trim(lcamendh.value1) <> '' then s-value1 = replace(s-lc,"/", "_") + string(lcamendh.value1,'99').

    find first lcamendh where lcamendh.bank = v-bank and lcamendh.lc = s-lc and lcamendh.lcamend = s-lcamend and lcamendh.kritcode = 'InstTo' no-lock no-error.
    if avail lcamendh and trim(lcamendh.value1) <> '' then put stream out unformatted cr-swthead (p-kodf,trim(lcamendh.value1)).
    put stream out unformatted '\{4:' skip.
    v-sym = ':'.
end.
else do:
    find first codific where codific.codfr = v-file0 no-lock no-error.
    if avail codific then v-namef = codific.name.
    put stream out unformatted 'MT' p-kodf ':' v-namef skip(2)
                                'To Institution '.
    find first lcamendh where lcamendh.bank = v-bank and lcamendh.lc = s-lc and lcamendh.lcamend = s-lcamend and lcamendh.kritcode = 'InstTo' no-lock no-error.
    if avail lcamendh and trim(lcamendh.value1) <> '' then do:
        find first swibic where swibic.bic = lcamendh.value1 no-lock no-error.
        if avail swibic then put stream out unformatted swibic.bic skip swibic.name skip.
        else put stream out unformatted lcamendh.value1 skip.
    end.

    put stream out unformatted 'Priority N' skip(2).
end.

for each wrk no-lock:
    if wrk.datacode1 eq '' then next.
    find first lcamendh where lcamendh.bank = v-bank and lcamendh.lc = s-lc and lcamendh.lcamend = s-lcamend and lcamendh.kritcode = wrk.datacode1 no-lock no-error.
    if avail lcamendh and lcamendh.value1 <> '' then do:
        if lcamendh.kritcode = 'AccIns' or lcamendh.kritcode = 'BenIns' then do:
            find first b-lcamendh where b-lcamendh.bank = v-bank and b-lcamendh.lc = s-lc and lcamendh.lcamend = s-lcamend and b-lcamendh.kritcode = lcamendh.kritcode + 'Op' no-lock no-error.
            if avail b-lcamendh and b-lcamendh.value1 ne '' then do:
                if b-lcamendh.value1 = 'a' then v-opt = yes. else v-opt = no.
                put stream out unformatted v-sym substr(wrk.nom-f,1,length(wrk.nom-f) - 1) b-lcamendh.value1  ':'.
            end.
            else put stream out unformatted v-sym wrk.nom-f ':' .
        end.
        else if lcamendh.kritcode = 'crcA' and wrk.datacode2 ne '' then do:
            find first b-lcamendh where b-lcamendh.bank = v-bank and b-lcamendh.lc = s-lc and b-lcamendh.lcamend = s-lcamend and b-lcamendh.kritcode = entry(1,wrk.datacode2) no-lock no-error.
            if avail b-lcamendh and b-lcamendh.value1 <> '' then put stream out unformatted v-sym wrk.nom-f ':' .
            else next.
        end.
        else put stream out unformatted v-sym wrk.nom-f ':' .
        if not p-yn then put stream out unformatted wrk.name-f skip.
        find first lckrit where lckrit.datacode = lcamendh.kritcode no-lock no-error.
        if avail lckrit then do:
            if lckrit.datatype = 'd' then put stream out unformatted datestr(lcamendh.value1).
            else if lckrit.datatype = 'r' then put stream out unformatted numstr(lcamendh.value1).
            else if trim(lckrit.dataSpr) <> '' then do:
                find first codfr
                where      codfr.codfr = trim(lckrit.dataSpr)
                and        codfr.code  = lcamendh.value1
                no-lock no-error.
                if avail codfr then put stream out unformatted caps(codfr.name[1]).
                else put stream out unformatted lcamendh.value1.
            end.
            else if lookup(lcamendh.kritcode,'AccIns,BenIns,Scor756,RCor,SRInf' + p-kodf + ',Applic,Benef,DrfAt,DetPayD,Charges,PerPres,StoRInf,BenAmd') > 0 then do:
                if not p-yn and ((lookup(lcamendh.kritcode,'AccIns,BenIns') > 0 and v-opt)
                               or lookup(lcamendh.kritcode,'Scor756,RCor')  > 0) then do:
                    find first swibic where swibic.bic = lcamendh.value1 no-lock no-error.
                    if avail swibic then put stream out unformatted swibic.bic skip swibic.name skip.
                end.
                else do:
                    k = length(lcamendh.value1).
                    i = 1.
                    repeat:
                        put stream out unformatted caps(trim(substr(lcamendh.value1,i,35))) SKIP.
                        k = k - 35.
                        if k <= 0 then leave.
                        i = i + 35.
                    end.
               end.
            end.
            else if lookup(lcamendh.kritcode,'DesGood,DocReq,AddCond,InstoBnk,DetGar,ShipPer,AmendDet') > 0 then do:
                k = length(lcamendh.value1).
                i = 1.
                repeat:
                    put stream out unformatted caps(trim(substr(lcamendh.value1,i,65))) SKIP.
                    k = k - 65.
                    if k <= 0 then leave.
                    i = i + 65.
                end.
            end.
            else if lookup(lcamendh.kritcode,'Narrat') > 0 then do:
                k = length(lcamendh.value1).
                i = 1.
                repeat:
                    put stream out unformatted caps(trim(substr(lcamendh.value1,i,50))) skip.
                    k = k - 50.
                    if k <= 0 then leave.
                    i = i + 50.
                end.
            end.
            else if lcamendh.kritcode = 'SCor202' then put stream out unformatted '/' lcamendh.value1.
            else do i = 1 to num-entries(lcamendh.value1,chr(1)):
               put stream out unformatted entry(i,lcamendh.value1,chr(1)).
            end.
        end.
    end.

    if  wrk.datacode2 ne '' then do:
        do j = 1 to num-entries(wrk.datacode2):
            find first lcamendh where lcamendh.bank = v-bank and lcamendh.lc = s-lc and lcamendh.lcamend = s-lcamend and lcamendh.kritcode = entry(j,wrk.datacode2) no-lock no-error.
            if avail lcamendh and lcamendh.value1 <> '' then do:
                find first lckrit where lckrit.datacode = lcamendh.kritcode no-lock no-error.
                if avail lckrit then do:
                    if lckrit.datatype = 'd' then put stream out unformatted datestr(lcamendh.value1).
                    else if lckrit.datatype = 'r' then put stream out unformatted numstr(lcamendh.value1).
                    else if trim(lckrit.dataSpr) <> '' then do:
                        find first codfr
                        where      codfr.codfr = trim(lckrit.dataSpr)
                        and        codfr.code  = lcamendh.value1
                        no-lock no-error.
                        if avail codfr then do:
                            if codfr.codfr = 'lcby' then put stream out unformatted skip 'BY ' + caps(codfr.name[1]).
                            else put stream out unformatted caps(codfr.name[1]).
                        end.
                        else put stream out unformatted lcamendh.value1.
                    end.
                    else put stream out unformatted lcamendh.value1.
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