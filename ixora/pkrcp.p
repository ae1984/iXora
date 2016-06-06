/* pkrcp.p
 * MODULE
        Потребительское кредитование
 * DESCRIPTION
        Копирование на локальную машину пользователя каких-нибудь файлов в локальный каталог
        например, файл факсимиле первого руководителя - для подписи договоров
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU
        4-6-2
 * AUTHOR
        nadejda
 * BASES
        BANK COMM
 * CHANGES
        23.07.2003 nadejda - поменяла выбор пути к файлам факсимиле на путь базы + каталог (т.е. каталог свой для каждого филиала)
        10.09.2003 nadejda - добавила логирование для каждого файла, поставила паузы после каждого вызова rsh, добавила вывод имен файлов при ошибке
        24.09.2004 dpuchkov - добавил подпись директора казначейства.
        21/12/2005 madiyar - добавил электронную печать для БД
        09/02/2006 madiyar - добавил копирование файла с логотипом банка
        14/06/2006 madiyar - добавил копирование файла pkdogsgn-pp.jpg
        12/09/2006 madiyar - электронная печать для БД по всем филиалам
        31/10/2006 madiyar - убрал логи и поменял явное использование rcp на скриптик cpy
        13/11/2008 madiyar - добавил копирование файла pkdogsgn1.jpg
        12/08/2011 evseev - копирование подписей и оттисков СП. ТЗ-1128
        04.01.2012 damir - Добавил копирование файла sf1.jpg.
*/
{global.i}
{pk.i "new"}

displ skip(1) "    Ждите...   " skip(1) with row 8 centered frame f-wait.

def var v-dcpath as char.
def var v-dcsign as char.
def var v as char.
def var v-str as char.

def temp-table t-files
    field name as char format "x(70)"
    field fname as char.

/*def var v-hostmy as char format "x(50)".
def var v-ipaddr as char format "x(30)".
input through askhost.
repeat:
import v-hostmy.
end.
input close.
pause 5 no-message.
run savelog("pkrcp", v-hostmy).*/

/* определение каталога для копий файлов на локальной машине юзера */
input through localtemp.
repeat:
    import s-tempfolder.
end.
input close.
pause 5 no-message.
if substr(s-tempfolder, length(s-tempfolder), 1) <> "\\" then s-tempfolder = s-tempfolder + "\\".

run savelog("pkrcp", s-tempfolder).

{pk-sysc.i}

/*находим все файлы подписей путь, где лежат исходники документов для каждого вида кредитов : /data/docs*/

for each bookcod where bookcod.bookcod = "credtype" no-lock:
    s-credtype = bookcod.code.
    v-dcpath = get-pksysc-char ("dcpath").
    if not v-dcpath begins "/" then v-dcpath = "/" + v-dcpath.
    v-dcpath = g-dbdir + v-dcpath.
    v-dcsign = get-pksysc-char ("dcsign").
    if not((v-dcpath + v-dcsign = "") or (v-dcsign = "") or (v-dcpath + v-dcsign = ?)) then do:
        find first t-files where t-files.name = v-dcpath + v-dcsign no-error.
        if not avail t-files then do:
            create t-files.
            t-files.name = v-dcpath + v-dcsign.
            t-files.fname = v-dcsign.
        end.
    end.
    if s-credtype = '6' then do:
        if not((v-dcpath = "") or (v-dcpath = ?)) then do:
            find first t-files where t-files.name = v-dcpath + "top_logo_bw.jpg" no-error.
            if not avail t-files then do:
                create t-files.
                t-files.name = v-dcpath + "top_logo_bw.jpg".
                t-files.fname = "top_logo_bw.jpg".
            end.
            /* для формирования писем задолжникам с подписью директора филиала */
            find first t-files where t-files.name = v-dcpath + "pkdogsgn1.jpg" no-error.
            if not avail t-files then do:
                create t-files.
                t-files.name = v-dcpath + "pkdogsgn1.jpg".
                t-files.fname = "pkdogsgn1.jpg".
            end.
            /* Логотип <ForteBank>. Используется в счетах-фактурах,... и т.д. */
            find first t-files where t-files.name = v-dcpath + "sf1.jpg" no-error.
            if not avail t-files then do:
                create t-files.
                t-files.name = "/data/docs/sf1.jpg".
                t-files.fname = "sf1.jpg".
            end.
        end.
        v-dcsign = get-pksysc-char ("dcstmp").
        if not((v-dcpath + v-dcsign = "") or (v-dcsign = "") or (v-dcpath + v-dcsign = ?)) then do:
            find t-files where t-files.name = v-dcpath + v-dcsign no-error.
            if not avail t-files then do:
                create t-files.
                t-files.name = v-dcpath + v-dcsign.
                t-files.fname = v-dcsign.
            end.
        end.
    end.
