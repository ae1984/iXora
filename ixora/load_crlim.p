/* load_crlim.p
 * MODULE
        Платежные карты
 * DESCRIPTION
        Загрузка остатков по кредитным лимитам из файлов Open Way
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
        17.07.2013 dmitriy. ТЗ 1640
 * BASES
        BANK COMM
 * CHANGES
        23.07.2013 dmitriy - удаление неиспользуемых переменных
        16.09.2013 dmitriy - Дополнение к ТЗ 1640 от 02.09.2013 - Добавление новых столбцов в загружаемый файл
*/

{global.i}

def temp-table wrk-str no-undo
field num as int
field str as char format "x(20)"
field dt as date
index idx is primary num.

def new shared temp-table wrk-dat no-undo
    field num as int
    field dt  as date
    field CONTRACT_NUMBER as char
    field CONTRACT_NAME as char
    field PRODUCT as char
    field DEPOSIT as char
    field CR_LIMIT as char
    field DATE_CR_LIM as char
    field CONTR_STATUS as char
    field AMOUNT_AVAILABLE as char
    field LOAN as char
    field PAYM_DUE as char
    field OVL as char
    field OVL_OVD as char
    field OVD_30 as char
    field OVD_MORE_30 as char
    field OVD_MORE_60 as char
    field OVD_MORE_90 as char
    field OVD_OUT as char
    field LOAN_INT as char
    field INT_RP as char
    field OVD_PENALTY_INT as char
    field INT_OVD_30 as char
    field INT_OVD_MORE_30 as char
    field INT_OVD_MORE_60 as char
    field INT_OVD_MORE_90 as char
    field INT_OVD_OUT as char

    field SUMM_ALL_WRITING as char
    field DATE_LAST_REPAYMENT as char
    field LAST_SUMM_REPAYMENT as char
    field SUMM_ALL_ACCRUAL_REWARD as char
    field SUMM_ALL_RECEIVE_REWARD as char

    index idx is primary num.

def temp-table wrk-fnames no-undo
    field path      as char  format 'x(50)'  label "Path"
    field fname     as char  format 'x(50)'  label "File"
    field fullname  as char  format 'x(50)'  label "Full name"
    field dt as date
    index fname is primary dt ascending.

def var v-tsnum     as int no-undo.
def stream r-in.
def var v-txt as char no-undo.
def var i as int.
def var k as int.
def var v-sel as char.
def var file1 as char.
def var v-fpath as char.
def var v-host as char.
def var fcount as int.
def var v-date as date.

function st-de returns decimal (input v-st as char).
if index(v-st, ",") > 0 and index(v-st, ".") > 0 then do:
    v-st = trim(v-st).
    v-st = replace(v-st, chr(160) , "").
    v-st = replace(v-st, " " , "").
    v-st = replace(v-st, "," , "").
end.
else do:
    v-st = trim(v-st).
    v-st = replace(v-st, chr(160) , "").
    v-st = replace(v-st, " " , "").
    v-st = replace(v-st, "," , ".").
end.
return decimal(v-st).
end.

repeat:
    run sel (" Загрузка данных по кредитным лимитам ", " 1. Загрузка файлов Results******.txt | 2. Остатки по кредитным лимитам | 3. Выход").
    v-sel = return-value.

    case v-sel:
        when '1' then  run LoadFile .
        when '2' then  run rep-crlim.
        when '3' then return.
        otherwise return.
    end case.
end.

