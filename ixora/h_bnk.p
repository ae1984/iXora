/* h_bnk.p
 * MODULE
        Название модуля
 * DESCRIPTION
        поиск банка о наименованию в bankl
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
        24/11/2010 gaina
 * BASES
        BANK
 * CHANGES
*/

{global.i}

def output parameter v-bank as char.

def var vselect as char.

def var vname as char.
message "Chose the bank N)Name  A)All" update vselect format "x(1)".
if vselect = 'N' then do:

    message 'BANK NAME ' update vname format 'x(40)'.
    {itemlist.i

     &set = "bnk"
     &file = "bankl"
     &frame = "row 6 centered scroll 1 20 down width 91 overlay "
     &where = " bankl.name matches '*' + caps(vname) + '*' "
     &flddisp = " bankl.bank label 'Code' format 'x(11)' bankl.name label 'Name' format 'x(60)' "
     &chkey = "bank"
     &index  = "bank"
     &end = "if keyfunction(lastkey) = 'end-error' then return."}
     v-bank = bankl.bank.

end.
if vselect = 'A' then do:
    {itemlist.i
     &set = "bnk1"
     &file = "bankl"
     &frame = "row 6 centered scroll 1 20 down width 91 overlay "
     &where = " bankl.bank <> '' "
     &flddisp = " bankl.bank label 'Code' format 'x(11)' bankl.name label 'Name' format 'x(60)' "
     &chkey = "bank"
     &index  = "bank"
     &end = "if keyfunction(lastkey) = 'end-error' then return."}
     v-bank = bankl.bank.

end.


