/* r101.p
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
 * BASES
        BANK COMM
 * AUTHOR
        31/12/99 pragma
 * CHANGES
*/

/*
   30.10.2002 nadejda - наименование клиента заменено на форма собств + наименование 
*/

def var m-sum like glbal.bal.
def var m-sum1 like glbal.bal.
def var v-cgr like cgr.cgr.
def var i as integer.
def var j as integer.
def var m-date as date.
def var vt1 as char.
def var vt2 as char.
def var vt3 as char.
def var vt0 as char.

m-sum = 0.
m-sum1 = 0.

def stream m-ekr.

output stream m-ekr to terminal.
find last cls no-lock no-error.

{mainhead.i R101}  /* CD MATURING ON TODAY */
{image1.i rpt.img}

repeat:
    update "Группа клиента " at 50 v-cgr with no-box no-label .
    find cgr where cgr.cgr = v-cgr no-lock.
    if available cgr then leave.
end.

{image2.i}
{report1.i 59}

vtitle = "Счета на " + string(cls.cls) +
" Группа клиентов : " + cgr.name.

find ofc where ofc.ofc = g-ofc no-lock no-error.

vt1 = " ККл       Наименование клиента" .
vt2 = "Счет       Валюта              Сумма            Сумма(латы)".


{report2.i 70
"skip vt1 form 'x(70)' skip vt2 form 'x(70)' skip(1) "}

put /* stream m-out */
" Наименование валюты                     Курс Количество" skip
"--------------------------------------------------------" skip.

i = 0.
for each crc :
    if crc.sts <> 9 then do:
        i = i + 1.
        put  i format "z9" ' ' crc.des ' ' crc.rate[1] ' за  '
        crc.rate[9] format "zzzz9" skip.
    end.
end.

put /* stream m-out */ skip(2).


i = 0.

for each cif no-lock :
    if cif.cgr = v-cgr then do:
        display /* stream m-out */
        cif.cif trim(trim(cif.prefix) + " " + trim(cif.name)) format "x(60)" skip
        fill("-",68) format "x(68)"
        with frame a no-label no-box.
        m-sum = 0.
        for each aaa where aaa.cif = cif.cif no-lock :
            if aaa.sta <> "C" then do :
                find crc where crc.crc = aaa.crc no-lock.
                display /* stream m-out */ aaa.aaa crc.code
                aaa.cr[1] - aaa.dr[1]
                format "->,>>>,>>>,>>>,>>9.99"
                ( aaa.cr[1] - aaa.dr[1] ) * crc.rate[1] / crc.rate[9]
                format "->,>>>,>>>,>>>,>>9.99" with frame b no-label no-box.
                m-sum = m-sum +
                ( aaa.cr[1] - aaa.dr[1] ) * crc.rate[1] / crc.rate[9].
            end.
        end.
        m-sum1 = m-sum1 + m-sum.
        display /* stream m-out */ fill("-",68) format "x(68)" skip
        /* with frame c1 no-label no-box. */
        /* display /* stream m-out */ */
        "Итог " fill(" ",30) format "x(30)" m-sum
        format "->,>>>,>>>,>>>,>>9.99" skip
        fill("=",68) format "x(68)" skip(1)
        with frame c no-label no-box.

    end.
    if i = j then do:
        display stream m-ekr "Обработано записей " i with
        frame aaa row 12 centered no-label .
        pause 0.
        j = j + 100.
    end.
    i = i + 1.
end.

        display /* stream m-out */
        "Итого по всем счетам     " fill(" ",12) format "x(12)" m-sum1
        format "->,>>>,>>>,>>>,>>9.99" skip(1)
        with frame c1 no-label no-box.



put /* stream m-out */
"*************    Конец документа   *************"  skip.

output stream m-ekr close.

{report3.i}
{image3.i}