procedure LoadFile:
    v-host = "Administrator@fs01.metrobank.kz".
    v-fpath = "D:\\\\euraz\\\\Cards\\\\In\\\\".

    /* Считывание файлов */
    def var v-str   as char no-undo.
    def var v-str1  as char no-undo.
    def var i as int.

    input through value("ssh " + v-host + " dir /b " + v-fpath).
    repeat:
        import unformatted v-str.
        v-str1 = v-str1 + "|" + v-str.
    end.

    fcount = 0.
    do i = 1 to num-entries(v-str1, "|"):
        if entry(i, v-str1, "|") begins "Results" and index(entry(i, v-str1, "|"), ".txt") > 0 and length(entry(i, v-str1, "|")) = 17 then do:
            fcount = fcount + 1.
            do transaction:
                create wrk-fnames.
                wrk-fnames.path = v-fpath.
                wrk-fnames.fname = entry(i, v-str1, "|").
                wrk-fnames.fullname = v-fpath + entry(i, v-str1, "|").
                wrk-fnames.dt = date(int(substr(wrk-fnames.fname,10,2)), int(substr(wrk-fnames.fname,8,2)), 2000 + int(substr(wrk-fnames.fname,12,2))).
            end.
        end.
    end.

    if fcount = 0 then do:
        message "Нет файлов для загрузки" view-as alert-box title " Внимание ".
        leave.
    end.

    for each wrk-fnames no-lock:
        displ wrk-fnames.fullname label "Загрузка файла".

        v-date = date(int(substr(wrk-fnames.fname,10,2)), int(substr(wrk-fnames.fname,8,2)), 2000 + int(substr(wrk-fnames.fname,12,2))).

        input through value("scp Administrator@fs01.metrobank.kz:D:/euraz/Cards/In/" + wrk-fnames.fname + " ./;echo $?").

        repeat:
            import unformatted v-str.
        end.

        if v-str <> "0" then do:
            message "Ошибка копирования файла " + wrk-fnames.fname + "!~n" + v-str + "~nДальнейшая работа невозможна!~Обратитесь в ДИТ!"
            view-as alert-box information buttons ok title " Внимание " .
            return.
        end.

        v-tsnum = 0.
        input from value(wrk-fnames.fname).
        repeat on error undo, leave:
            import unformatted v-str.
            if v-str ne "" then do:
                create wrk-str.
                assign wrk-str.num = v-tsnum
                wrk-str.str = v-str.
            end.
            v-tsnum = v-tsnum + 1.
        end.
        input close.

        for each wrk-str no-lock:
            create wrk-dat.
            wrk-dat.num = wrk-str.num.
            wrk-dat.dt = v-date.
            do i = 1 to  num-entries(wrk-str.str,chr(9)):
                case i:
                    when 1  then wrk-dat.CONTRACT_NUMBER             = entry(i,wrk-str.str,chr(9)).
                    when 2  then wrk-dat.CONTRACT_NAME               = entry(i,wrk-str.str,chr(9)).
                    when 3  then wrk-dat.PRODUCT                     = entry(i,wrk-str.str,chr(9)).
                    when 4  then wrk-dat.DEPOSIT                     = entry(i,wrk-str.str,chr(9)).
                    when 5  then wrk-dat.CR_LIMIT                    = entry(i,wrk-str.str,chr(9)).
                    when 6  then wrk-dat.DATE_CR_LIM                 = entry(i,wrk-str.str,chr(9)).
                    when 7  then wrk-dat.CONTR_STATUS                = entry(i,wrk-str.str,chr(9)).
                    when 8  then wrk-dat.AMOUNT_AVAILABLE            = entry(i,wrk-str.str,chr(9)).
                    when 9  then wrk-dat.LOAN                        = entry(i,wrk-str.str,chr(9)).
                    when 10 then wrk-dat.PAYM_DUE                    = entry(i,wrk-str.str,chr(9)).
                    when 11 then wrk-dat.OVL                         = entry(i,wrk-str.str,chr(9)).
                    when 12 then wrk-dat.OVL_OVD                     = entry(i,wrk-str.str,chr(9)).
                    when 13 then wrk-dat.OVD_30                      = entry(i,wrk-str.str,chr(9)).
                    when 14 then wrk-dat.OVD_MORE_30                 = entry(i,wrk-str.str,chr(9)).
                    when 15 then wrk-dat.OVD_MORE_60                 = entry(i,wrk-str.str,chr(9)).
                    when 16 then wrk-dat.OVD_MORE_90                 = entry(i,wrk-str.str,chr(9)).
                    when 17 then wrk-dat.OVD_OUT                     = entry(i,wrk-str.str,chr(9)).
                    when 18 then wrk-dat.LOAN_INT                    = entry(i,wrk-str.str,chr(9)).
                    when 19 then wrk-dat.INT_RP                      = entry(i,wrk-str.str,chr(9)).
                    when 20 then wrk-dat.OVD_PENALTY_INT             = entry(i,wrk-str.str,chr(9)).
                    when 21 then wrk-dat.INT_OVD_30                  = entry(i,wrk-str.str,chr(9)).
                    when 22 then wrk-dat.INT_OVD_MORE_30             = entry(i,wrk-str.str,chr(9)).
                    when 23 then wrk-dat.INT_OVD_MORE_60             = entry(i,wrk-str.str,chr(9)).
                    when 24 then wrk-dat.INT_OVD_MORE_90             = entry(i,wrk-str.str,chr(9)).
                    when 25 then wrk-dat.INT_OVD_OUT                 = entry(i,wrk-str.str,chr(9)).
                    when 26 then wrk-dat.SUMM_ALL_WRITING            = entry(i,wrk-str.str,chr(9)).
                    when 27 then wrk-dat.DATE_LAST_REPAYMENT         = entry(i,wrk-str.str,chr(9)).
                    when 28 then wrk-dat.LAST_SUMM_REPAYMENT         = entry(i,wrk-str.str,chr(9)).
                    when 29 then wrk-dat.SUMM_ALL_ACCRUAL_REWARD     = entry(i,wrk-str.str,chr(9)).
                    when 30 then wrk-dat.SUMM_ALL_RECEIVE_REWARD     = entry(i,wrk-str.str,chr(9)).
                end case.
            end.
        end.

        EMPTY TEMP-TABLE wrk-str.
    end.

    {r-branch.i &proc = "load_crlim2"}

    /* перемещение в архив */
    for each wrk-fnames no-lock:
        unix silent value("ssh " + v-host + " -q move " + v-fpath + wrk-fnames.fname + " " + v-fpath + "arc\\\\" + wrk-fnames.fname + " ;echo $?").
        unix silent value("rm -f " + wrk-fnames.fname).
    end.
    EMPTY TEMP-TABLE wrk-fnames.

end procedure.