end.
/* копируем файлы */
v-str = "".
for each t-files:
/*run savelog("pkrcp","  rcp " + t-files.name + " " + v-hostmy + ":" + replace(s-tempfolder, "\\", "/") + ";echo $?").*/
/*input through value("rcp " + t-files.name + " " + v-hostmy + ":" + replace(s-tempfolder, "\\", "/") + ";echo $?").*/
    input through value("cpy -put " + t-files.name + " " + replace(s-tempfolder, "\\", "/") + ";echo $?").
    repeat:
        import v.
    end.
    input close.
    pause 3 no-message.

    if v <> "0" then do:
        if v-str <> "" then v-str = v-str + "; ".
        v-str = v-str + t-files.fname.
    end.
    /*run savelog("pkrcp","  result: " + v).*/
end.
/*Подпись казначейства согласно ТЗ 972 и  805*/
def buffer bpodpsys for sysc.
find last bpodpsys where bpodpsys.sysc = "OURBNK" no-lock no-error.
if bpodpsys.chval = "TXB00" then do:
    input through value("cpy -put " + v-dcpath + "oprdogsgn.jpg" + " " + replace(s-tempfolder, "\\", "/") + ";echo $?").
    input through value("cpy -put " + v-dcpath + "oprstamp.jpg" + " " + replace(s-tempfolder, "\\", "/") + ";echo $?").
end.

find sysc where sysc.sysc = 'SGNFL' no-lock no-error.
if avail sysc then do:
    /*run savelog("pkrcp","  rcp " + v-dcpath + sysc.chval + " " + v-hostmy + ":" + replace(s-tempfolder, "\\", "/") + ";echo $?").*/
    input through value("cpy -put " + v-dcpath + sysc.chval + " " + replace(s-tempfolder, "\\", "/") + ";echo $?").
end.
find sysc where sysc.sysc = 'SGNFL1' no-lock no-error.
if avail sysc then do:
    /*run savelog("pkrcp","  rcp " + v-dcpath + sysc.chval + " " + v-hostmy + ":" + replace(s-tempfolder, "\\", "/") + ";echo $?").*/
    input through value("cpy " + v-dcpath + sysc.chval + " " + replace(s-tempfolder, "\\", "/") + ";echo $?").
end.
/*Подпись казначейства согласно ТЗ 972 и 805*/
/*Подписи СП, согластно тз 1128*/
def var vpoint like point.point .
def var vdep like ppoint.dep .
def var v-res as char no-undo.
def var v-f2 as char no-undo.
find first ofc where ofc.ofc = g-ofc no-lock no-error.
vpoint =  integer(ofc.regno / 1000).
vdep = ofc.regno mod 1000.

find ppoint where ppoint.point = vpoint and ppoint.dep = vdep no-lock no-error.
if avail ppoint and ppoint.name matches "*СП*" and ppoint.info[5] <> "" and ppoint.info[6] <> "" and ppoint.info[7] <> "" then do:
    v-f2 = v-dcpath + "dogsgn_sp_" + string(vdep) + "_1.jpg".
    input through value ("if [ -e " + v-f2 + " ]; then echo 1; else echo 0; fi").
    import unformatted v-res.
    if v-res = "1" then do:
        input through value("cpy -put " + v-f2 + " " + replace(s-tempfolder, "\\", "/") + ";echo $?").
    end.
    else do:
        if v-str <> "" then v-str = v-str + "; ".
        v-str = v-str + v-f2.
    end.

    v-f2 = v-dcpath + "stamp_sp_" + string(vdep) + "_1.jpg".
    input through value ("if [ -e " + v-f2 + " ]; then echo 1; else echo 0; fi").
    import unformatted v-res.
    if v-res = "1" then do:
        input through value("cpy -put " +  v-f2 + " " + replace(s-tempfolder, "\\", "/") + ";echo $?").
    end.
    else do:
        if v-str <> "" then v-str = v-str + "; ".
        v-str = v-str + v-f2.
    end.
end.
/*Подписи СП, согластно тз 1128*/
hide frame f-wait no-pause.
if v-str = "" then message skip " Предварительная настройка завершена !" skip(1) view-as alert-box title "".
else message skip " Во время предварительной настройки произошла ошибка !"
skip " Файлы :" v-str
skip(1) " Обратитесь к системному администратору !"
skip(1) view-as alert-box title " ОШИБКА ! ".
