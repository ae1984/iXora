/* r-dopusk.p
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

/*r-dopusk.p отчет по счетам где нарушен минимум остатка (меньше 200 долларов)
   30.10.2002 nadejda - наименование клиента заменено на форма собств + наименование 
*/

{global.i}

def stream m-out.
def var v-dat as date label "ДАТА    ".
def var comprt as cha initial "prit  " format "x(10)" .
def var v-new as log  format "создать/продожить"  initial "Создать".
def var dopusk as int.
def var vcrc1 as inte.
def var vcrc2 as inte.
def var cas1 as logi.
def var cas2 as logi.
def var amt1 as deci.
def var amt2 as deci.
def var vrat1 as deci decimals 4 format "9.9999".
def var vrat2 as deci decimals 4 format "9.9999".
def var coef1 as inte.
def var coef2 as inte.
def var marg1 as deci.
def var marg2 as deci.

v-dat = g-today.
if not g-batch then do :
    update v-dat skip
    comprt label  "Команда " skip
    v-new label "Создать(с)/продожить(п)"
    with side-label row 5 centered frame dat .
end.
else v-dat = g-today.

find sysc where sysc.sysc eq "DOPUSK" no-lock no-error.
if not available sysc then do:
    message "Введите DOPUSK в sysc".
    pause.
    return.
end.    
dopusk = sysc.inval.


display "......Ж Д И Т Е ......."  with row 12 frame ww centered .

if v-new then do :
output stream m-out to rpt.img.
put stream m-out "          СЧЕТА ГДЕ НАРУШЕН МИНИМУМ ОСТАТКА (200 ДОЛЛАРОВ)" 
skip.
put stream m-out "                    ДАТА: " v-dat format "99/99/9999" 
skip(1).
put stream m-out "------------------------------------------------------------"
"-----------------------------" skip.
put stream m-out " N СЧЕТА     КЛИЕНТ     НАИМЕНОВАНИЕ КЛИЕНТА           ВАЛ " 
"    СУММА НОМ.       СУММА USD" skip.
put stream m-out "------------------------------------------------------------"
"-----------------------------" skip.
for each lgr where lgr.led eq "SAV":
    for each aaa where aaa.sta <> "C" and aaa.regdt <> v-dat  and 
    aaa.lgr eq lgr.lgr break by aaa.crc:
    if v-dat = g-today then do:
        amt1 = aaa.cr[1] - aaa.dr[1].
        vcrc1 = aaa.crc. vcrc2 = 2.
        cas1 = false. cas2 = false.
        amt2 = 0.
        run conv(vcrc1,vcrc2,cas1,cas2,input-output amt1, input-output amt2,
                 output vrat1, output vrat2, output coef1, output coef2,
                 output marg1, output marg2).
        if amt2 >= dopusk then next.
        if amt2 < dopusk then do:
            find cif where cif.cif eq aaa.cif no-lock no-error.
            find crc where crc.crc eq aaa.crc no-lock no-error.
            put stream m-out aaa.aaa "  " 
            aaa.cif "   " trim(trim(cif.prefix) + " " + trim(cif.name)) format "x(30)" "   "  
            crc.code "   " amt1 format "-z,zzz,zz9.99" "   "
            amt2 format "-z,zzz,zz9.99" skip.
        end.
    end.
    else do:
        find last aab where aab.aaa eq aaa.aaa and aaa.regdt le v-dat no-lock 
        no-error.
        if available aab then do:    
            amt1 = aab.bal. /*aab.avl*/ 
            vcrc1 = aaa.crc. vcrc2 = 2.
            cas1 = false. cas2 = false.
            amt2 = 0.
            run conv(vcrc1,vcrc2,cas1,cas2,input-output amt1, input-output amt2,
                output vrat1, output vrat2, output coef1, output coef2,
                output marg1, output marg2).
            if amt2 >= dopusk then next.
            if amt2 < dopusk then do:
                find cif where cif.cif eq aaa.cif no-lock no-error.
                find crc where crc.crc eq aaa.crc no-lock no-error.
                put stream m-out aaa.aaa "  " 
                aaa.cif "   " trim(trim(cif.prefix) + " " + trim(cif.name)) format "x(30)" "   "  
                crc.code "   " amt1 format "-z,zzz,zz9.99" "   "
                amt2 format "-z,zzz,zz9.99" skip.
            end.
        end.
    end.    
end.        
end.
put stream m-out "------------------------------------------------------------"
"-----------------------------" skip(2).


output stream m-out close.
end.
if not g-batch then do :
    pause 0.
    unix value(comprt) rpt.img.
    pause 0.
end.





