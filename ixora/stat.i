/* stat.i
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
        25.09.2013 damir - Внедрено Т.З. № 1869.
*/
def {1} shared var ReportType as CHARACTER.

def {1} shared var id_form as CHARACTER.
def {1} shared var d_report as DATE.
def {1} shared var d_rep_file as CHARACTER.
def {1} shared var pr_period as CHARACTER.
def {1} shared var zo as CHARACTER FORMAT "x(1)".
def {1} shared var status_ as CHARACTER FORMAT "x(1)".

def {1} shared var oracleHost as CHARACTER.
def {1} shared var oracleDb as CHARACTER.
def {1} shared var oracleUser as CHARACTER.
def {1} shared var oraclePassword as CHARACTER.

def {1} shared temp-table t-stat NO-UNDO
    field i as INTEGER
    field id_pokaz as INTEGER
    field znac as DECIMAL
    field znac_null as LOGICAL format "true/false"
    field stroka as CHARACTER
    field line as CHARACTER
    field pr_spr as LOGICAL format "true/false"
    field tname_spr as CHARACTER
    field field_spr as CHARACTER
    field znac_spr as CHARACTER
INDEX idx1 is PRIMARY i ascending.


