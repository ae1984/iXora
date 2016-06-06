/* i-mt760.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        Export Garantee - Advise - Импорт МТ760
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
        15/12/2010 id00810
 * BASES
        BANK  COMM
 * CHANGES

*/
{global.i}
{lgps.i new}
def var v-infile as char no-undo.
def var v-result as char no-undo.
def var sw-text  as char no-undo extent 170.
def var i        as int  no-undo.
def var j        as int  no-undo.
def var pr77c    as log  no-undo.
def var pr72     as log  no-undo.

def shared temp-table t-mt760 no-undo
    field fname  as char
    field fvalue as char extent 150.

find first LCswt where LCswt.lc = '' and LCswt.mt = 'O760' and LCswt.sts = 'new' no-lock no-error.
if not avail LCswt then return.

v-infile = LCswt.fname2.
input through  value("cp " + "/data/import/lcmt/" + string(year(LCswt.rdt),"9999") + string(month(LCswt.rdt),"99") + string(day(LCswt.rdt),"99") + "/" + v-infile + " " + v-infile + ";echo $?").
repeat:
    import unformatted v-result.
end.
if v-result <> "0" then do:
    message v-result + "Ошибка копирования файла " + v-infile view-as alert-box error.
    return.
end.

input from value(v-infile).

i = 0. j = 0.
repeat:
   i = i + 1.
   import unformatted sw-text[i].

    if sw-text[i] begins "-}"  then leave.
    if index(sw-text[i],"\{2:O760") > 0 then do:
        find first swibic where swibic.bic = substr(sw-text[i],index(sw-text[i],"\{2:O760") + 17,11) no-lock no-error.
        if not avail swibic
        then find first swibic where swibic.bic = substr(sw-text[i],index(sw-text[i],"\{2:O760") + 17,8) + 'XXX' no-lock no-error.
        if avail swibic then do:
            create t-mt760.
            assign t-mt760.fvalue[1] = swibic.bic
                   t-mt760.fname     = 'Sender'.
        end.
    end.
    if sw-text[i] begins ":27:" then do:
        create t-mt760.
        assign t-mt760.fvalue[1] = substr(sw-text[i],5)
               t-mt760.fname     = 'SeqTot'.
    end.
    if sw-text[i] begins ":20:" then do:
        create t-mt760.
        assign t-mt760.fvalue[1] = substr(sw-text[i],5,16)
               t-mt760.fname     = 'TRNum'.
    end.
    if sw-text[i] begins ":23:" then do:
        create t-mt760.
        assign t-mt760.fvalue[1] = substr(sw-text[i],5)
               t-mt760.fname     = 'FurId'.
    end.
    if sw-text[i] begins ":30:" then do:
        create t-mt760.
        assign t-mt760.fvalue[1] =  substr(sw-text[i],9,2) + '/' + substr(sw-text[i],7,2) + '/' + substr(sw-text[i],5,2)
               t-mt760.fname     = 'Date'.
    end.
    if sw-text[i] begins ":40c:" then do:
        create t-mt760.
        assign t-mt760.fvalue[1] = substr(sw-text[i],6)
               t-mt760.fname      = 'AppRule'.
    end.
    if sw-text[i] begins ":77c:" then do:
        j = j + 1.
        create t-mt760.
        assign t-mt760.fvalue[j] = substr(sw-text[i],6)
               t-mt760.fname     = 'DetGar'.
        pr77c = yes.
    end.
    if not sw-text[i] begins ":" and pr77c then do:
         j = j + 1.
         find t-mt760 where t-mt760.fname = 'DetGar' no-error.
         if avail t-mt760 then
         t-mt760.fvalue[j] = sw-text[i].
    end.
    if sw-text[i] begins ":72:" then do:
        j = 1. pr77c = no.
        create t-mt760.
        assign t-mt760.fvalue[j] = substr(sw-text[i],5)
               t-mt760.fname     = 'SRInf'.
        pr72 = yes.
    end.
    if not sw-text[i] begins ":" and pr72 then do:
        j = j + 1.
        find t-mt760 where t-mt760.fname = 'SRInf' no-error.
        if avail t-mt760 then
        t-mt760.fvalue[j] = sw-text[i].
    end.
end .

input close.
unix silent value("rm -r " +  v-infile).

create t-mt760.
    assign t-mt760.fvalue[1] = LCswt.fname2
           t-mt760.fname     = 'fname2'.

