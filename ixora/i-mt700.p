/* i-mt700.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        Export Letter of Credit - Advise - Импорт МТ700/710
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
        08/02/2011 id00810
 * BASES
        BANK  COMM
 * CHANGES
        10/05/2011 id00810 - MT707, MT767 (advise of amendment EXLC, EXPG)
        11/01/2012 id00810 - обработка полей, имеющих разные опции, с пом.настройки lcmtf
*/
{global.i}
{lgps.i new}
def input param in-lcswt as recid.
def       var   v-infile as char no-undo.
def       var   v-mt     as char no-undo.
def       var   v-result as char no-undo.
def       var   sw-text  as char no-undo extent 500.
def       var   i        as int  no-undo.
def       var   j        as int  no-undo.
def       var   v-name   as char no-undo.
def       var   v-kod    as char no-undo.
def       var   v-spf    as char no-undo.
def shared temp-table t-mt700 no-undo
    field fname  as char
    field fvalue as char extent 100.

find first LCswt where recid(LCswt) = in-lcswt no-lock no-error.
if not avail LCswt then return.

assign v-infile = LCswt.fname2
       v-mt     = LCswt.mt.
input through  value("cp " + "/data/import/lcmt/" + string(year(LCswt.rdt),"9999") + string(month(LCswt.rdt),"99") + string(day(LCswt.rdt),"99") + "/" + v-infile + " " + v-infile + ";echo $?").
repeat:
    import unformatted v-result.
end.
if v-result <> "0" then do:
    message v-result + "Ошибка копирования файла " + v-infile view-as alert-box error.
    return error.
end.

find first pksysc where pksysc.sysc = 'lcmtf' no-lock no-error.
if avail pksysc then v-spf = pksysc.chval.

input from value(v-infile).

i = 0. j = 0.
repeat:
   i = i + 1.
   import unformatted sw-text[i].

    if sw-text[i] begins "-}"  then leave.
    if index(sw-text[i],"\{2:O7") > 0 then do:
        find first swibic where swibic.bic = substr(sw-text[i],index(sw-text[i],"\{2:O7") + 17,11) no-lock no-error.
        if not avail swibic
        then find first swibic where swibic.bic = substr(sw-text[i],index(sw-text[i],"\{2:O7") + 17,8) + 'XXX' no-lock no-error.
        if avail swibic then do:
            create t-mt700.
            assign t-mt700.fvalue[1] = swibic.bic
                   t-mt700.fname     = 'Sender'.
        end.
        next.
    end.

    if sw-text[i] begins ":" then do:
        v-kod = entry(2,sw-text[i],':').
        if v-mt = 'O710' and v-kod = '20' then next.
        if lookup(v-kod,v-spf) > 0 then v-kod = substr(v-kod,1,length(v-kod) - 1) + 'A'.

        find first codfr
        where      codfr.codfr = 'MT' + substr(v-mt,2)
        and        codfr.code  = v-kod
        no-lock no-error.
        if not avail codfr then do:
            message "There is no such field " + v-kod + " in codificator " + 'MT' + substr(v-mt,2) + "!" view-as alert-box error.
            return error.
        end.
        find first lckrit where lckrit.datacode =  codfr.name[3] no-lock no-error.
        if not avail lckrit then next.

        if v-kod = "31D" then do:
            create t-mt700.
            assign t-mt700.fvalue[1] =  substr(sw-text[i],10,2) + '/' + substr(sw-text[i],8,2) + '/' + substr(sw-text[i],6,2)
                   t-mt700.fname     = codfr.name[3].

            create t-mt700.
            assign t-mt700.fvalue[1] =  substr(sw-text[i],12)
                   t-mt700.fname     = codfr.name[4].
            next.
        end.
        if v-kod = "32B" or v-kod = "33B" or v-kod = "34B" then do:
            find first t-mt700 where t-mt700.fname = codfr.name[3] no-lock no-error.
            if not avail t-mt700 then do:
                create t-mt700.
                assign t-mt700.fvalue[1] =  substr(sw-text[i],6,3)
                       t-mt700.fname     = codfr.name[3].
                find first crc where crc.code = t-mt700.fvalue[1] no-lock no-error.
                if avail crc then t-mt700.fvalue[1] = string(crc.crc).
            end.
            create t-mt700.
            assign t-mt700.fvalue[1] =  replace(substr(sw-text[i],9),',','.')
                   t-mt700.fname     = codfr.name[4].
            next.
        end.
        assign v-name = codfr.name[3]
               j      = 1.
        create t-mt700.
        assign t-mt700.fvalue[1] = if lckrit.datatype = 'd' then substr(sw-text[i],length(v-kod) + 7,2) + '/' + substr(sw-text[i],length(v-kod) + 5,2) + '/' + substr(sw-text[i],length(v-kod) + 3,2)
                                                            else entry(3,sw-text[i],':')
               t-mt700.fname     =  v-name.
    end.
    else do:
         if v-name = 'AvlWith' and sw-text[i] begins 'by' then do:
            create t-mt700.
            assign t-mt700.fvalue[1] = sw-text[i]
                   t-mt700.fname      = 'By'.
         end.
         else do:
            j = j + 1.
            find last t-mt700 where t-mt700.fname = v-name no-error.
            if avail t-mt700 then t-mt700.fvalue[j] = sw-text[i].
         end.
    end.
end.

input close.
unix silent value("rm -r " +  v-infile).

create t-mt700.
    assign t-mt700.fvalue[1] = substr(v-mt,2)
           t-mt700.fname     = 'fmt'.
create t-mt700.
    assign t-mt700.fvalue[1] = LCswt.fname2
           t-mt700.fname     = 'fname2'.