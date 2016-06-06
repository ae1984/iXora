/* LCmt767.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        MT767
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
        28/02/2011 id00810
 * BASES
        BANK COMM
 * CHANGES
        24/04/2012 evseev  - rebranding.БИК из sysc cleocod
        25/04/2012 evseev  - повтор
*/

{global.i}
def shared var s-lc      like LC.LC.
def shared var s-lcamend like lcamend.lcamend.
def var s-value1 as char.
def var v-file0  as char init 'MT767'.
def var v-result as char no-undo.

def stream out.
def var k as integer.
def vaR I AS INTEGER.

def temp-table wrk no-undo
  field id as integer
  field nom-f  as char
  field name-f as char
  field datacode1   as char
  field datacode2   as char
  index idx is primary id.

{sysc.i}
def var v-clecod as char no-undo.
v-clecod = get-sysc-cha("clecod").

function datestr returns char (input p-dtin as char).
    def var v-dt as char.
    v-dt = substr(string(year(date(p-dtin))),3,2) + string(month(date(p-dtin)),'99') + string(day(date(p-dtin)),'99').
    return v-dt.
end function.

    for each codfr where codfr.codfr   = 'MT767' no-lock.
            create wrk.
            assign wrk.id        = int(codfr.name[2])
                   wrk.nom-f     = codfr.code
                   wrk.name-f    = codfr.name[1]
                   wrk.datacode1 = codfr.name[3]
                   wrk.datacode2 = codfr.name[4] no-error.
    end.

    find first lcamendh where lcamendh.lc = s-lc and lcamendh.lcamend = s-lcamend and lcamendh.kritcode = 'NumAmend' no-lock no-error.
    if avail lcamendh and trim(lcamendh.value1) <> '' then s-value1 = replace(s-lc,"/", "_") + string(lcamendh.value1,'99').

    output stream out to value(v-file0).

    find first lcamendh where lcamendh.lc = s-lc and lcamendh.lcamend = s-lcamend and lcamendh.kritcode = 'InstTo' no-lock no-error.
    if avail lcamendh and trim(lcamendh.value1) <> '' then put stream out unformatted "\{1:F01" + v-clecod + "AXXXXXXXXXXXXX}\{2:I767" + lcamendh.value1 + "XN}\{4:" skip.

    for each wrk no-lock:
                if wrk.datacode1 eq '' then next.
                find first lcamendh where lcamendh.lc = s-lc and lcamendh.kritcode = wrk.datacode1 no-lock no-error.
                if avail lcamendh and lcamendh.value1 <> '' then do:
                    put stream out unformatted wrk.nom-f ':' .
                    find first lckrit where lckrit.datacode = lcamendh.kritcode no-lock no-error.
                    if avail lckrit then do:
                        if lckrit.datatype = 'd' then do:
                            put stream out unformatted datestr(lcamendh.value1) skip.
                            next.
                        end.
                        if trim(lckrit.dataSpr) <> '' then do:
                            find first codfr
                            where      codfr.codfr = trim(lckrit.dataSpr)
                            and        codfr.code  = lcamendh.value1
                            no-lock no-error.
                            if avail codfr then put stream out unformatted caps(codfr.name[1]) skip.
                            else put stream out unformatted lcamendh.value1 skip.
                            next.
                        end.
                        if lcamendh.kritcode = 'AmendDet' then do:
                            k = length(lcamendh.value1).
                            i = 1.
                            repeat:
                                put stream out unformatted caps(substr(lcamendh.value1,i,65)) SKIP.
                                k = k - 65.
                                if k <= 0 then leave.
                                i = i + 65.
                            end.
                            next.
                        end.
                        do i = 1 to num-entries(lcamendh.value1,chr(1)):
                           put stream out unformatted entry(i,lcamendh.value1,chr(1)) skip.
                        end.
                    end.
                end.

                if  wrk.datacode2 ne '' then do:
                    find first lcamendh where lcamendh.lc = s-lc and lcamendh.kritcode = wrk.datacode2 no-lock no-error.
                    if avail lcamendh and lcamendh.value1 <> '' then do:
                        put stream out unformatted lcamendh.value1.
                    end.
                end.
                put stream out unformatted skip.

    end.
    put stream out unformatted "-}" skip.
    output stream out close.

    unix silent value("un-win1 " + v-file0 + " " + s-value1).

    unix silent cptwin value(s-value1) notepad.

    v-result = ''.
    input through value ("scp -i $HOME/.ssh/id_swift -o PasswordAuthentication=no " + s-value1 + " Administrator@192.168.222.226:C:/swift/in/;echo $?").
    repeat:
        import unformatted v-result.
    end.
    if v-result <> "0" then do:
        message skip " Произошла ошибка при копировании файла" s-value1 skip(1) v-result view-as alert-box buttons ok title " ОШИБКА ! ".
    end.

    v-result = ''.
    input through  value("cp " + s-value1 + " /data/export/mt707;echo $?").
    repeat:
        import unformatted v-result.
    end.
    if v-result <> "0" then  message v-result + " Ошибка копирования в архив" view-as alert-box.


    unix silent rm -f value (s-value1).
    unix silent rm -f value (v-file0).



