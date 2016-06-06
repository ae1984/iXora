/* lcrep2i
 * MODULE
        Trade Finance
 * DESCRIPTION
        Reports - Remaining Amount
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        lcrep2.p lcrep2f.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT

 * MENU
        14-7-3-2
 * BASES
        BANK
 * AUTHOR
        29/11/11 id00810
 * CHANGES
*/
def {1} var v-dt          as date .
def {1} var v-valuta      as int .
def {1} var v-valuta_code as char .
def {1} var v-glacc       as int format ">>>>>>".
def {1} var v-cif         as char init '*'.
def {1} var v-splcprod    as char.
def {1} var v-cover       as char.
def {1} var v-code        as char.
def {1} var v-lev         as int.
def {1} var v-com         as logi.
def {1} var v-ap          as logi.