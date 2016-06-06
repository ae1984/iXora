/* lonlev.i
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
        04.02.2004 nataly   - добавлено начисление %% по индексированной сумме и просроченной индекс сумме на 22-ой, 23-ий уровни
        24.02.2004 marinav  - уровни ОД + индексация
*/

def var v-lonprnlev as char initial "1;7;8".
def var v-prnodlev as char initial "7".
def var v-prnbllev as char initial "8".
def var v-prnfslev as char initial "1".

def var v-prnindlev as char initial "20". /*индексирвоанная сумма */
def var v-prnindlev2 as char initial "21".  /*просроченная индексированная сумма */ 
def var v-prnindlevp as char initial "22". /*индексирвоанные %% */
def var v-prnindlev2p as char initial "23".  /*просроченные индексированные %% */ 

def var v-lonprnlevi as char initial "1;7;8;20;21".
