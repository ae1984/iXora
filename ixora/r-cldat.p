/* r-cldat.p
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

/*r-cldat.p*/
/*
   30.10.2002 nadejda - наименование клиента заменено на форма собств + наименование 
*/


{global.i}


def var file1 as char format "x(20)".
def var file2 as char format "x(20)".
def var v-dat as date label "ДАТА    ".
def var comprt as cha initial "prit  " format "x(10)" .
def var v-new as log  format "создать/продолжить"  initial "Создать".
DEF STREAM m-out1.
DEF STREAM m-out2.

DEF var dd AS int .
DEF var mm AS int .
DEF var yy AS int.

v-dat = g-today .
if not g-batch then do :
    update v-dat skip
    comprt label  "Команда " skip
    v-new label "Создать(с)/продолжить(п)"
    with side-label row 5 centered frame dat .
end.
else v-dat = g-today.

dd = day(v-dat) .
mm = month(v-dat) .
yy = year(v-dat) .
file1 = "cf" + string(dd,"99") + string(mm,"99") + string(yy,"9999") .
file2 = "cj" + string(dd,"99") + string(mm,"99") + string(yy,"9999") .

find first sysc where sysc.sysc = "OURBNK" no-lock no-error.
if not available sysc then do :
   message "Введите OURBNK в sysc". 
   pause.
   return.
end. 
display "......Ж Д И Т Е ......."  with row 12 frame ww centered .
if v-new then do :
    output stream m-out1 to value(file1).
    output stream m-out2 to value(file2).
    find first bankl where bankl.bank = trim(sysc.chval) no-lock no-error.
    find first codfr where codfr.codfr = "rnnsp" and codfr.code eq "1" 
    no-lock no-error.
put stream m-out1 
trim(bankl.addr[1]) format "x(30)" space(20)
caps(bankl.name) format "x(30)" skip
trim(bankl.addr[2]) format "x(20)" trim(bankl.addr[3]) format "x(20)" skip
"Tel:      " trim(bankl.tel) skip
"Fax:      " trim(bankl.fax) space(30) "НАЛОГОВЫЙ КОМИТЕТ " skip
"Telex:    " trim(bankl.tlx) space(30) "        ПО" skip
"S.W.I.F.T:" trim(bankl.bic) space(30)  codfr.name[1] format "x(22)" skip        "                                             ----------------------"
skip
"                                                            РАЙОНУ" skip(2)
/***
bankl.name format "x(30)" skip(1)
trim(bankl.addr[2]) format "x(15)" "," trim(bankl.addr[1]) format "x(20)" ","
trim(bankl.addr[3]) format "x(20)" ",phone:" trim(bankl.tel) 
",fax:" trim(bankl.fax) ",telex:" trim(bankl.tlx) ",S.W.I.F.T:" trim(bankl.bic) skip
"______________________________________________________________________________"skip(1)
"     KC 9.04                                           НАЛОГОВЫЙ КОМИТЕТ" skip
"                                                               ПО" skip
"                                                      " codfr.name[1] format "x(22)" skip
"                                                     ----------------------"
skip
"                                                            РАЙОНУ" skip(1)
***/
"N счета" AT 1 "Наименование клиента" AT 20 "РНН" AT 67
SKIP 
"-------------------------------------------------------------------------"
"----"
 SKIP(1) .
for each aaa where aaa.sta eq "C" and aaa.cltdt = v-dat:
    find first sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = aaa.cif
    and sub-cod.d-cod = 'clnsts' no-lock no-error.
    if not avail sub-cod then next.
    find cif where cif.cif = aaa.cif no-lock no-error.
    if not avail cif then next.
    if sub-cod.ccode = "1" then do :
        put stream m-out1 aaa.aaa format "x(10)" " " trim(trim(cif.prefix) + " " + trim(cif.name)) format "x(50)"             "  "  cif.jss format "x(20)" skip.
    end.    
    else do :
        find first codfr where codfr.codfr = "rnnsp" and codfr.code =                    substr(cif.jss,4,1) no-lock no-error.
        if not avail codfr then find last codfr.
            put stream m-out2
trim(bankl.addr[1]) format "x(30)" space(20)
caps(bankl.name) format "x(30)" skip
trim(bankl.addr[2]) format "x(20)" trim(bankl.addr[3]) format "x(20)" skip
"Tel:      " trim(bankl.tel) skip
"Fax:      " trim(bankl.fax) space(30) "НАЛОГОВЫЙ КОМИТЕТ " skip
"Telex:    " trim(bankl.tlx) space(30) "        ПО" skip
"S.W.I.F.T:" trim(bankl.bic) space(30)  codfr.name[1] format "x(22)" skip        "                                             ----------------------"
skip
"                                                            РАЙОНУ" skip(2).
            
            find first codfr where codfr.codfr = "clsa" and codfr.code = "c1"
            no-lock no-error.
            put stream m-out2
            "    'TEXAKABANK' СТАВИТ ВАС В ИЗВЕСТНОСТЬ, ЧТО  "
            trim(trim(cif.prefix) + " " + trim(cif.name)) format "x(50)" skip.
            put stream m-out2
            " ЗАРЕГИСТРИРОВАННОЙ У ВАС ПОД  "  
            cif.jss format "x(20)" 
            " ЗАКРЫТ СЧЕТ N " aaa.aaa format "x(10)" skip
            " ПО ПРИЧИНЕ  " codfr.name[1] skip
            " " sub-cod.rdt  format "99/99/9999" skip
            " ЗАМ.ГЛАВ.БУХГАЛТЕРА" skip(1)
            "-----------------------------------------------------------------"
            skip(2).
    end.
end.

put stream m-out1 skip(1)
   "от " string(v-dat) skip(1)
   "Зам.главного бухгалтера" skip
   trim(bankl.name) format "x(30)" skip(1).
output stream m-out1 close. 
output stream m-out2 close.

end.

if not g-batch then do :
    pause 0.
    unix value(comprt) value (file1).
    pause 0.
    unix value(comprt) value (file2).
    pause 0.
end.

