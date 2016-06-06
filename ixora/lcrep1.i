/* lcrep1.i
 * MODULE
        Trade Finance
 * DESCRIPTION
        Reports - Turnover
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        lcrep1.p lcrep1f.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT

 * MENU
        14-7-3-1
 * BASES
        BANK
 * AUTHOR
        21/11/11 id00810
 * CHANGES
*/
def {1} var v-from        as date .
def {1} var v-to          as date .
def {1} var v-valuta      as int .
def {1} var v-valuta_code as char .
def {1} var v-glacc       as int format ">>>>>>".
def {1} var v-cif         as char init '*'.
def {1} var v-splcprod    as char.
def {1} var v-cover       as char.
def {1} var v-code        as char.
def {1} var v-lev         as int.
def {1} var v-com         as logi.
