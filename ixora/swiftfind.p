/* swiftfind.p
 * MODULE
        Название модуля
 * DESCRIPTION
        поиск SWIFT кода банка
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
        11/10/2010 gaina
 * BASES
        BANK
 * CHANGES
*/

{global.i}

def output parameter v-swift as char.
/*def var v-swift as char.*/
def var vselect as char.
def var vcode as char.
def var vname as char.
message "Chose the bank N)Name  S)SWIFT" update vselect format "x(1)".
if vselect = 'N' then do:

    message 'BANK NAME ' update vname format 'x(40)'.
    {itemlist.i

     &set = "bnk"
     &file = "swibic"
     &frame = "row 6 centered scroll 1 20 down width 91 overlay "
     &where = " swibic.name matches '*' + caps(vname) + '*' "
     &flddisp = " swibic.bic label 'SWIFT' format 'x(11)' swibic.name label 'Name' format 'x(60)' "
     &chkey = "bic"
     &index  = "bic"
     &end = "if keyfunction(lastkey) = 'end-error' then return."}
     v-swift = swibic.bic.

end.
if vselect = 'S' then do:

   message 'BANK NAME ' update vcode format 'x(11)'.

    {itemlist.i
     &set = "bnk1"
     &file = "swibic"
     &frame = "row 6 centered scroll 1 20 down width 91 overlay "
     &where = " swibic.bic matches '*' + caps(vcode) + '*' "
     &flddisp = " swibic.bic label 'SWIFT' format 'x(11)' swibic.name label 'Name' format 'x(60)' "
     &chkey = "bic"
     &index  = "bic"
     &end = "if keyfunction(lastkey) = 'end-error' then return."}
     v-swift = swibic.bic.
     /*message v-swift view-as alert-box.*/
end.


