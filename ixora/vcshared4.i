/* vcshared4.i
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
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
        --/--/2013 damir
 * BASES
        BANK COMM
 * CHANGES
        13.08.2013 damir - Внедрено Т.З. № 1559,1308.
*/
def {1} shared var v-god as inte format "9999".
def {1} shared var v-month as inte format "99".
def {1} shared var v-dtb as date.
def {1} shared var v-dte as date.
def {1} shared var v-dtdoc as date format "99/99/9999".
def {1} shared var v-dtcor as date format "99/99/9999".
def {1} shared var s-empty as logi format "да/нет" init false.
def {1} shared var v-oper as char.
def {1} shared var v-option as char.

def {1} shared temp-table t-docs no-undo
    field rdt as date
    field psdate as date
    field psnum as char
    field name as char
    field okpo as char format "999999999999"
    field rnn as char format "999999999999"
    field clntype as char
    field country as char
    field region as char
    field locat as char
    field partner as char
    field rnnben as char format "999999999999"
    field okpoben as char format "999999999999"
    field typeben as char
    field countryben as char
    field regionben as char
    field locatben as char
    field dnnum as char
    field dndate as date
    field docs as inte
    field sum as deci
    field strsum as char
    field codval as char
    field ctformrs as char
    field inout as char
    field note as char
    field bin as char
    field iin as char
    field binben as char
    field iinben as char
    field bnkbin as char
    field numdc as char
    field datedc as date
    field numnewps as char
    field datenewps as date
    field numobyaz as char
    field corr as char
    field pcrc as inte
index main is primary dndate sum docs.

def {1} shared temp-table t-dc no-undo
    field contract as inte
    field docs as inte
    field bnkbin as char
    field psnum as char
    field psdate as date
    field numobyaz as char
    field dndate as date
    field pcrc as inte
    field sum as deci
    field NAME as char
    field COUNTRY as char
    field BNAME as char
    field BCOUNTRY as char
    field PAYDATE as char
    field SUMM as char
    field CURR as char
    field CODECALC as char
    field INOUT as char
    field NOTE as char
    field corr as char
    field dtcorrect as date
    field rdt as date.