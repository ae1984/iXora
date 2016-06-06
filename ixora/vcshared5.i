/* vcshared5.i
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
        09.10.2013 damir - Т.З. № 1670.
*/
def {1} shared var s-vcourbank as char.
def {1} shared var v-dt as date.
def {1} shared var v-dte as date.
def {1} shared var v-dtcorr as date.
def {1} shared var v-dtps as date.
def {1} shared var v-oper as char.
def {1} shared var v-option as char.
def {1} shared var s-empty as logi format "да/нет" init false.

def {1} shared temp-table t-ps no-undo
    field bank as char
    field repdate as date
    field psnum as char
    field psdate as date
    field psnum_19 as char
    field psdate_19 as date
    field psreason_19 as char
    field cifname as char
    field cifprefix as char
    field cif_rfkod1 as char
    field cif_jss as char
    field cif_type as inte
    field cif_region as char
    field partner_name as char
    field partner_country as char
    field ctexpimp as inte
    field ctnum as char
    field ctdate as date
    field ctregdt as date
    field ctvalpl as char
    field ctsum as deci
    field ctncrc_int as integer
    field ctncrc as char
    field ctogval as char
    field ctlastdate as date
    field ctterm as char
    field ctformrs as char
    field ctclosereas as char
    field ctclosedt as date
    field rslcdnnum_21 as char
    field rslcdndate_21 as date
    field bankokpo as char
    field note as char
    field bnkbin as char
    field bin as char
    field iin as char
    field corrinfo as char
    field newval1 as char
    field newval2 as char
    field valplnew as char
    field okpoprev as char
    field oper as char
index idx1 is primary psnum ascending.

def {1} shared temp-table t-dc no-undo
    field cont as inte
    field psnum as char
    field psdate as date
    field bnkbin as char
    field bin as char
    field iin as char
    field EISIGN as char
    field CONTRACT as char
    field CDATE as char
    field CSUMM as char
    field NRNAME as char
    field NRCOUNTRY as char
    field TERM_ as char
    field CCURR as char
    field CLASTDATE as char
    field CLOSEDATE as char
    field CLOSEFOUND as char
    field CURRENCY as char
    field CODECALC as char
    field note as char
    field dtcorrect as date
    field ctregdt as date
index idx1 contract ascending.

