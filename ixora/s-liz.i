/* s-liz.i
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        31/12/99 pragma
 * CHANGES
*/

/*
* s-liz.i
* Variable for Leasing
*/
/* variables for facif file */
def {1} shared var cgFacifFacif    as char format "x(6)".
def {1} shared var cgFacifFacifApd as char format "x(6)".
def {1} shared var lUserPressOk   as logi.

def var cFacifFacif      as char format "x(6)".
def var cFacifName       as char format "x(50)".
def var cFacifAddr       as char format "x(50)".
def var cFacifTel1       as char format "(xxx)xxx-xxx".
def var cFacifTel2       as char format "(xxx)xxx-xxx".
def var cFacifFax        as char format "(xxx)xxx-xxx".
def var cFacifBanka      as char.
def var cFacifKonts      as char.
def var cFacifFanrur     as char.
def var cFacifPvnMaks    as char.
def var cFacifVaditais   as char.
def var cFacifVadUzvards as char.
def var cFacifGrUzvards  as char.
def var cFacifFacifApd   as char format "x(6)".
def var cFacifNameApd    as char format "x(50)".
def var cFacifAddrApd    as char format "x(50)".

define var cFalonTypeList as character format "x(15)" extent 10.
define var cFalonTypeCode as character format "x(3)"  extent 10.

/*cFalonTypeList[1]  = "P…RDEVЁJI".
cFalonTypeCode[1]  = "PRD".

cFalonTypeList[2]  = "APDRO№IN…№ANAI".
cFalonTypeCode[2]  = "APD".

cFalonTypeList[3]  = "C§TI".
cFalonTypeCode[3]  = "".*/

cFalonTypeList[1]  = "ВСЕ".
cFalonTypeCode[1]  = "".
