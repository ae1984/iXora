/* eknpjss_var.i
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл - eknp_f3.p,eknpjss.p.
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        --/--/2012 damir
 * BASES
        BANK
 * CHANGES
        21.12.2012 damir - Внедрено Т.З. № 1620.
*/

def {1} shared var vn-dt as date.
def {1} shared var vn-dtbeg as date.
def {1} shared var v-jss as char.

def {1} shared temp-table t-rash_1
    field txb as char
    field bnkname as char
    field cifname as char
    field gl_4 as inte
    field gl as inte
    field acc as char
    field crc as inte
    field crccode as char
    field bal_beg as deci
    field dam as deci
    field cam as deci
    field bal_end as deci.

def {1} shared temp-table t-rash_2
    field txb as char
    field bnkname as char
    field cifname as char
    field dtdoc as date
    field rmz as char
    field rem as char
    field drgl_4 as inte
    field drgl as inte
    field dacc as char
    field dcrc as inte
    field dcrccode as char
    field crgl_4 as inte
    field crgl as inte
    field cacc as char
    field ccrc as inte
    field ccrccode as char
    field damcrc as deci
    field damkzt as deci
    field camcrc as deci
    field camkzt as deci
    field KOd as char
    field KBe as char
    field KNP as char
    field benbank as char
    field swiftben as char
    field ordbank as char
    field swiftord as char.







